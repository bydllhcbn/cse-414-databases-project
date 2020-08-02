let express = require('express');
let router = express.Router();
let db = require('../db');
router.get('/', async (req, res) => {
    res.send('respond with a resource');
});

router.get('/list', async (req, res) => {
    let places = [];
    if (req.auth_type === 'PLACE_OWNER') {
        places = await db.db(`SELECT places.id, city_id, place_name, city_name, country_id
                              FROM places
                                       INNER JOIN place_cities pc on places.city_id = pc.id
                              WHERE places.owner_id = ?`, [req.auth_id]);
    } else {
        places = await db.db(`SELECT places.id, city_id, place_name, city_name, country_id
                              FROM places
                                       INNER JOIN place_cities pc on places.city_id = pc.id`);
    }

    res.render('place/list', {title: 'Mekanlar', places: places});
});


router.get('/seats', async (req, res) => {
    let seats = [];
    seats = await db.db(`SELECT seat_number, total_price, total_tickets, p.place_name
                         FROM seat_income
                                  INNER JOIN places p on seat_income.place_id = p.id
                         WHERE p.owner_id = ?`, [req.auth_id]);

    res.render('place/seats', {title: 'Koltuklar ve Gelirler', seats: seats});
});


router.get('/add', async (req, res) => {
    let cities = await db.db("SELECT id, city_name, country_id FROM place_cities")
    let categories = await db.db("SELECT id, category_name FROM event_categories")
    res.render('place/add', {title: 'Mekan Ekle', cities: cities, categories: categories});
});

router.get('/edit/:id', async (req, res) => {
    let place = await db.dbGetFirst("SELECT id, city_id, place_name FROM places WHERE id = ?", [req.params.id])
    let cities = await db.db("SELECT id, city_name, country_id FROM place_cities")
    let sections = await db.db("SELECT id, place_id, section_name FROM seat_sections WHERE place_id = ?", [req.params.id])
    let seats = await db.db(`SELECT seats.id, seat_section_id, seat_number, ss.section_name
                             FROM seats
                                      INNER JOIN seat_sections ss on seats.seat_section_id = ss.id
                             WHERE place_id = ?`, [req.params.id])
    let categories = await db.db(`SELECT id,
                                         category_name,
                                         (SELECT place_id
                                          FROM place_allowed_categories pac
                                          WHERE pac.event_category_id = id
                                            AND place_id = ?) as selected
                                  FROM event_categories`, [req.params.id])
    res.render('place/edit',
        {
            title: 'Mekan Düzenle',
            cities: cities,
            categories: categories,
            place: place,
            seats: seats,
            sections: sections
        });
});

router.post('/add', async (req, res) => {

    let name = req.body.name;
    let city = req.body.city;
    let allowedCategories = req.body.allowedCategories;


    let user = null;
    if (req.auth_type === 'PLACE_OWNER') {
        user = req.auth_id;
    }
    let placeId = await db.dbInsert("INSERT INTO places (place_name,city_id,owner_id) VALUES (?,?,?)", [name, city, user]);

    if (!allowedCategories) {
        res.resultOk("Lütfen kategori seç");
        return;
    }
    for (let cat of allowedCategories) {
        await db.dbInsert("INSERT INTO place_allowed_categories (place_id, event_category_id) VALUES  (?,?)",
            [placeId, cat])
    }
    res.resultOkRedirect('Başarıyla eklendi', '/place/edit/' + placeId);
});

router.post('/addSeatSection', async (req, res) => {
    await db.dbInsert("INSERT INTO seat_sections (place_id, section_name) VALUES (?,?)", [
        req.body.placeId, req.body.name
    ]);
    res.resultReload();
});


router.post('/addSeat', async (req, res) => {
    await db.dbInsert("INSERT INTO seats (seat_section_id, seat_number) VALUES (?,?)", [
        req.body.sectionId, req.body.seatNumber
    ]);
    res.resultReload();
});


router.post('/edit', async (req, res) => {

    let placeId = req.body.placeId;
    let name = req.body.name;
    let city = req.body.city;
    let allowedCategories = req.body.allowedCategories;

    await db.dbUpdate("UPDATE places SET place_name=?,city_id=? WHERE id = ?", [name, city, placeId]);

    await db.dbUpdate("DELETE FROM place_allowed_categories WHERE place_id = ?", [placeId]);

    for (let cat of allowedCategories) {
        await db.dbInsert("INSERT INTO place_allowed_categories (place_id, event_category_id) VALUES  (?,?)",
            [placeId, cat])
    }
    res.resultReload('Başarıyla güncellendi');
});


router.post('/deleteSeatSection', async (req, res) => {
    let a = await db.dbUpdate("DELETE FROM seat_sections WHERE id = ?", [req.body.id]);
    if (a) {
        res.resultOkReload("Başarıyla silindi.");
    } else {
        res.resultOkReload("Silinirken bir hata oluştu.");
    }
});

router.post('/deleteSeat', async (req, res) => {
    let a = await db.dbUpdate("DELETE FROM seats WHERE id = ?", [req.body.id]);
    if (a) {
        res.resultOkReload("Başarıyla silindi.");
    } else {
        res.resultOkReload("Silinirken bir hata oluştu.");
    }
});
module.exports = router;
