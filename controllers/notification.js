let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/', async (req, res) => {
    res.send('respond with a resource');
});


router.get('/list', async (req, res) => {
    let notifications = await db.db(`SELECT id, text, user_id, is_read, created_at
                                    FROM notifications
                                    WHERE user_id = ?`, [req.auth_id]);
    await db.dbUpdate("UPDATE notifications SET is_read = 1 WHERE user_id = ?",[req.auth_id]);
    res.render('notification/list', {title: 'Bildirimlerim', notifications: notifications});
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


router.post('/add', async (req, res) => {
    await db.dbInsert(`INSERT INTO users (username, password, user_role)
                       VALUES (?, ?, ?)`, [req.body.username, req.body.password, req.body.userRole])

    res.resultOkRedirect("Başarıyla eklendi.", "/user/list")
});


module.exports = router;
