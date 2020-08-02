let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/list', async (req, res) => {
    let actors = await db.db("SELECT id, name FROM actors");
    res.render('actor/list', {title: 'Sanatçılar', actors: actors});
});

router.get('/add', async (req, res) => {
    res.render('actor/add', {title: 'Sanatçı Ekle'});
});


router.post('/add', async (req, res) => {
    await db.dbInsert("INSERT INTO actors (name) VALUES (?)", [req.body.name]);

    res.resultOkRedirect("Başarıyla eklendi", "/actor/list");
});
module.exports = router;
