let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/', async (req, res) => {
    res.send('respond with a resource');
});

router.get('/add', async (req, res) => {
    let eventGroups = await db.db("SELECT id, event_name FROM event_group")
    let places = await db.db("SELECT id, place_name FROM places")
    let categories = await db.db("SELECT id, category_name FROM event_categories")
    res.render('campaign/add', {
        title: 'Kampanya Ekle',
        eventGroups: eventGroups,
        categories: categories,
        places: places
    });
});

router.get('/list', async (req, res) => {
    let campaigns = await db.db(`SELECT campaigns.id,
                                        start_date,
                                        end_date,
                                        discount,
                                        title,
                                        event_category_id,
                                        ec.category_name,
                                        p.place_name,
                                        eg.event_name
                                 FROM campaigns
                                          LEFT JOIN event_categories ec on campaigns.event_category_id = ec.id
                                          LEFT JOIN places p on campaigns.place_id = p.id
                                          LEFT JOIN event_group eg on campaigns.event_group_id = eg.id`);

    res.render('campaign/list', {title: 'Kampanyalar', campaigns: campaigns});
});


router.post('/add', async (req, res) => {
    let category = req.body.category;
    category = category == '0' ? null : category;
    let eventGroup = req.body.eventGroup;
    eventGroup = eventGroup == '0' ? null : eventGroup;
    let place = req.body.place;
    place = place == '0' ? null : place;
    let discount = req.body.discount;
    let startDate = req.body.startDate;
    let endDate = req.body.endDate;
    let title = req.body.title;


    await db.dbInsert(`INSERT INTO campaigns (start_date, end_date, discount, title, event_category_id, place_id,
                                              event_group_id)
                       VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [startDate, endDate, discount, title, category, place, eventGroup]);

    res.resultOkRedirect('Kampanya başarıyla yayınlandı.', '/campaign/list')
});

router.post('/delete', async (req, res) => {
    await db.dbUpdate("DELETE FROM campaigns WHERE id = ?", [req.body.id])
    res.resultOkReload('Kampanya silindi.')
});


module.exports = router;
