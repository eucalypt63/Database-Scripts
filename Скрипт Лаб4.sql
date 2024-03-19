-- Add 3 subscribers
 INSERT INTO `subscribers` VALUES (5,'Орлов О.О.'), (6,'Соколов С.С.'), (7,'Беркутов Б.Б.');
 
-- Add them subscriptions
 INSERT INTO `subscriptions` VALUES (105,5,6,'2016-01-20','2011-02-20','Y'),(106,6,6,'2016-01-20','2011-02-20','Y'),(107,7,6,'2016-01-20','2011-02-20','Y');

-- Mark all subscriptions with id ≤50 as returned
 UPDATE `subscriptions` SET `sb_is_active` = 'N' WHERE `sb_id` <= 50;

-- For all subscriptions made before January 1, 2012, reduce the value of the day of subscription by 3
SET `SQL_SAFE_UPDATES` = 0;
UPDATE `subscriptions` SET `sb_start` = DATE_SUB(`sb_start`, INTERVAL 3 DAY) WHERE `sb_finish` < '2012-01-01';
SET `SQL_SAFE_UPDATES` = 1;

-- Delete all books belonging to the “Classics” genre
SET `SQL_SAFE_UPDATES` = 0;
DELETE FROM `books`
WHERE `b_id` IN (
  SELECT `b_id`
  FROM `m2m_books_genres`
  WHERE `g_id` = (SELECT `g_id` FROM `genres` WHERE `g_name` = 'Классика')
);
SET `SQL_SAFE_UPDATES` = 1;
