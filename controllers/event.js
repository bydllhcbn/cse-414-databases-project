let express = require('express');
let router = express.Router();
let db = require('../db');


router.get('/list/:event_group_id', async (req, res) => {
    let events = await db.db(`SELECT events.id,
                                     place_id,
                                     LEFT(start_date, 10) as start_date,
                                     LEFT(end_date, 10)   as end_date,
                                     p.place_name
                              FROM events
                                       INNER JOIN places p on events.place_id = p.id
                              WHERE event_group_id = ?`, [req.params.event_group_id]);


    let eventGroup = await db.dbGetFirst(`SELECT id, event_name, category_id, created_at, updated_at
                                          FROM event_group
                                          WHERE id = ?`, [req.params.event_group_id])
    res.render('event/list', {
        title: eventGroup.event_name + ' Bulunan Etkinlikler',
        events: events,
        eventGroup: eventGroup
    });
});


router.get('/add/:event_group_id', async (req, res) => {

    let eventGroup = await db.dbGetFirst(`SELECT id, event_name, category_id, created_at, updated_at
                                          FROM event_group
                                          WHERE id = ?`, [req.params.event_group_id])
    //only allowed categories for event group
    let places = await db.db(`SELECT id, city_id, place_name
                              FROM places
                                       INNER JOIN place_allowed_categories pac on places.id = pac.place_id
                              WHERE pac.event_category_id = ?`, [eventGroup.category_id]);

    res.render('event/add', {
        title: 'Etkinlik Ekle',
        event_group_id: req.params.event_group_id,
        places: places,
        eventGroup: eventGroup
    });
});


router.get('/edit/:id', async (req, res) => {

    let event = await db.dbGetFirst(`SELECT id,
                                            place_id,
                                            event_group_id,
                                            start_date,
                                            end_date,
                                            created_at,
                                            is_published,
                                            updated_at
                                     FROM events
                                     WHERE id = ?`, [req.params.id]);
    let places = await db.db("SELECT id, city_id, place_name FROM places");

    let eventGroup = await db.dbGetFirst(`SELECT id, event_name, category_id, created_at, updated_at
                                          FROM event_group
                                          WHERE id = ?`, [event.event_group_id])

    let prices = await db.db(`SELECT place_id,
                                     section_name,
                                     id,
                                     (SELECT price
                                      FROM seat_prices
                                      WHERE seat_section_id = seat_sections.id
                                        AND event_id = ?) AS price
                              FROM seat_sections
                              WHERE place_id = ?`, [event.id, event.place_id]);

    let rules = await db.db("SELECT event_id, rule FROM event_rules WHERE event_id = ?", [event.id]);

    let availableSeats = await db.db(`SELECT seats.id, seat_number, section_name, place_name
                                      FROM seats
                                               INNER JOIN seat_sections ss on seats.seat_section_id = ss.id
                                               INNER JOIN places p on ss.place_id = p.id
                                      WHERE p.id = ?
                                        AND seats.id NOT IN (SELECT seat_id FROM event_reserved_seat WHERE event_id = ?)
                                        AND seats.id NOT IN (SELECT seat_id FROM tickets WHERE event_id = ?)`,
        [event.place_id, event.id, event.id]);

    let reservedSeats = await db.db(`SELECT seats.id, seat_number, section_name
                                     FROM seats
                                              INNER JOIN event_reserved_seat ers on seats.id = ers.seat_id
                                              INNER JOIN seat_sections ss on seats.seat_section_id = ss.id
                                     WHERE ers.event_id = ?`, [event.id]);
    res.render('event/edit', {
        title: 'Etkinliği Düzenle',
        event: event,
        places: places,
        prices: prices,
        availableSeats: availableSeats,
        reservedSeats: reservedSeats,
        rules: rules,
        eventGroup: eventGroup
    });
});


router.get('/view/:id', async (req, res) => {
    let event = await db.dbGetFirst(`SELECT id,
                                            place_id,
                                            event_group_id,
                                            LEFT(start_date, 10) as start_date,
                                            LEFT(end_date, 10)   as end_date,
                                            created_at,
                                            is_published,
                                            updated_at,
                                            start_date < CURRENT_TIMESTAMP as isStarted
                                     FROM events
                                     WHERE id = ?`, [req.params.id]);
    let places = await db.db("SELECT id, city_id, place_name FROM places");

    let eventGroup = await db.dbGetFirst(`SELECT id, event_name, category_id, created_at, updated_at
                                          FROM event_group
                                          WHERE id = ?`, [event.event_group_id])


    let rules = await db.db("SELECT event_id, rule FROM event_rules WHERE event_id = ?", [event.id]);

    let ticketCategories = await db.db("SELECT id, category_name, discount FROM ticket_categories");
    let eventSeats = await db.db(`SELECT * FROM available_tickets WHERE event_id = ?`, [event.id])

    let discount = await db.dbGetFirst("SELECT * FROM campaign_events WHERE id = ?", [req.params.id])
    console.log(discount);
    res.render('event/view', {
        title: 'Etkinlik Detayı',
        event: event,
        places: places,
        rules: rules,
        ticketCategories: ticketCategories,
        eventSeats: eventSeats,
        eventGroup: eventGroup,
        discount: discount
    });
});

router.post('/add', async (req, res) => {

    let id = await db.dbInsert("INSERT INTO events (place_id, event_group_id, start_date, end_date) VALUES (?,?,?,?)",
        [req.body.placeId, req.body.eventGroupId, req.body.startDate, req.body.endDate]);

    res.resultOkRedirect("Başarıyla eklendi.", "/event/edit/" + id);
});
router.post('/addReservedSeat', async (req, res) => {

    await db.dbInsert("INSERT IGNORE INTO event_reserved_seat (event_id, seat_id) VALUES (?,?)", [
        req.body.eventId, req.body.seatId
    ]);
    res.resultOkReload("Başarıyla eklendi.");
});

router.post('/edit', async (req, res) => {

    await db.startTransaction();
    await db.dbUpdate("UPDATE events SET place_id = ? WHERE id = ?",
        [req.body.placeId, req.body.eventId]);


    let seatSections = await db.db("SELECT id FROM seat_sections WHERE place_id = ?", [req.body.placeId]);

    for (let section of seatSections) {
        let price = req.body['price-' + section.id];
        await db.dbUpdate(`INSERT INTO seat_prices (seat_section_id, event_id, price)
                           VALUES (?, ?, ?)
                           ON DUPLICATE KEY UPDATE price = ?`,
            [section.id, req.body.eventId, price, price]);
    }
    await db.commitTransaction();

    res.resultOkReload("Başarıyla güncellendi.");
});
router.post('/addRule', async (req, res) => {
    await db.dbInsert("INSERT INTO event_rules (event_id, rule) VALUES (?,?)",
        [req.body.eventId, req.body.rule]);

    res.resultOkReload("Başarıyla eklendi.");
});

router.post('/buyTicket', async (req, res) => {
    await db.dbInsert("INSERT INTO tickets (ticket_category_id, event_id, seat_id, sold_user_id,discount) VALUES (?,?,?,?,?)",
        [req.body.category, req.body.event, req.body.seat, req.auth_id, req.body.discount]);

    res.resultOkReload("Başarıyla eklendi.");
});


module.exports = router;
