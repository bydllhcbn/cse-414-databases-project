SET AUTOCOMMIT = 0;
START TRANSACTION;


DROP DATABASE IF EXISTS `ticket`;
CREATE DATABASE IF NOT EXISTS `ticket` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `ticket`;


CREATE TABLE `active_event_groups` (
`id` int(11) unsigned
,`event_name` varchar(255)
,`event_description` text
,`category_id` int(11) unsigned
,`photo_url` varchar(255)
,`next_event_date` datetime
,`category_name` varchar(255)
);

CREATE TABLE `active_users` (
`id` int(11) unsigned
,`username` varchar(127)
,`name` varchar(255)
,`password` varchar(127)
,`user_role` set('NORMAL','ADMIN','ORGANIZATOR','PLACE_OWNER','ACTOR')
,`created_at` timestamp
,`updated_at` timestamp
,`totalTickets` bigint(21)
,`totalPrice` decimal(32,2)
);

CREATE TABLE `actors` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `actor_events` (
  `actor_id` int(11) UNSIGNED NOT NULL,
  `event_group_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `available_tickets` (
`event_id` int(11) unsigned
,`seat_id` int(11) unsigned
,`event_name` varchar(255)
,`place_name` varchar(255)
,`section_name` varchar(255)
,`seat_number` varchar(10)
);

CREATE TABLE `campaigns` (
  `id` int(10) UNSIGNED NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `discount` tinyint(4) NOT NULL,
  `title` varchar(255) NOT NULL,
  `event_category_id` int(11) UNSIGNED DEFAULT NULL,
  `place_id` int(11) UNSIGNED DEFAULT NULL,
  `event_group_id` int(11) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `campaign_events` (
`id` int(11) unsigned
,`place_id` int(11) unsigned
,`event_group_id` int(11) unsigned
,`start_date` datetime
,`end_date` datetime
,`is_published` tinyint(4)
,`created_at` timestamp
,`updated_at` timestamp
,`discount` tinyint(4)
,`campaign_id` int(10) unsigned
);

CREATE TABLE `events` (
  `id` int(11) UNSIGNED NOT NULL,
  `place_id` int(11) UNSIGNED NOT NULL,
  `event_group_id` int(11) UNSIGNED NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `is_published` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `event_categories` (
  `id` int(11) UNSIGNED NOT NULL,
  `category_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO `event_categories` (`id`, `category_name`) VALUES
(1, 'Müzik'),
(2, 'Tiyatro'),
(3, 'Film'),
(4, 'Sahne'),
(5, 'Spor'),
(6, 'Eğitim'),
(7, 'Müze');


CREATE TABLE `event_gallery` (
  `id` int(11) UNSIGNED NOT NULL,
  `event_group_id` int(11) UNSIGNED NOT NULL,
  `photo_url` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `event_group` (
  `id` int(11) UNSIGNED NOT NULL,
  `event_name` varchar(255) NOT NULL,
  `event_description` text NOT NULL DEFAULT '',
  `category_id` int(11) UNSIGNED NOT NULL,
  `organizator_id` int(11) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `event_price_update_log` (
  `event_id` int(11) UNSIGNED NOT NULL,
  `seat_section_id` int(11) UNSIGNED NOT NULL,
  `old_price` decimal(10,2) NOT NULL,
  `new_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `event_reserved_seat` (
  `event_id` int(11) UNSIGNED NOT NULL,
  `seat_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `event_rules` (
  `event_id` int(11) UNSIGNED NOT NULL,
  `rule` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `movies` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `movie_events` (
  `movie_id` int(11) UNSIGNED NOT NULL,
  `event_group_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `musics` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `music_events` (
  `music_id` int(11) UNSIGNED NOT NULL,
  `event_group_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `notifications` (
  `id` int(11) UNSIGNED NOT NULL,
  `text` text NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `places` (
  `id` int(11) UNSIGNED NOT NULL,
  `city_id` int(11) UNSIGNED NOT NULL,
  `owner_id` int(11) UNSIGNED DEFAULT NULL,
  `place_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `place_allowed_categories` (
  `place_id` int(11) UNSIGNED NOT NULL,
  `event_category_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `place_cities` (
  `id` int(11) UNSIGNED NOT NULL,
  `city_name` varchar(255) NOT NULL,
  `country_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `place_cities` (`id`, `city_name`, `country_id`) VALUES
(1, 'ADANA', 1),
(2, 'ADIYAMAN', 1),
(3, 'AFYONKARAHİSAR', 1),
(4, 'AĞRI', 1),
(5, 'AKSARAY', 1),
(6, 'AMASYA', 1),
(7, 'ANKARA', 1),
(8, 'ANTALYA', 1),
(9, 'ARDAHAN', 1),
(10, 'ARTVİN', 1),
(11, 'AYDIN', 1),
(12, 'BALIKESİR', 1),
(13, 'BARTIN', 1),
(14, 'BATMAN', 1),
(15, 'BAYBURT', 1),
(16, 'BİLECİK', 1),
(17, 'BİNGÖL', 1),
(18, 'BİTLİS', 1),
(19, 'BOLU', 1),
(20, 'BURDUR', 1),
(21, 'BURSA', 1),
(22, 'ÇANAKKALE', 1),
(23, 'ÇANKIRI', 1),
(24, 'ÇORUM', 1),
(25, 'DENİZLİ', 1),
(26, 'DİYARBAKIR', 1),
(27, 'DÜZCE', 1),
(28, 'EDİRNE', 1),
(29, 'ELAZIĞ', 1),
(30, 'ERZİNCAN', 1),
(31, 'ERZURUM', 1),
(32, 'ESKİŞEHİR', 1),
(33, 'GAZİANTEP', 1),
(34, 'GİRESUN', 1),
(35, 'GÜMÜŞHANE', 1),
(36, 'HAKKARİ', 1),
(37, 'HATAY', 1),
(38, 'IĞDIR', 1),
(39, 'ISPARTA', 1),
(40, 'İSTANBUL', 1),
(41, 'İZMİR', 1),
(42, 'KAHRAMANMARAŞ', 1),
(43, 'KARABÜK', 1),
(44, 'KARAMAN', 1),
(45, 'KARS', 1),
(46, 'KASTAMONU', 1),
(47, 'KAYSERİ', 1),
(48, 'KIRIKKALE', 1),
(49, 'KIRKLARELİ', 1),
(50, 'KIRŞEHİR', 1),
(51, 'KİLİS', 1),
(52, 'KOCAELİ', 1),
(53, 'KONYA', 1),
(54, 'KÜTAHYA', 1),
(55, 'MALATYA', 1),
(56, 'MANİSA', 1),
(57, 'MARDİN', 1),
(58, 'MERSİN', 1),
(59, 'MUĞLA', 1),
(60, 'MUŞ', 1),
(61, 'NEVŞEHİR', 1),
(62, 'NİĞDE', 1),
(63, 'ORDU', 1),
(64, 'OSMANİYE', 1),
(65, 'RİZE', 1),
(66, 'SAKARYA', 1),
(67, 'SAMSUN', 1),
(68, 'SİİRT', 1),
(69, 'SİNOP', 1),
(70, 'SİVAS', 1),
(71, 'ŞANLIURFA', 1),
(72, 'ŞIRNAK', 1),
(73, 'TEKİRDAĞ', 1),
(74, 'TOKAT', 1),
(75, 'TRABZON', 1),
(76, 'TUNCELİ', 1),
(77, 'UŞAK', 1),
(78, 'VAN', 1),
(79, 'YALOVA', 1),
(80, 'YOZGAT', 1),
(81, 'ZONGULDAK', 1);


CREATE TABLE `place_countries` (
  `id` int(11) UNSIGNED NOT NULL,
  `country_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `place_countries` (`id`, `country_name`) VALUES
(1, 'Türkiye');

CREATE TABLE `place_income` (
`id` int(11) unsigned
,`city_id` int(11) unsigned
,`owner_id` int(11) unsigned
,`place_name` varchar(255)
,`total_price` decimal(32,2)
,`total_tickets` bigint(21)
);


CREATE TABLE `seats` (
  `id` int(11) UNSIGNED NOT NULL,
  `seat_section_id` int(11) UNSIGNED NOT NULL,
  `seat_number` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `seat_income` (
`id` int(11) unsigned
,`seat_section_id` int(11) unsigned
,`seat_number` varchar(10)
,`place_id` int(11) unsigned
,`owner_id` int(11) unsigned
,`city_id` int(11) unsigned
,`total_price` decimal(32,2)
,`total_tickets` bigint(21)
);


CREATE TABLE `seat_prices` (
  `seat_section_id` int(11) UNSIGNED NOT NULL,
  `event_id` int(11) UNSIGNED NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `seat_sections` (
  `id` int(11) UNSIGNED NOT NULL,
  `place_id` int(11) UNSIGNED NOT NULL,
  `section_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sold_tickets` (
`id` int(11) unsigned
,`ticket_category_id` int(11) unsigned
,`event_id` int(11) unsigned
,`seat_id` int(11) unsigned
,`sold_user_id` int(11) unsigned
,`created_at` timestamp
,`updated_at` timestamp
,`price` decimal(10,2)
,`place_name` varchar(255)
,`place_id` int(11) unsigned
,`city_id` int(11) unsigned
,`section_name` varchar(255)
,`seat_number` varchar(10)
,`organizator_id` int(11) unsigned
,`category_id` int(11) unsigned
,`username` varchar(127)
);

CREATE TABLE `theater_plays` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `event_group_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `tickets` (
  `id` int(11) UNSIGNED NOT NULL,
  `ticket_category_id` int(11) UNSIGNED NOT NULL,
  `event_id` int(11) UNSIGNED NOT NULL,
  `seat_id` int(11) UNSIGNED NOT NULL,
  `sold_user_id` int(11) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `price` decimal(10,2) DEFAULT 0.00,
  `discount` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




CREATE TABLE `ticket_categories` (
  `id` int(11) UNSIGNED NOT NULL,
  `category_name` varchar(255) NOT NULL,
  `discount` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO `ticket_categories` (`id`, `category_name`, `discount`) VALUES
(2, 'Yetişkin', 0),
(3, 'Öğrenci', 50);

CREATE TABLE `users` (
  `id` int(11) UNSIGNED NOT NULL,
  `username` varchar(127) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(127) NOT NULL,
  `user_role` set('NORMAL','ADMIN','ORGANIZATOR','PLACE_OWNER','ACTOR') NOT NULL DEFAULT 'NORMAL',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `users` (`id`, `username`, `name`, `password`, `user_role`, `created_at`, `updated_at`) VALUES
(1, 'test', '', 'test', 'ADMIN', '2020-06-19 17:55:03', '2020-06-19 17:55:03'),
(5, 'testsanat', '', 'test', 'ACTOR', '2020-06-19 18:31:40', '2020-07-06 22:05:39'),
(6, 'admin', '', 'test', 'ADMIN', '2020-06-20 09:39:44', '2020-07-06 22:05:39'),
(7, 'user', '', 'test', 'NORMAL', '2020-06-20 11:26:50', '2020-07-06 22:05:39'),
(8, 'organizer', '', 'test', 'ORGANIZATOR', '2020-06-20 23:07:27', '2020-07-06 22:05:50'),
(9, 'mekan', '', 'test', 'PLACE_OWNER', '2020-06-20 23:36:27', '2020-06-20 23:36:27');


ALTER TABLE `actors`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `actor_events`
  ADD PRIMARY KEY (`actor_id`,`event_group_id`),
  ADD KEY `actor_events_event_group` (`event_group_id`);

ALTER TABLE `campaigns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `campaign_event_category` (`event_category_id`),
  ADD KEY `campaign_place` (`place_id`),
  ADD KEY `campaign_event_group` (`event_group_id`);


ALTER TABLE `events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_event_group` (`event_group_id`),
  ADD KEY `event_place` (`place_id`);

ALTER TABLE `event_categories`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `event_gallery`
  ADD PRIMARY KEY (`id`),
  ADD KEY `gallery_event_group` (`event_group_id`);

ALTER TABLE `event_group`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_group_category` (`category_id`),
  ADD KEY `organizator` (`organizator_id`);

ALTER TABLE `event_reserved_seat`
  ADD PRIMARY KEY (`event_id`,`seat_id`),
  ADD KEY `reserved_seat` (`seat_id`);


ALTER TABLE `event_rules`
  ADD KEY `rule_event` (`event_id`);

ALTER TABLE `movies`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `movie_events`
  ADD PRIMARY KEY (`movie_id`,`event_group_id`),
  ADD KEY `movie_event_event` (`event_group_id`);

ALTER TABLE `musics`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `music_events`
  ADD PRIMARY KEY (`music_id`,`event_group_id`),
  ADD KEY `music_event_group` (`event_group_id`);

ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `places`
  ADD PRIMARY KEY (`id`),
  ADD KEY `place_city` (`city_id`),
  ADD KEY `place_owner` (`owner_id`);

ALTER TABLE `place_allowed_categories`
  ADD PRIMARY KEY (`place_id`,`event_category_id`),
  ADD KEY `allowed_category` (`event_category_id`);

ALTER TABLE `place_cities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `city_country` (`country_id`);

ALTER TABLE `place_countries`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `seats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seat_seat_section` (`seat_section_id`);

ALTER TABLE `seat_prices`
  ADD PRIMARY KEY (`seat_section_id`,`event_id`),
  ADD KEY `price_event` (`event_id`);

ALTER TABLE `seat_sections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seat_section_place` (`place_id`);

ALTER TABLE `theater_plays`
  ADD PRIMARY KEY (`id`),
  ADD KEY `theater_event_group` (`event_group_id`);

ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ticket_event` (`event_id`),
  ADD KEY `ticket_sold_user` (`sold_user_id`),
  ADD KEY `ticket_ticket_category` (`ticket_category_id`),
  ADD KEY `ticket_seat` (`seat_id`);

ALTER TABLE `ticket_categories`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `actors`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `campaigns`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `events`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `event_categories`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

ALTER TABLE `event_gallery`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `event_group`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `movies`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `musics`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `notifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `places`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `seats`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `seat_sections`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `theater_plays`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `tickets`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `ticket_categories`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

ALTER TABLE `users`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

ALTER TABLE `actor_events`
  ADD CONSTRAINT `actor_events_actor` FOREIGN KEY (`actor_id`) REFERENCES `actors` (`id`),
  ADD CONSTRAINT `actor_events_event_group` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`);

ALTER TABLE `campaigns`
  ADD CONSTRAINT `campaign_event_category` FOREIGN KEY (`event_category_id`) REFERENCES `event_categories` (`id`),
  ADD CONSTRAINT `campaign_event_group` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`),
  ADD CONSTRAINT `campaign_place` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`);

ALTER TABLE `events`
  ADD CONSTRAINT `event_event_group` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`),
  ADD CONSTRAINT `event_place` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`);

ALTER TABLE `event_gallery`
  ADD CONSTRAINT `gallery_event_group` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`);

ALTER TABLE `event_group`
  ADD CONSTRAINT `event_group_category` FOREIGN KEY (`category_id`) REFERENCES `event_categories` (`id`),
  ADD CONSTRAINT `organizator` FOREIGN KEY (`organizator_id`) REFERENCES `users` (`id`);

ALTER TABLE `event_reserved_seat`
  ADD CONSTRAINT `reserved_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`),
  ADD CONSTRAINT `reserved_seat` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`);

ALTER TABLE `event_rules`
  ADD CONSTRAINT `rule_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`);

ALTER TABLE `movie_events`
  ADD CONSTRAINT `movie_event_event_c` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`),
  ADD CONSTRAINT `movie_event_movie_c` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`);

ALTER TABLE `music_events`
  ADD CONSTRAINT `music_event_group` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`),
  ADD CONSTRAINT `music_music` FOREIGN KEY (`music_id`) REFERENCES `musics` (`id`);

ALTER TABLE `places`
  ADD CONSTRAINT `place_city` FOREIGN KEY (`city_id`) REFERENCES `place_cities` (`id`),
  ADD CONSTRAINT `place_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`);

ALTER TABLE `place_allowed_categories`
  ADD CONSTRAINT `allowed_category` FOREIGN KEY (`event_category_id`) REFERENCES `event_categories` (`id`),
  ADD CONSTRAINT `allowed_event_place` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`);

ALTER TABLE `place_cities`
  ADD CONSTRAINT `city_country` FOREIGN KEY (`country_id`) REFERENCES `place_countries` (`id`);

ALTER TABLE `seats`
  ADD CONSTRAINT `seat_seat_section` FOREIGN KEY (`seat_section_id`) REFERENCES `seat_sections` (`id`);

ALTER TABLE `seat_prices`
  ADD CONSTRAINT `price_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`),
  ADD CONSTRAINT `price_seat_section` FOREIGN KEY (`seat_section_id`) REFERENCES `seat_sections` (`id`);

ALTER TABLE `seat_sections`
  ADD CONSTRAINT `seat_section_place` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`);

ALTER TABLE `theater_plays`
  ADD CONSTRAINT `theater_event_group` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`);

ALTER TABLE `tickets`
  ADD CONSTRAINT `ticket_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`),
  ADD CONSTRAINT `ticket_seat` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`),
  ADD CONSTRAINT `ticket_sold_user` FOREIGN KEY (`sold_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `ticket_ticket_category` FOREIGN KEY (`ticket_category_id`) REFERENCES `ticket_categories` (`id`);










DROP TABLE IF EXISTS `active_event_groups`;
CREATE VIEW `active_event_groups` AS
select `event_group`.`id`                AS `id`,
       `event_group`.`event_name`        AS `event_name`,
       `event_group`.`event_description` AS `event_description`,
       `event_group`.`category_id`       AS `category_id`,
       (select `event_gallery`.`photo_url`
        from `event_gallery`
        where `event_gallery`.`event_group_id` = `event_group`.`id`
        limit 1)                         AS `photo_url`,
       (select `events`.`start_date`
        from `events`
        where `events`.`event_group_id` = `event_group`.`id`
          and `events`.`start_date` > curdate()
        order by `events`.`start_date`
        limit 1)                         AS `next_event_date`,
       `ec`.`category_name`              AS `category_name`
from (`event_group`
         join `event_categories` `ec` on (`event_group`.`category_id` = `ec`.`id`))
having `next_event_date` is not null;

DROP TABLE IF EXISTS `active_users`;

CREATE VIEW `active_users` AS
select `users`.`id`         AS `id`,
       `users`.`username`   AS `username`,
       `users`.`name`       AS `name`,
       `users`.`password`   AS `password`,
       `users`.`user_role`  AS `user_role`,
       `users`.`created_at` AS `created_at`,
       `users`.`updated_at` AS `updated_at`,
       count(0)             AS `totalTickets`,
       sum(`t`.`price`)     AS `totalPrice`
from (`users`
         join `tickets` `t` on (`users`.`id` = `t`.`sold_user_id`))
where `users`.`user_role` = 'NORMAL'
group by `users`.`id`;


DROP TABLE IF EXISTS `available_tickets`;
CREATE VIEW `available_tickets` AS
select `events`.`id`       AS `event_id`,
       `s`.`id`            AS `seat_id`,
       `eg`.`event_name`   AS `event_name`,
       `p`.`place_name`    AS `place_name`,
       `ss`.`section_name` AS `section_name`,
       `s`.`seat_number`   AS `seat_number`
from ((((((`events` join `event_group` `eg` on (`events`.`event_group_id` = `eg`.`id`)) join `places` `p` on (`events`.`place_id` = `p`.`id`)) join `seat_sections` `ss` on (`p`.`id` = `ss`.`place_id`)) join `seats` `s` on (`ss`.`id` = `s`.`seat_section_id`)) left join `event_reserved_seat` `ers` on (`events`.`id` = `ers`.`event_id` and `ers`.`seat_id` = `s`.`id`))
         left join `tickets` `t` on (`events`.`id` = `t`.`event_id` and `t`.`seat_id` = `s`.`id`))
where `ers`.`seat_id` is null
  and `t`.`id` is null;


DROP TABLE IF EXISTS `campaign_events`;
CREATE  VIEW `campaign_events` AS
select `events`.`id`             AS `id`,
       `events`.`place_id`       AS `place_id`,
       `events`.`event_group_id` AS `event_group_id`,
       `events`.`start_date`     AS `start_date`,
       `events`.`end_date`       AS `end_date`,
       `events`.`is_published`   AS `is_published`,
       `events`.`created_at`     AS `created_at`,
       `events`.`updated_at`     AS `updated_at`,
       `c`.`discount`            AS `discount`,
       `c`.`id`                  AS `campaign_id`
from ((`events` join `event_group` `eg` on (`events`.`event_group_id` = `eg`.`id`))
         join `campaigns` `c` on (`eg`.`id` = `c`.`event_group_id` or `events`.`place_id` = `c`.`place_id` or
                                  `eg`.`category_id` = `c`.`event_category_id`))
where `c`.`start_date` < current_timestamp()
  and `c`.`end_date` > current_timestamp()
  and `events`.`start_date` > current_timestamp();


DROP TABLE IF EXISTS `place_income`;
CREATE VIEW `place_income` AS
select `p`.`id`               AS `id`,
       `p`.`city_id`          AS `city_id`,
       `p`.`owner_id`         AS `owner_id`,
       `p`.`place_name`       AS `place_name`,
       sum(`tickets`.`price`) AS `total_price`,
       count(0)               AS `total_tickets`
from (((`tickets` join `seats` `s` on (`tickets`.`seat_id` = `s`.`id`)) join `seat_sections` `ss` on (`s`.`seat_section_id` = `ss`.`id`))
         join `places` `p` on (`ss`.`place_id` = `p`.`id`))
group by `p`.`id`;


DROP TABLE IF EXISTS `seat_income`;
CREATE VIEW `seat_income` AS
select `s`.`id`               AS `id`,
       `s`.`seat_section_id`  AS `seat_section_id`,
       `s`.`seat_number`      AS `seat_number`,
       `p`.`id`               AS `place_id`,
       `p`.`owner_id`         AS `owner_id`,
       `p`.`city_id`          AS `city_id`,
       sum(`tickets`.`price`) AS `total_price`,
       count(0)               AS `total_tickets`
from (((`tickets` join `seats` `s` on (`tickets`.`seat_id` = `s`.`id`)) join `seat_sections` `ss` on (`s`.`seat_section_id` = `ss`.`id`))
         join `places` `p` on (`ss`.`place_id` = `p`.`id`))
group by `s`.`id`;

DROP TABLE IF EXISTS `sold_tickets`;
CREATE VIEW `sold_tickets` AS
select `tickets`.`id`                 AS `id`,
       `tickets`.`ticket_category_id` AS `ticket_category_id`,
       `tickets`.`event_id`           AS `event_id`,
       `tickets`.`seat_id`            AS `seat_id`,
       `tickets`.`sold_user_id`       AS `sold_user_id`,
       `tickets`.`created_at`         AS `created_at`,
       `tickets`.`updated_at`         AS `updated_at`,
       `tickets`.`price`              AS `price`,
       `p`.`place_name`               AS `place_name`,
       `p`.`id`                       AS `place_id`,
       `p`.`city_id`                  AS `city_id`,
       `ss`.`section_name`            AS `section_name`,
       `s`.`seat_number`              AS `seat_number`,
       `eg`.`organizator_id`          AS `organizator_id`,
       `eg`.`category_id`             AS `category_id`,
       `u`.`username`                 AS `username`
from ((((((`tickets` join `seats` `s` on (`tickets`.`seat_id` = `s`.`id`)) join `seat_sections` `ss` on (`s`.`seat_section_id` = `ss`.`id`)) join `users` `u` on (`tickets`.`sold_user_id` = `u`.`id`)) join `places` `p` on (`ss`.`place_id` = `p`.`id`)) join `events` `e` on (`tickets`.`event_id` = `e`.`id`))
         join `event_group` `eg` on (`e`.`event_group_id` = `eg`.`id`));



DELIMITER $$
CREATE TRIGGER `fix_event_dates` BEFORE INSERT ON `events` FOR EACH ROW BEGIN

     IF NEW.start_date < CURRENT_TIMESTAMP THEN
        SET NEW.start_date = CURRENT_TIMESTAMP;
    END IF;
     IF NEW.end_date < NEW.start_date THEN
        SET NEW.end_date = NEW.start_date;
    END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `notify_place_owner` BEFORE INSERT ON `events` FOR EACH ROW BEGIN
    SET @owner_id := (SELECT owner_id FROM places WHERE id = NEW.place_id);
    SET @place_name := (SELECT places.place_name FROM places WHERE id = NEW.place_id);
    IF @owner_id IS NOT NULL THEN
        INSERT INTO notifications (text, user_id) VALUES (CONCAT(@place_name,' adlı mekanınızda yeni bir etkinlik var.'),@owner_id);
    end if ;

END
$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER `event_price_log` BEFORE UPDATE ON `seat_prices` FOR EACH ROW BEGIN
    IF OLD.price != NEW.price THEN
        INSERT INTO event_price_update_log (event_id, old_price, new_price, seat_section_id)
        VALUES (NEW.event_id, OLD.price, NEW.price, NEW.seat_section_id);
    END IF;
END
$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER `publish_on_prices_updated` AFTER INSERT ON `seat_prices` FOR EACH ROW BEGIN
    UPDATE events SET is_published = 1 WHERE id = NEW.event_id;
END
$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER `buy_ticket` BEFORE INSERT ON `tickets` FOR EACH ROW BEGIN

    SET NEW.price = (SELECT price
                 FROM seat_prices sp
                 WHERE sp.event_id = NEW.event_id
                   AND sp.seat_section_id = (SELECT seat_section_id FROM seats WHERE seats.id = NEW.seat_id));
END
$$
DELIMITER ;

COMMIT;
