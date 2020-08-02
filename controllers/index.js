let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/', async (req, res) => {
    let events = await db.db(`SELECT * FROM active_event_groups`)
    res.render('index', {title: 'Aktif Etkinlikler', events: events});
});

module.exports = router;
