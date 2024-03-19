-- Author information
SELECT * FROM `authors`;

-- Book identifiers taken by subscriber
SELECT DISTINCT `sb_book` FROM `subscriptions`;

-- Total books taken
SELECT COUNT(*) AS `total_books` FROM `subscriptions`;

-- Books taken by each subscriber
SELECT `sb_subscriber`, COUNT(*) AS `books_of_each_subscriber`
FROM `subscriptions`
GROUP BY `sb_subscriber`;

-- Books taken by the most subscriber by subscriber ¯\_(ツ)_/¯
SELECT `sb_subscriber`, COUNT(*) AS `total_books_taken`
FROM `subscriptions`
GROUP BY `sb_subscriber`
ORDER BY `total_books_taken` DESC
LIMIT 1;

-- How long the subscriber has been registered
SELECT `sb_subscriber` AS `subscriber_id`, 
       CONCAT(
           FLOOR(DATEDIFF(NOW(), MIN(`sb_start`)) / 365), ' Г. ',
           FLOOR(MOD(DATEDIFF(NOW(), MIN(`sb_start`)), 365) / 30), ' М. ',
           FLOOR(MOD(MOD(DATEDIFF(NOW(), MIN(`sb_start`)), 365), 30)), ' Д. '
       ) AS `average_registration_duration`
FROM `subscriptions`
GROUP BY `sb_subscriber`;

-- Show in days how many subscriber on average are already registered in the library
SELECT AVG(`registration_duration`) AS `average_registration_duration`
FROM (
    SELECT `sb_subscriber`, DATEDIFF(NOW(), MIN(`sb_start`)) AS `registration_duration`
    FROM `subscriptions`
    GROUP BY `sb_subscriber`
) AS `registration_durations`;