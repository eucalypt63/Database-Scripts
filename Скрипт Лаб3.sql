-- Show a list of books that have more than one author.
SELECT `b`.`b_id`, `b_name`, GROUP_CONCAT(`a_name` SEPARATOR ', ') AS `authors`
FROM `books` `b`
JOIN `m2m_books_authors` ON `b`.`b_id` = `m2m_books_authors`.`b_id`
JOIN `authors` ON `m2m_books_authors`.`a_id` = `authors`.`a_id`
WHERE `b`.`b_id` IN (
    SELECT `b_id`
    FROM `m2m_books_authors`
    GROUP BY `b_id`
    HAVING COUNT(*) > 1
)
GROUP BY `b`.`b_id`, `b_name`;

-- Show all books with their genres
SELECT `b`.`b_name`, GROUP_CONCAT(`g`.`g_name` SEPARATOR ', ') AS `genres`
FROM `books` `b`
JOIN `m2m_books_genres` `bg` ON `b`.`b_id` = `bg`.`b_id`
JOIN `genres` `g` ON `bg`.`g_id` = `g`.`g_id`
GROUP BY `b`.`b_name`;

-- Show a list of books that no reader has ever taken
SELECT `b_id`, `b_name`
FROM `books`
WHERE `b_id` NOT IN (SELECT `sb_book` FROM `subscriptions`);

-- Show all subscribers who did not return books, and the number of unreturned books for each such reader.
SELECT `s`.`s_id`, `s`.`s_name`, COUNT(*) AS `unreturned_books_count`,  
GROUP_CONCAT(`b`.`b_name` SEPARATOR ', ') AS `books_name`
FROM `subscribers` `s`
JOIN `subscriptions` `sb` ON `s`.`s_id` = `sb`.`sb_subscriber`
JOIN `books` `b` ON  `sb`.`sb_book` = `b`.`b_id`
WHERE `sb`.`sb_is_active` = 'Y' AND `sb`.`sb_finish` < CURDATE()
GROUP BY `s`.`s_id`, `s`.`s_name`;

-- Show the subscriber who last borrowed a book from the library.
SELECT `s`.`s_id`, `s`.`s_name`, MAX(`sb`.`sb_start`) AS `last_borrow_date`
FROM `subscribers` `s`
JOIN `subscriptions` `sb` ON `s`.`s_id` = `sb`.`sb_subscriber`
GROUP BY `s`.`s_id`, `s`.`s_name`
ORDER BY `last_borrow_date` DESC
LIMIT 1;