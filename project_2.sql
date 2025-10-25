-- ============================================================
-- COMPLETE TRIGGERS AND PROCEDURES FOR OTT PLATFORM
-- Run this AFTER running project_final.sql
-- ============================================================

USE ott;

-- ============================================================
-- PART 1: DROP EXISTING TRIGGERS AND PROCEDURES (IF ANY)
-- ============================================================

-- Drop existing triggers
DROP TRIGGER IF EXISTS trg_update_content_rating;
DROP TRIGGER IF EXISTS trg_update_total_views;
DROP TRIGGER IF EXISTS trg_subscription_renewal;
DROP TRIGGER IF EXISTS trg_prevent_duplicate_watchlist;
DROP TRIGGER IF EXISTS trg_auto_generate_rating_id;
DROP TRIGGER IF EXISTS trg_validate_rating;
DROP TRIGGER IF EXISTS trg_remove_from_watchlist_on_complete;
DROP TRIGGER IF EXISTS trg_log_content_deletion;

-- Drop existing procedures
DROP PROCEDURE IF EXISTS sp_user_watch_summary;
DROP PROCEDURE IF EXISTS sp_renew_subscription;
DROP PROCEDURE IF EXISTS sp_get_top_rated_content;
DROP PROCEDURE IF EXISTS sp_get_user_recommendations;
DROP PROCEDURE IF EXISTS sp_add_to_watchlist;
DROP PROCEDURE IF EXISTS sp_get_profile_watchlist;
DROP PROCEDURE IF EXISTS sp_record_watch_progress;
DROP PROCEDURE IF EXISTS sp_get_content_details;
DROP PROCEDURE IF EXISTS sp_get_user_subscription;
DROP PROCEDURE IF EXISTS sp_get_content_by_genre;
DROP PROCEDURE IF EXISTS sp_search_content;
DROP PROCEDURE IF EXISTS sp_get_popular_content;
DROP PROCEDURE IF EXISTS sp_remove_from_watchlist;
DROP PROCEDURE IF EXISTS sp_get_all_users_status;
DROP PROCEDURE IF EXISTS sp_get_actor_filmography;

-- ============================================================
-- PART 2: ADD NECESSARY COLUMNS (ONLY IF THEY DON'T EXIST)
-- ============================================================

-- Check and add columns to content table
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'content' AND COLUMN_NAME = 'Content_Rating';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE content ADD COLUMN Content_Rating DECIMAL(3,2) DEFAULT 0.00', 
    'SELECT "Content_Rating already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'content' AND COLUMN_NAME = 'Total_Views';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE content ADD COLUMN Total_Views INT DEFAULT 0', 
    'SELECT "Total_Views already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'content' AND COLUMN_NAME = 'Last_Updated';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE content ADD COLUMN Last_Updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP', 
    'SELECT "Last_Updated already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add columns to users table
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'Subscription_Start_Date';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE users ADD COLUMN Subscription_Start_Date DATE', 
    'SELECT "Subscription_Start_Date already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'Subscription_End_Date';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE users ADD COLUMN Subscription_End_Date DATE', 
    'SELECT "Subscription_End_Date already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'Last_Renewal_Date';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE users ADD COLUMN Last_Renewal_Date DATE', 
    'SELECT "Last_Renewal_Date already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add columns to ratings table
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'ratings' AND COLUMN_NAME = 'Created_At';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE ratings ADD COLUMN Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP', 
    'SELECT "Created_At already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add columns to watch_history table
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'watch_history' AND COLUMN_NAME = 'Created_At';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE watch_history ADD COLUMN Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP', 
    'SELECT "Created_At already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add columns to watchlist table
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ott' AND TABLE_NAME = 'watchlist' AND COLUMN_NAME = 'Status';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE watchlist ADD COLUMN Status VARCHAR(20) DEFAULT "Active"', 
    'SELECT "Status already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create audit table if not exists
CREATE TABLE IF NOT EXISTS content_audit (
    Audit_Id INT AUTO_INCREMENT PRIMARY KEY,
    Content_Id INT,
    Title VARCHAR(150),
    Deleted_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Deleted_By VARCHAR(100)
);

-- ============================================================
-- PART 3: CREATE TRIGGERS
-- ============================================================

-- TRIGGER 1: Update Content Rating (Average) when new rating is added
DELIMITER //
CREATE TRIGGER trg_update_content_rating
AFTER INSERT ON ratings
FOR EACH ROW
BEGIN
    UPDATE content 
    SET Content_Rating = (
        SELECT AVG(Rating) 
        FROM ratings 
        WHERE Content_Id = NEW.Content_Id
    )
    WHERE Content_Id = NEW.Content_Id;
END//
DELIMITER ;

-- TRIGGER 2: Update Total Views when watch history is added
DELIMITER //
CREATE TRIGGER trg_update_total_views
AFTER INSERT ON watch_history
FOR EACH ROW
BEGIN
    UPDATE content 
    SET Total_Views = Total_Views + 1
    WHERE Content_Id = NEW.Content_Id;
END//
DELIMITER ;

-- TRIGGER 3: Update subscription dates on renewal
DELIMITER //
CREATE TRIGGER trg_subscription_renewal
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.Last_Renewal_Date != OLD.Last_Renewal_Date OR OLD.Last_Renewal_Date IS NULL THEN
        UPDATE users 
        SET 
            Subscription_Start_Date = CURDATE(),
            Subscription_End_Date = DATE_ADD(CURDATE(), INTERVAL 
                (SELECT Validity FROM subscription WHERE Subscription_Id = NEW.Subscription_Id) DAY)
        WHERE User_Id = NEW.User_Id;
    END IF;
END//
DELIMITER ;

-- TRIGGER 4: Prevent duplicate watchlist entries
DELIMITER //
CREATE TRIGGER trg_prevent_duplicate_watchlist
BEFORE INSERT ON watchlist
FOR EACH ROW
BEGIN
    DECLARE existing_count INT;
    
    SELECT COUNT(*) INTO existing_count
    FROM watchlist
    WHERE Profile_Id = NEW.Profile_Id 
    AND Content_Id = NEW.Content_Id 
    AND Status = 'Active';
    
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Content already exists in watchlist';
    END IF;
END//
DELIMITER ;

-- TRIGGER 5: Auto-generate Ratings_Id
DELIMITER //
CREATE TRIGGER trg_auto_generate_rating_id
BEFORE INSERT ON ratings
FOR EACH ROW
BEGIN
    DECLARE max_id INT;
    IF NEW.Ratings_Id IS NULL OR NEW.Ratings_Id = 0 THEN
        SELECT COALESCE(MAX(Ratings_Id), 0) + 1 INTO max_id FROM ratings;
        SET NEW.Ratings_Id = max_id;
    END IF;
END//
DELIMITER ;

-- TRIGGER 6: Validate rating range
DELIMITER //
CREATE TRIGGER trg_validate_rating
BEFORE INSERT ON ratings
FOR EACH ROW
BEGIN
    IF NEW.Rating < 1 OR NEW.Rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
END//
DELIMITER ;

-- TRIGGER 7: Remove from watchlist when watched completely
DELIMITER //
CREATE TRIGGER trg_remove_from_watchlist_on_complete
AFTER INSERT ON watch_history
FOR EACH ROW
BEGIN
    IF NEW.Progress >= 95 THEN
        UPDATE watchlist 
        SET Status = 'Completed'
        WHERE Profile_Id = NEW.Profile_Id 
        AND Content_Id = NEW.Content_Id;
    END IF;
END//
DELIMITER ;

-- TRIGGER 8: Log content deletions
DELIMITER //
CREATE TRIGGER trg_log_content_deletion
BEFORE DELETE ON content
FOR EACH ROW
BEGIN
    INSERT INTO content_audit (Content_Id, Title, Deleted_By)
    VALUES (OLD.Content_Id, OLD.Title, USER());
END//
DELIMITER ;

-- ============================================================
-- PART 4: CREATE STORED PROCEDURES
-- ============================================================

-- PROCEDURE 1: User Watch Summary
DELIMITER //
CREATE PROCEDURE sp_user_watch_summary(IN p_user_id INT)
BEGIN
    SELECT 
        p.Name AS Profile_Name,
        c.Title AS Content_Title,
        wh.Progress,
        wh.Watch_Date
    FROM watch_history wh
    JOIN profiles p ON wh.Profile_Id = p.Profile_Id
    JOIN content c ON wh.Content_Id = c.Content_Id
    WHERE p.User_Id = p_user_id
    ORDER BY wh.Watch_Date DESC;
END//
DELIMITER ;

-- PROCEDURE 2: Renew Subscription
DELIMITER //
CREATE PROCEDURE sp_renew_subscription(
    IN p_user_id INT,
    IN p_payment_method VARCHAR(50)
)
BEGIN
    UPDATE users 
    SET Last_Renewal_Date = CURDATE()
    WHERE User_Id = p_user_id;
    
    SELECT 'Subscription renewed successfully' AS Message;
END//
DELIMITER ;

-- PROCEDURE 3: Get Top Rated Content
DELIMITER //
CREATE PROCEDURE sp_get_top_rated_content(IN p_limit INT)
BEGIN
    SELECT 
        c.Content_Id,
        c.Title,
        c.Type,
        c.Release_Year,
        c.Content_Rating,
        c.Total_Views,
        g.Name AS Genre
    FROM content c
    LEFT JOIN genre g ON c.Genre_Id = g.Genre_Id
    WHERE c.Content_Rating > 0
    ORDER BY c.Content_Rating DESC, c.Total_Views DESC
    LIMIT p_limit;
END//
DELIMITER ;

-- PROCEDURE 4: Get User Recommendations (based on watch history)
DELIMITER //
CREATE PROCEDURE sp_get_user_recommendations(IN p_user_id INT)
BEGIN
    SELECT DISTINCT
        c.Content_Id,
        c.Title,
        c.Type,
        c.Content_Rating,
        g.Name AS Genre
    FROM content c
    JOIN genre g ON c.Genre_Id = g.Genre_Id
    WHERE c.Genre_Id IN (
        SELECT DISTINCT c2.Genre_Id
        FROM watch_history wh
        JOIN profiles p ON wh.Profile_Id = p.Profile_Id
        JOIN content c2 ON wh.Content_Id = c2.Content_Id
        WHERE p.User_Id = p_user_id
    )
    AND c.Content_Id NOT IN (
        SELECT wh2.Content_Id
        FROM watch_history wh2
        JOIN profiles p2 ON wh2.Profile_Id = p2.Profile_Id
        WHERE p2.User_Id = p_user_id
    )
    ORDER BY c.Content_Rating DESC
    LIMIT 10;
END//
DELIMITER ;

-- PROCEDURE 5: Add to Watchlist
DELIMITER //
CREATE PROCEDURE sp_add_to_watchlist(
    IN p_profile_id INT,
    IN p_content_id INT
)
BEGIN
    DECLARE max_id INT;
    DECLARE existing_count INT;
    
    SELECT COUNT(*) INTO existing_count
    FROM watchlist
    WHERE Profile_Id = p_profile_id 
    AND Content_Id = p_content_id 
    AND Status = 'Active';
    
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Content already in watchlist';
    ELSE
        SELECT COALESCE(MAX(Watchlist_Id), 0) + 1 INTO max_id FROM watchlist;
        
        INSERT INTO watchlist (Watchlist_Id, Profile_Id, Content_Id, Added_Date, Status)
        VALUES (max_id, p_profile_id, p_content_id, CURDATE(), 'Active');
        
        SELECT 'Added to watchlist successfully' AS Message;
    END IF;
END//
DELIMITER ;

-- PROCEDURE 6: Get Profile Watchlist
DELIMITER //
CREATE PROCEDURE sp_get_profile_watchlist(IN p_profile_id INT)
BEGIN
    SELECT 
        w.Watchlist_Id,
        c.Content_Id,
        c.Title,
        c.Type,
        c.Release_Year,
        c.Content_Rating,
        g.Name AS Genre,
        w.Added_Date,
        w.Status
    FROM watchlist w
    JOIN content c ON w.Content_Id = c.Content_Id
    LEFT JOIN genre g ON c.Genre_Id = g.Genre_Id
    WHERE w.Profile_Id = p_profile_id
    AND w.Status = 'Active'
    ORDER BY w.Added_Date DESC;
END//
DELIMITER ;

-- PROCEDURE 7: Record Watch Progress
DELIMITER //
CREATE PROCEDURE sp_record_watch_progress(
    IN p_profile_id INT,
    IN p_content_id INT,
    IN p_progress DECIMAL(5,2)
)
BEGIN
    DECLARE max_id INT;
    DECLARE existing_id INT;
    
    SELECT History_Id INTO existing_id
    FROM watch_history
    WHERE Profile_Id = p_profile_id 
    AND Content_Id = p_content_id
    AND Watch_Date = CURDATE()
    LIMIT 1;
    
    IF existing_id IS NOT NULL THEN
        UPDATE watch_history
        SET Progress = p_progress
        WHERE History_Id = existing_id;
    ELSE
        SELECT COALESCE(MAX(History_Id), 0) + 1 INTO max_id FROM watch_history;
        
        INSERT INTO watch_history (History_Id, Watch_Date, Progress, Profile_Id, Content_Id)
        VALUES (max_id, CURDATE(), p_progress, p_profile_id, p_content_id);
    END IF;
    
    SELECT 'Watch progress recorded' AS Message;
END//
DELIMITER ;

-- PROCEDURE 8: Get Content Details with Stats
DELIMITER //
CREATE PROCEDURE sp_get_content_details(IN p_content_id INT)
BEGIN
    SELECT 
        c.Content_Id,
        c.Title,
        c.Type,
        c.Release_Year,
        c.Language,
        c.Content_Rating,
        c.Total_Views,
        g.Name AS Genre,
        COUNT(DISTINCT r.Ratings_Id) AS Total_Ratings,
        COUNT(DISTINCT s.Season_Id) AS Total_Seasons
    FROM content c
    LEFT JOIN genre g ON c.Genre_Id = g.Genre_Id
    LEFT JOIN ratings r ON c.Content_Id = r.Content_Id
    LEFT JOIN seasons s ON c.Content_Id = s.Content_Id
    WHERE c.Content_Id = p_content_id
    GROUP BY c.Content_Id;
    
    SELECT 
        a.Actor_Name
    FROM content_actors ca
    JOIN actors a ON ca.Actor_Id = a.Actor_Id
    WHERE ca.Content_Id = p_content_id;
END//
DELIMITER ;

-- PROCEDURE 9: Get User Subscription Info
DELIMITER //
CREATE PROCEDURE sp_get_user_subscription(IN p_user_id INT)
BEGIN
    SELECT 
        u.User_Id,
        u.Name,
        u.Email,
        s.Plan_Name,
        s.Price,
        s.Validity,
        u.Subscription_Start_Date,
        u.Subscription_End_Date,
        DATEDIFF(u.Subscription_End_Date, CURDATE()) AS Days_Remaining
    FROM users u
    JOIN subscription s ON u.Subscription_Id = s.Subscription_Id
    WHERE u.User_Id = p_user_id;
END//
DELIMITER ;

-- PROCEDURE 10: Get Content by Genre
DELIMITER //
CREATE PROCEDURE sp_get_content_by_genre(IN p_genre_name VARCHAR(50))
BEGIN
    SELECT 
        c.Content_Id,
        c.Title,
        c.Type,
        c.Release_Year,
        c.Content_Rating,
        c.Total_Views,
        c.Language
    FROM content c
    JOIN genre g ON c.Genre_Id = g.Genre_Id
    WHERE g.Name = p_genre_name
    ORDER BY c.Content_Rating DESC, c.Total_Views DESC;
END//
DELIMITER ;

-- PROCEDURE 11: Search Content
DELIMITER //
CREATE PROCEDURE sp_search_content(IN p_search_term VARCHAR(150))
BEGIN
    SELECT 
        c.Content_Id,
        c.Title,
        c.Type,
        c.Release_Year,
        c.Content_Rating,
        c.Total_Views,
        g.Name AS Genre,
        c.Language
    FROM content c
    LEFT JOIN genre g ON c.Genre_Id = g.Genre_Id
    WHERE c.Title LIKE CONCAT('%', p_search_term, '%')
    OR g.Name LIKE CONCAT('%', p_search_term, '%')
    ORDER BY c.Content_Rating DESC
    LIMIT 20;
END//
DELIMITER ;

-- PROCEDURE 12: Get Popular Content (most viewed)
DELIMITER //
CREATE PROCEDURE sp_get_popular_content(IN p_limit INT)
BEGIN
    SELECT 
        c.Content_Id,
        c.Title,
        c.Type,
        c.Release_Year,
        c.Content_Rating,
        c.Total_Views,
        g.Name AS Genre
    FROM content c
    LEFT JOIN genre g ON c.Genre_Id = g.Genre_Id
    WHERE c.Total_Views > 0
    ORDER BY c.Total_Views DESC, c.Content_Rating DESC
    LIMIT p_limit;
END//
DELIMITER ;

-- PROCEDURE 13: Remove from Watchlist
DELIMITER //
CREATE PROCEDURE sp_remove_from_watchlist(IN p_watchlist_id INT)
BEGIN
    UPDATE watchlist
    SET Status = 'Removed'
    WHERE Watchlist_Id = p_watchlist_id;
    
    SELECT 'Removed from watchlist' AS Message;
END//
DELIMITER ;

-- PROCEDURE 14: Get All Users with Subscription Status
DELIMITER //
CREATE PROCEDURE sp_get_all_users_status()
BEGIN
    SELECT 
        u.User_Id,
        u.Name,
        u.Email,
        s.Plan_Name,
        u.Subscription_End_Date,
        CASE 
            WHEN u.Subscription_End_Date >= CURDATE() THEN 'Active'
            ELSE 'Expired'
        END AS Status,
        DATEDIFF(u.Subscription_End_Date, CURDATE()) AS Days_Remaining
    FROM users u
    JOIN subscription s ON u.Subscription_Id = s.Subscription_Id
    ORDER BY u.User_Id;
END//
DELIMITER ;

-- PROCEDURE 15: Get Actor Filmography
DELIMITER //
CREATE PROCEDURE sp_get_actor_filmography(IN p_actor_id INT)
BEGIN
    SELECT 
        a.Actor_Name,
        c.Content_Id,
        c.Title,
        c.Type,
        c.Release_Year,
        c.Content_Rating,
        g.Name AS Genre
    FROM actors a
    JOIN content_actors ca ON a.Actor_Id = ca.Actor_Id
    JOIN content c ON ca.Content_Id = c.Content_Id
    LEFT JOIN genre g ON c.Genre_Id = g.Genre_Id
    WHERE a.Actor_Id = p_actor_id
    ORDER BY c.Release_Year DESC;
END//
DELIMITER ;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Show all triggers
SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE 
FROM INFORMATION_SCHEMA.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'ott';

-- Show all procedures
SELECT ROUTINE_NAME, ROUTINE_TYPE 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_SCHEMA = 'ott' AND ROUTINE_TYPE = 'PROCEDURE';

-- Success message
SELECT '✅ All triggers and procedures created successfully!' AS Status;