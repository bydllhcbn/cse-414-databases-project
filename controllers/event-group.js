let express = require('express');
let router = express.Router();
let db = require('../db');

router.get('/', async (req, res) => {
    res.send('respond with a resource');
});


router.get('/list', async (req, res) => {
    let events  = [];
    if (req.auth_type == 'ADMIN') {
        events = await db.db(`
            SELECT event_group.id, event_name, category_id, created_at, updated_at, event_categories.category_name
            FROM event_group
                     INNER JOIN event_categories ON event_group.category_id = event_categories.id
        `, []);
    } else {
        events = await db.db(`
            SELECT event_group.id, event_name, category_id, created_at, updated_at, event_categories.category_name
            FROM event_group
                     INNER JOIN event_categories ON event_group.category_id = event_categories.id
            WHERE event_group.organizator_id = ?
        `, [req.auth_id]);
    }


    res.render('event-group/list', {title: 'Etkinlik Grupları', events: events});
});

router.get('/add', async (req, res) => {
    let cities = await db.db("SELECT id, city_name, country_id FROM place_cities")
    let categories = await db.db("SELECT id, category_name FROM event_categories")
    res.render('event-group/add', {title: 'Etkinlik Grubu Ekle', cities: cities, categories: categories});
});


router.get('/edit/:id', async (req, res) => {
    let cities = await db.db("SELECT id, city_name, country_id FROM place_cities")
    let categories = await db.db("SELECT id, category_name FROM event_categories")
    let eventGroup = await db.dbGetFirst(`
        SELECT id, event_name, event_description, category_id, created_at, updated_at
        FROM event_group
        WHERE id = ?`, [req.params.id]);
    let events = await db.db(`SELECT events.id,
                                     place_id,
                                     LEFT(start_date, 10) as start_date,
                                     LEFT(end_date, 10)   as end_date,
                                     p.place_name
                              FROM events
                                       INNER JOIN places p on events.place_id = p.id
                              WHERE event_group_id = ?`, [req.params.id]);

    let images = await db.db(`SELECT id, event_group_id, photo_url
                              FROM event_gallery
                              WHERE event_group_id = ?`, [eventGroup.id]);

    let actors = await db.db(`SELECT actors.id,
                                     actors.name,
                                     (SELECT actor_id
                                      FROM actor_events
                                      WHERE event_group_id = ?
                                        AND actor_id = actors.id) IS NOT NULL as selected
                              FROM actors`, [eventGroup.id]);

    let musics = await db.db(`SELECT musics.id,
                                     musics.name,
                                     (SELECT music_id
                                      FROM music_events
                                      WHERE event_group_id = ?
                                        AND music_id = musics.id) IS NOT NULL as selected
                              FROM musics`, [eventGroup.id]);
    let movies = await db.db(`SELECT movies.id,
                                     movies.name,
                                     (SELECT movie_id
                                      FROM movie_events
                                      WHERE event_group_id = ?
                                        AND movie_id = movies.id) IS NOT NULL as selected
                              FROM movies`, [eventGroup.id]);
    res.render('event-group/edit', {
        title: 'Etkinlik Grubunu Düzenle',
        cities: cities,
        categories: categories,
        events: events,
        images: images,
        actors: actors,
        musics: musics,
        movies: movies,
        eventGroup: eventGroup
    });
});


router.get('/view/:id', async (req, res) => {
    let cities = await db.db("SELECT id, city_name, country_id FROM place_cities")
    let categories = await db.db("SELECT id, category_name FROM event_categories")
    let eventGroup = await db.dbGetFirst(`
        SELECT id, event_name, event_description, category_id, created_at, updated_at
        FROM event_group
        WHERE id = ?`, [req.params.id]);
    let events = await db.db(`SELECT events.id,
                                     place_id,
                                     LEFT(start_date, 10) as start_date,
                                     LEFT(end_date, 10)   as end_date,
                                     p.place_name
                              FROM events
                                       INNER JOIN places p on events.place_id = p.id
                              WHERE event_group_id = ?`, [req.params.id]);

    let images = await db.db(`SELECT id, event_group_id, photo_url
                              FROM event_gallery
                              WHERE event_group_id = ?`, [eventGroup.id]);

    let actors = await db.db(`SELECT actors.id,
                                     actors.name
                              FROM actors
                                       INNER JOIN actor_events ae on actors.id = ae.actor_id
                              WHERE ae.event_group_id = ?`, [eventGroup.id]);

    let musics = await db.db(`SELECT musics.id,
                                     musics.name
                              FROM musics
                                       INNER JOIN music_events me on musics.id = me.music_id
                              WHERE me.event_group_id = ?`, [eventGroup.id]);

    let movies = await db.db(`SELECT movies.id,
                                     movies.name

                              FROM movies
                                       INNER JOIN movie_events me on movies.id = me.movie_id
                              WHERE me.event_group_id = ?`, [eventGroup.id]);
    res.render('event-group/view', {
        title: 'Etkinlik Detayı',
        cities: cities,
        categories: categories,
        events: events,
        images: images,
        actors: actors,
        musics: musics,
        movies: movies,
        eventGroup: eventGroup
    });
});


router.post('/add', async (req, res) => {
    let user = null;
    if (req.auth_type === 'ORGANIZATOR') {
        user = req.auth_id;
    }
    let id = await db.dbInsert(`INSERT INTO event_group (event_name, category_id, event_description, organizator_id)
                                VALUES (?, ?, ?, ?)`, [
        req.body.name, req.body.category, req.body.description, user
    ]);


    res.resultOkRedirect("Başarıyla eklendi.", "/event-group/list");
});

router.post('/edit', async (req, res) => {
    let transaction = await db.startTransaction();
    if (!transaction) {
        res.resultError("Bir hata oluştu.");
        return;
    }
    try{
        await db.dbUpdate("UPDATE event_group SET event_name = ?,category_id = ?,event_description=? WHERE id = ?",
        [req.body.name, req.body.category, req.body.description, req.body.id]);

    await db.dbUpdate("DELETE FROM actor_events WHERE event_group_id = ?", [req.body.id]);
    await db.dbUpdate("DELETE FROM music_events WHERE event_group_id = ?", [req.body.id]);
    await db.dbUpdate("DELETE FROM movie_events WHERE event_group_id = ?", [req.body.id]);
    if (req.body.actors) {
        for (let it of req.body.actors) {
            await db.dbInsert("INSERT INTO actor_events (event_group_id, actor_id) VALUES  (?,?)",
                [req.body.id, it])
        }
    }
    if (req.body.musics) {
        for (let it of req.body.musics) {
            await db.dbInsert("INSERT INTO music_events (event_group_id, music_id) VALUES  (?,?)",
                [req.body.id, it])
        }
    }
    if (req.body.movies) {
        for (let it of req.body.movies) {
            await db.dbInsert("INSERT INTO movie_events (event_group_id, movie_id) VALUES  (?,?)",
                [req.body.id, it])
        }
    }
    }catch (e) {
        await db.rollbackTransaction();
    }

    await db.commitTransaction();
    res.resultOkReload("Başarıyla güncellendi.");
});

router.post('/addImage', async (req, res) => {

    await db.dbInsert("INSERT INTO event_gallery (event_group_id, photo_url) VALUES (?,?)",
        [req.body.eventGroupId, req.body.url]);
    res.resultOkReload("Başarıyla eklendi.");
});
router.post('/deletePhoto', async (req, res) => {
    await db.dbInsert("DELETE FROM event_gallery WHERE id = ?", [req.body.id]);
    res.resultOkReload("Başarıyla silindi.");
});


module.exports = router;
