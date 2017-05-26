START TRANSACTION;
INSERT INTO `user` (`first_name`, `last_name`, `email`, `language_id`, `who_id`) VALUES
    ('John', 'Doe', 'jd@example.com', (SELECT `id` FROM `language` WHERE `locale` = 'en-us'), 1);
ROLLBACK;
