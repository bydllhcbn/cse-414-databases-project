let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/', async (req, res) => {
  res.send('respond with a resource');
});


router.get('/list', async (req, res) => {
    let musics = await db.db(`SELECT id, name, created_at, updated_at FROM musics`);

    res.render('music/list', {title: 'Müzikler', musics: musics});
});


router.get('/add', async (req, res) => {
    res.render('music/add', {title: 'Müzik Ekle'});
});


router.post('/add', async (req, res) => {
    await db.dbInsert("INSERT INTO musics (name) VALUES (?)", [req.body.name]);
    res.resultOkRedirect("Başarıyla eklendi", "/music/list");
});

module.exports = router;
