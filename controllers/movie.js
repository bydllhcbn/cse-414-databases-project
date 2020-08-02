let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/', async (req, res) => {
    res.send('respond with a resource');
});

router.get('/list', async (req, res) => {
    let movies = await db.db(`SELECT id, name, created_at, updated_at
                              FROM movies`);

    res.render('movie/list', {title: 'Filmler', movies: movies});
});


router.get('/add', async (req, res) => {

    res.render('movie/add', {title: 'Film Ekle'});
});


router.post('/add', async (req, res) => {
    await db.dbInsert("INSERT INTO movies (name) VALUES (?)", [req.body.name]);
    res.resultOkRedirect("Başarıyla eklendi", "/movie/list");
});

module.exports = router;
