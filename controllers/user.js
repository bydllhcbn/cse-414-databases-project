let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/list', async (req, res) => {
    let users = await db.db(`SELECT id, username, password, user_role
                             FROM users`);
    res.render('user/list', {title: 'Kullanıcılar', users: users});
});

router.get('/add', async (req, res) => {

    res.render('user/add', {title: 'Kullanıcı Kaydet'});
});
router.get('/login', async (req, res) => {

    res.render('user/login', {title: 'Giriş Yap'});
});

router.get('/logout', async (req, res) => {
    res.cookie('auth_id', '', {maxAge: 0, httpOnly: true});
    res.cookie('auth_type', '', {maxAge: 0, httpOnly: true});
    res.redirect('/')
});


router.post('/login', async (req, res) => {
    let user = await db.dbGetFirst("SELECT id,user_role FROM users WHERE username = ? AND password = ?",
        [req.body.username, req.body.password])
    if (user) {
        res.cookie('auth_id', user.id, {maxAge: 900000000, httpOnly: true});
        res.cookie('auth_type', user.user_role, {maxAge: 900000000, httpOnly: true});
        res.resultRedirect('/');
    } else {
        res.resultError("Bilgiler yanlış!")
    }
});


router.post('/add', async (req, res) => {
    await db.dbInsert(`INSERT INTO users (username, password, user_role)
                       VALUES (?, ?, ?)`, [req.body.username, req.body.password, req.body.userRole])

    res.resultOkRedirect("Başarıyla eklendi.", "/user/list")
});


module.exports = router;
