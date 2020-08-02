let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/', async (req, res) => {
    res.send('respond with a resource');
});

router.get('/list', async (req, res) => {
    let tickets = await db.db(`SELECT tickets.id,
                                      ticket_category_id,
                                      event_id,
                                      seat_id,
                                      u.username,
                                      eg.event_name,
                                      p.place_name,
                                      s.seat_number
                               FROM tickets
                                        INNER JOIN events e on tickets.event_id = e.id
                                        INNER JOIN event_group eg on e.event_group_id = eg.id
                                        INNER JOIN users u on tickets.sold_user_id = u.id
                                        INNER JOIN seats s on tickets.seat_id = s.id
                                        INNER JOIN places p on e.place_id = p.id

    `);

    let ticketCategories = await db.db("SELECT id, category_name, discount FROM ticket_categories")
    res.render('ticket/list', {title: 'Biletler', tickets: tickets, ticketCategories: ticketCategories});
});


router.get('/add', async (req, res) => {

    let users = await db.db("SELECT id, username, name, password, user_role, created_at, updated_at FROM users");
    let ticketCategories = await db.db("SELECT id, category_name, discount FROM ticket_categories");
    let eventSeats = await db.db(`SELECT events.id                 as event_id,
                                         s.id                      as seat_id,
                                         eg.event_name,
                                         place_name,
                                         section_name,
                                         seat_number,
                                         (ers.seat_id IS NOT NULL) as isReserved,
                                         (t.id IS NOT NULL)           isSold
                                  FROM events
                                           INNER JOIN event_group eg on events.event_group_id = eg.id
                                           INNER JOIN places p on events.place_id = p.id
                                           INNER JOIN seat_sections ss on p.id = ss.place_id
                                           INNER JOIN seats s on ss.id = s.seat_section_id
                                           LEFT JOIN event_reserved_seat ers
                                                     on (events.id = ers.event_id AND ers.seat_id = s.id)
                                           LEFT JOIN tickets t on (events.id = t.event_id AND t.seat_id = s.id)`)

    res.render('ticket/add', {
        title: 'Bilet Sat',
        users: users,
        eventSeats: eventSeats,
        ticketCategories: ticketCategories
    });
});

router.post('/addTicketCategory', async (req, res) => {
    await db.dbInsert("INSERT INTO ticket_categories (category_name, discount) VALUES (?,?)",
        [req.body.name, req.body.discount]);
    res.resultOkReload("Başarıyla eklendi!");
});


router.post('/add', async (req, res) => {
    let ticket = req.body.ticket.split('-');
    let eventId = ticket[0];
    let seatId = ticket[1];

    await db.dbInsert(`INSERT INTO tickets (ticket_category_id, event_id, seat_id, sold_user_id)
                       VALUES (?, ?, ?, ?)`,
        [req.body.category, eventId, seatId, req.body.user]);

    res.resultOkRedirect("Başarıyla eklendi!", "/ticket/list");
});


router.get('/my-list', async (req, res) => {
    let tickets = await db.db(`SELECT *
                               FROM sold_tickets
INNER JOIN events e on sold_tickets.event_id = e.id
INNER JOIN event_group eg on e.event_group_id = eg.id
                               WHERE sold_user_id = ?
ORDER BY sold_tickets.created_at DESC
                               `, [req.auth_id]);

    res.render('ticket/myList', {title: 'Biletlerim', tickets: tickets});
});


module.exports = router;
