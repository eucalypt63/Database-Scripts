-- 2. Создать кэширующее представление, позволяющее получать список всех книг и их жанров 
-- Создание таблицы 
DROP TABLE IF EXISTS `books_genres`;
CREATE TABLE `books_genres`
(
	`book` varchar(150) NOT NULL,
    `genres` varchar(150) NOT NULL
);
TRUNCATE TABLE `books_genres`;

-- Заполнение таблицы
INSERT INTO `books_genres` (`book`, `genres`)
SELECT `b`.`b_name` AS `book_name`, GROUP_CONCAT(`g`.`g_name` SEPARATOR ', ') AS `genres`
FROM `books` `b`
JOIN `m2m_books_genres` `m2m` ON `b`.`b_id` = `m2m`.`b_id`
JOIN `genres` `g` ON `m2m`.`g_id` = `g`.`g_id`
GROUP BY `b`.`b_id`;

-- Создание тригеров
-- Добавление книги
DROP TRIGGER IF EXISTS `upd_book_genres_ins_books`;
DELIMITER $$
CREATE TRIGGER `upd_book_genres_ins_books` 
BEFORE INSERT
ON `books`
FOR EACH ROW
BEGIN
    INSERT INTO `books_genres` (`book`, `genres`)
    VALUES (NEW.`b_name`, '');
END;
$$
DELIMITER ;

-- Удаление книги
DROP TRIGGER  IF EXISTS `upd_book_genres_del_books`;
DELIMITER $$
CREATE TRIGGER `upd_book_genres_del_books` 
AFTER DELETE
ON `books`
FOR EACH ROW
BEGIN
    DELETE FROM `books_genres`
    WHERE `book` = OLD.`b_name`;
END;
$$
DELIMITER ;

-- Добавление зависимости книги и жанра
DROP TRIGGER  IF EXISTS `upd_book_genres_ins_m2m`;
DELIMITER $$
CREATE TRIGGER `upd_book_genres_ins_m2m` 
BEFORE INSERT
ON `m2m_books_genres`
FOR EACH ROW
BEGIN
    UPDATE `books_genres`
    SET `genres` = CONCAT(`genres`, ',', (SELECT `g_name` FROM `genres` WHERE `g_id` = NEW.`g_id`))
    WHERE `book` = (SELECT `b_name` FROM `books` WHERE `b_id` = NEW.`b_id`);
END;
$$
DELIMITER ;

-- Удаление зависимости книги и жанра
DROP TRIGGER  IF EXISTS `upd_book_genres_del_m2m`;
DELIMITER $$
CREATE TRIGGER `upd_book_genres_del_m2m` 
AFTER DELETE
ON `m2m_books_genres`
FOR EACH ROW
BEGIN
    UPDATE `books_genres`
    SET `genres` = REPLACE(`genres`, CONCAT((SELECT `g_name` FROM `genres` WHERE `g_id` = OLD.`g_id`), ','), '')
    WHERE `book` = (SELECT `b_name` FROM `books` WHERE `b_id` = OLD.`b_id`);
END;
$$
DELIMITER ;

-- Вызов таблицы
SELECT * FROM `books_genres`;

-- --------------------------------------------------------------------------------------------

-- 1. Создать представление, позволяющее получать список читателей с количеством находящихся у каждого читателя на руках книг, но отображающее только таких читателей, по которым имеются задолженности
CREATE OR REPLACE VIEW `overdue_subscribers` AS
SELECT `s`.`s_id` AS `subscriber_id`, `s`.`s_name` AS `subscriber_name`, COUNT(*) AS `overdue_books_count`
FROM `subscribers` `s`
JOIN `subscriptions` `sub` ON `s`.`s_id` = `sub`.`sb_subscriber`
JOIN `books` `b` ON `sub`.`sb_book` = `b`.`b_id`
WHERE `sub`.`sb_finish` < CURDATE() AND `sub`.`sb_is_active` = 'Y'
GROUP BY `s`.`s_id`;

-- Вызов представления
SELECT * FROM `overdue_subscribers`;

-- --------------------------------------------------------------------------------------------

-- 5. Создать представление, возвращающее всю информацию из таблицы subscriptions, преобразуя даты из полей sb_start и sb_finish в формат «ГГГГ-ММ-ДД НН», где «НН» – день недели в виде своего полного названия
CREATE OR REPLACE VIEW `subscriptions_view` AS
SELECT `sb_id` as `subscriber_id`, `sb_subscriber` as `subscriber_nama`, `sb_book` as `subscriber_book`,
    CONCAT(DATE_FORMAT(`sb_start`, '%Y-%m-%d'), ' ', DAYNAME(`sb_start`)),
    CONCAT(DATE_FORMAT(`sb_finish`, '%Y-%m-%d'), ' ', DAYNAME(`sb_finish`)),
    `sb_is_active`
FROM `subscriptions`;
SELECT * FROM `subscriptions_view`;

-- ---------------------------------------------------------------------------------------------
-- 9. Создать представление, показывающее список книг с их авторами, и при этом позволяющее добавлять новых авторов.
-- Создание таблицы 
DROP TABLE IF EXISTS `authors_books`;
-- Создание таблицы
CREATE TABLE `authors_books`
(
	`author` varchar(150) NOT NULL,
	`book` varchar(150) NOT NULL
);
TRUNCATE TABLE `authors_books`;

-- Заполнение таблицы
INSERT INTO `authors_books` (`author`, `book`)
SELECT `a`.`a_name` AS `author_name`, GROUP_CONCAT(`b`.`b_name` SEPARATOR ', ') AS `books`
FROM `authors` `a`
JOIN `m2m_books_authors` `m2m` ON `a`.`a_id` = `m2m`.`a_id`
JOIN `books` `b` ON `m2m`.`b_id` = `b`.`b_id`
GROUP BY `a`.`a_name`;

-- Создание тригеров
-- Добавление книги
DROP TRIGGER IF EXISTS `upd_authors_books_ins_authors`;
DELIMITER $$
CREATE TRIGGER `upd_authors_books_ins_authors` 
BEFORE INSERT
ON `authors`
FOR EACH ROW
BEGIN
    INSERT INTO `authors_books` (`author`, `book`)
    VALUES (NEW.`a_name`, '');
END;
$$
DELIMITER ;

-- Удаление книги
DROP TRIGGER  IF EXISTS `upd_authors_books_del_authors`;
DELIMITER $$
CREATE TRIGGER `upd_authors_books_del_authors` 
AFTER DELETE
ON `authors`
FOR EACH ROW
BEGIN
    DELETE FROM `authors_books`
    WHERE `author` = OLD.`a_name`;
END;
$$
DELIMITER ;

-- Добавление зависимости книги и жанра
DROP TRIGGER  IF EXISTS `upd_authors_books_ins_m2m`;
DELIMITER $$
CREATE TRIGGER `upd_authors_books_ins_m2m` 
BEFORE INSERT
ON `m2m_books_authors`
FOR EACH ROW
BEGIN
    UPDATE `authors_books`
    SET `book` = CONCAT(`book`, ',', (SELECT `b_name` FROM `books` WHERE `b_id` = NEW.`b_id`))
    WHERE `author` = (SELECT `a_name` FROM `authors` WHERE `a_id` = NEW.`a_id`);
END;
$$
DELIMITER ;

-- Удаление зависимости книги и жанра
DROP TRIGGER  IF EXISTS `upd_authors_books_del_m2m`;
DELIMITER $$
CREATE TRIGGER `upd_authors_books_del_m2m` 
AFTER DELETE
ON `m2m_books_authors`
FOR EACH ROW
BEGIN
    UPDATE `authors_books`
    SET `book` = REPLACE(`book`, CONCAT((SELECT `b_name` FROM `books` WHERE `b_id` = OLD.`b_id`), ','), '')
	WHERE `author` = (SELECT `a_name` FROM `authors` WHERE `a_id` = OLD.`a_id`);
END;
$$
DELIMITER ;

-- Вызов представления
SELECT * FROM `authors_books`;

-- ---------------------------------------------------------------------------------------------

-- 15.	Создать триггер, допускающий регистрацию в библиотеке только таких авторов, имя которых не содержит никаких символов кроме букв, цифр, знаков - (минус), ' (апостроф) и пробелов (не допускается два и более идущих подряд пробела). 
-- (Так же '.' т.к. они есть в изначальных полях имени автора)
DROP TRIGGER  IF EXISTS `author_registration`;
DELIMITER $$
CREATE TRIGGER `author_registration`
BEFORE INSERT ON `authors`
FOR EACH ROW
BEGIN
    DECLARE `valid_characters` VARCHAR(150);
SET `valid_characters` = '-\' абвгдежзийклмнопрстуфхцчшщъыьэюяАБВГДЕЖЗИЁКЛМНОПРСТУФХЦЧШЩЬЪЭЮЯ.';
    
    IF NEW.`a_name` REGEXP CONCAT('^[', `valid_characters`, ']+$') = 0 OR NEW.`a_name` REGEXP '  ' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Incorrect name of author in the name field';
    END IF;
END; 
$$
DELIMITER ;

-- Вызвать таблицу авторов
SELECT * FROM `authors`;