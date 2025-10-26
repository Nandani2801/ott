DROP TABLE IF EXISTS Ratings, Watchlist, Watch_History, Episodes, Seasons, Content_Actors, Actors, Content, Genre, Profiles, Users, Subscription, Payment_History, Trigger_Logs, Device_Info, Download_History, Search_History, Recommendations, Customer_Support, Feedback, Parental_Control, Notifications, Subscription_Renewal;

-- =========================
-- 1. TABLE CREATION
-- =========================

-- 1. SUBSCRIPTION
CREATE TABLE subscription (
    Subscription_Id INT PRIMARY KEY,
    Plan_Name VARCHAR(50),
    Price DECIMAL(10,2),
    Validity INT
);

-- 2. USERS (Corrected syntax for DATE_ADD defaults)
CREATE TABLE users (
    User_Id INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
    Subscription_Id INT,
    Subscription_Start_Date DATE DEFAULT (CURRENT_DATE()), -- Use parenthesis for CURRENT_DATE()
    Subscription_End_Date DATE DEFAULT (DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)), -- Enclose DATE_ADD in parenthesis
    FOREIGN KEY (Subscription_Id) REFERENCES Subscription(Subscription_Id)
);

-- 3. PROFILES
CREATE TABLE profiles (
    Profile_Id INT PRIMARY KEY,
    User_Id INT,
    Name VARCHAR(100) NOT NULL,
    AgeGroup VARCHAR(20),
    FOREIGN KEY (User_Id) REFERENCES Users(User_Id)
);

-- 4. GENRE
CREATE TABLE genre (
    Genre_Id INT PRIMARY KEY,
    Name VARCHAR(50) UNIQUE
);

-- 5. CONTENT (Removed Type CHECK constraint for robustness, kept simple)
CREATE TABLE content (
    Content_Id INT PRIMARY KEY,
    Title VARCHAR(150) NOT NULL,
    Type VARCHAR(50), -- CHECK (Type IN ('Movie','Series')) is removed/simplified
    Release_Year INT,
    Subscription_Required BOOLEAN,
    Language VARCHAR(50),
    Genre_Id INT,
    Content_Rating DECIMAL(3,2) DEFAULT 0.0,
    Total_Views INT DEFAULT 0,
    FOREIGN KEY (Genre_Id) REFERENCES Genre(Genre_Id)
);

-- 6. ACTORS
CREATE TABLE actors (
    Actor_Id INT PRIMARY KEY,
    Actor_Name VARCHAR(100) NOT NULL
);

-- 7. CONTENT_ACTORS
CREATE TABLE content_actors (
    Content_Id INT,
    Actor_Id INT,
    PRIMARY KEY (Content_Id, Actor_Id),
    FOREIGN KEY (Content_Id) REFERENCES Content(Content_Id),
    FOREIGN KEY (Actor_Id) REFERENCES Actors(Actor_Id)
);

-- 8. SEASONS
CREATE TABLE seasons (
    Season_Id INT PRIMARY KEY,
    Content_Id INT,
    Season_Number INT,
    Release_Year INT,
    FOREIGN KEY (Content_Id) REFERENCES Content(Content_Id)
);

-- 9. EPISODES
CREATE TABLE episodes (
    Episode_Id INT PRIMARY KEY,
    Season_Id INT,
    Title VARCHAR(150),
    Duration INT,
    Release_Date DATE,
    FOREIGN KEY (Season_Id) REFERENCES Seasons(Season_Id)
);

-- 10. WATCH HISTORY
CREATE TABLE watch_history (
    History_Id INT PRIMARY KEY,
    Watch_Date DATE,
    Progress DECIMAL(5,2),
    Profile_Id INT,
    Content_Id INT,
    FOREIGN KEY (Profile_Id) REFERENCES Profiles(Profile_Id),
    FOREIGN KEY (Content_Id) REFERENCES Content(Content_Id)
);

-- 11. WATCHLIST
CREATE TABLE watchlist (
    Watchlist_Id INT PRIMARY KEY,
    Profile_Id INT,
    Content_Id INT,
    Added_Date DATE,
    FOREIGN KEY (Profile_Id) REFERENCES Profiles(Profile_Id),
    FOREIGN KEY (Content_Id) REFERENCES Content(Content_Id)
);

-- 12. RATINGS
CREATE TABLE ratings (
    Ratings_Id INT PRIMARY KEY,
    Profile_Id INT,
    Content_Id INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Review_Text TEXT,
    FOREIGN KEY (Profile_Id) REFERENCES Profiles(Profile_Id),
    FOREIGN KEY (Content_Id) REFERENCES Content(Content_Id)
);

-- ADDITIONAL TABLES

CREATE TABLE payment_history (
    Payment_Id INT PRIMARY KEY AUTO_INCREMENT,
    User_Id INT,
    Amount DECIMAL(10,2),
    Payment_Date DATE DEFAULT (CURRENT_DATE()),
    Payment_Method VARCHAR(50),
    FOREIGN KEY (User_Id) REFERENCES Users(User_Id)
);

CREATE TABLE trigger_logs (
    Log_Id INT PRIMARY KEY AUTO_INCREMENT,
    Log_Type VARCHAR(50),
    Description TEXT,
    Log_Time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE device_info (
    Device_Id INT PRIMARY KEY AUTO_INCREMENT,
    User_Id INT,
    Device_Type VARCHAR(50),
    Device_Name VARCHAR(100),
    Last_Login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_Id) REFERENCES Users(User_Id)
);

CREATE TABLE download_history (
    Download_Id INT PRIMARY KEY AUTO_INCREMENT,
    Profile_Id INT,
    Content_Id INT,
    Download_Date DATE DEFAULT (CURRENT_DATE()),
    Device_Id INT,
    FOREIGN KEY (Profile_Id) REFERENCES Profiles(Profile_Id),
    FOREIGN KEY (Content_Id) REFERENCES Content(Content_Id),
    FOREIGN KEY (Device_Id) REFERENCES Device_Info(Device_Id)
);

CREATE TABLE search_history (
    Search_Id INT PRIMARY KEY AUTO_INCREMENT,
    Profile_Id INT,
    Search_Query VARCHAR(255),
    Search_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Profile_Id) REFERENCES Profiles(Profile_Id)
);

CREATE TABLE recommendations (
    Recommendation_Id INT PRIMARY KEY AUTO_INCREMENT,
    Profile_Id INT,
    Recommended_Content_Id INT,
    Reason VARCHAR(255),
    FOREIGN KEY (Profile_Id) REFERENCES Profiles(Profile_Id),
    FOREIGN KEY (Recommended_Content_Id) REFERENCES Content(Content_Id)
);

CREATE TABLE customer_support (
    Ticket_Id INT PRIMARY KEY AUTO_INCREMENT,
    User_Id INT,
    Issue_Type VARCHAR(100),
    Issue_Description TEXT,
    Status VARCHAR(50) DEFAULT 'Open',
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_Id) REFERENCES Users(User_Id)
);

CREATE TABLE feedback (
    Feedback_Id INT PRIMARY KEY AUTO_INCREMENT,
    User_Id INT,
    Message TEXT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_Id) REFERENCES Users(User_Id)
);

CREATE TABLE parental_control (
    Control_Id INT PRIMARY KEY AUTO_INCREMENT,
    Profile_Id INT,
    Restriction_Level VARCHAR(50),
    FOREIGN KEY (Profile_Id) REFERENCES Profiles(Profile_Id)
);

CREATE TABLE notifications (
    Notification_Id INT PRIMARY KEY AUTO_INCREMENT,
    User_Id INT,
    Message TEXT,
    Sent_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_Id) REFERENCES Users(User_Id)
);

CREATE TABLE subscription_renewal (
    Renewal_Id INT PRIMARY KEY AUTO_INCREMENT,
    User_Id INT,
    Renewal_Date DATE,
    Amount DECIMAL(10,2),
    Payment_Method VARCHAR(50),
    FOREIGN KEY (User_Id) REFERENCES Users(User_Id)
);

-- =========================
-- 2. INSERT INITIAL DATA
-- =========================

INSERT INTO subscription VALUES
(1, 'Basic', 199.99, 30),
(2, 'Standard', 299.99, 30),
(3, 'Premium', 499.99, 30),
(4, 'Ultra', 699.99, 30);

INSERT INTO users (User_Id, Name, Email, Password, Subscription_Id) VALUES
(1, 'Rohan Sharma', 'rohan.sharma@example.com', 'rohan123', 2),
(2, 'Priya Singh', 'priya.singh@example.com', 'priya123', 3),
(3, 'Amit Kumar', 'amit.kumar@example.com', 'amit123', 1),
(4, 'Neha Patel', 'neha.patel@example.com', 'neha123', 2),
(5, 'Vikram Rao', 'vikram.rao@example.com', 'vikram123', 4),
(6, 'Sonal Mehta', 'sonal.mehta@example.com', 'sonal123', 3),
(7, 'Arjun Kapoor', 'arjun.kapoor@example.com', 'arjun123', 2),
(8, 'Ritika Joshi', 'ritika.joshi@example.com', 'ritika123', 1),
(9, 'Karan Verma', 'karan.verma@example.com', 'karan123', 3),
(10, 'Simran Kaur', 'simran.kaur@example.com', 'simran123', 2),
(11, 'Ananya Nair', 'ananya.nair@example.com', 'ananya123', 2),
(12, 'Devansh Choudhary', 'devansh.choudhary@example.com', 'devansh123', 4),
(13, 'Tanvi Desai', 'tanvi.desai@example.com', 'tanvi123', 3),
(14, 'Aditya Mishra', 'aditya.mishra@example.com', 'aditya123', 2),
(15, 'Isha Reddy', 'isha.reddy@example.com', 'isha123', 1),
(16, 'Manish Jain', 'manish.jain@example.com', 'manish123', 3),
(17, 'Tanya Roy', 'tanya.roy@example.com', 'tanya123', 2),
(18, 'Raghav Bansal', 'raghav.bansal@example.com', 'raghav123', 4),
(19, 'Pooja Gupta', 'pooja.gupta@example.com', 'pooja123', 3),
(20, 'Shivansh Pillai', 'shivansh.pillai@example.com', 'shivansh123', 2),
(21, 'Meera Nambiar', 'meera.nambiar@example.com', 'meera123', 1),
(22, 'Kunal Dutta', 'kunal.dutta@example.com', 'kunal123', 3),
(23, 'Sanya Bhatia', 'sanya.bhatia@example.com', 'sanya123', 2),
(24, 'Harsh Vardhan', 'harsh.vardhan@example.com', 'harsh123', 4),
(25, 'Anjali Chawla', 'anjali.chawla@example.com', 'anjali123', 2);

INSERT INTO profiles VALUES
(1,1,'Rohan Jr','Teen'),(2,1,'Rohan Mom','Adult'),(3,2,'Priya Teen','Teen'),(4,2,'Priya Dad','Adult'),
(5,3,'Amit Self','Adult'),(6,4,'Neha Teen','Teen'),(7,4,'Neha Mom','Adult'),(8,5,'Vikram Jr','Teen'),
(9,5,'Vikram Dad','Adult'),(10,6,'Sonal Self','Adult'),(11,7,'Arjun Teen','Teen'),(12,7,'Arjun Mom','Adult'),
(13,8,'Ritika Self','Adult'),(14,9,'Karan Jr','Teen'),(15,9,'Karan Dad','Adult'),(16,10,'Simran Teen','Teen'),
(17,10,'Simran Mom','Adult'),(18,11,'Ananya Teen','Teen'),(19,11,'Ananya Mom','Adult'),(20,12,'Devansh Self','Adult'),
(21,13,'Tanvi Self','Adult'),(22,14,'Aditya Jr','Teen'),(23,14,'Aditya Dad','Adult'),(24,15,'Isha Self','Adult'),
(25,16,'Manish Teen','Teen'),(26,16,'Manish Mom','Adult'),(27,17,'Tanya Self','Adult'),(28,18,'Raghav Jr','Teen'),
(29,18,'Raghav Dad','Adult'),(30,19,'Pooja Self','Adult'),(31,20,'Shivansh Jr','Teen'),(32,20,'Shivansh Dad','Adult'),
(33,21,'Meera Self','Adult'),(34,22,'Kunal Self','Adult'),(35,23,'Sanya Teen','Teen'),(36,23,'Sanya Mom','Adult'),
(37,24,'Harsh Jr','Teen'),(38,24,'Harsh Dad','Adult'),(39,25,'Anjali Self','Adult'),(40,5,'Vikram Jr2','Teen'),
(41,6,'Sonal Teen','Teen'),(42,8,'Ritika Teen','Teen'),(43,12,'Arjun Jr','Teen'),(44,14,'Aditya Jr2','Teen'),
(45,17,'Tanya Teen','Teen'),(46,19,'Pooja Teen','Teen'),(47,20,'Shivansh Jr2','Teen'),(48,22,'Kunal Jr','Teen'),
(49,25,'Anjali Teen','Teen'),(50,3,'Amit Jr','Teen');

INSERT INTO genre VALUES
(1,'Drama'),(2,'Comedy'),(3,'Action'),(4,'Romance'),(5,'Thriller'),
(6,'Horror'),(7,'Mythology'),(8,'Reality Show'),(9,'Sci-Fi'),(10,'Documentary');

INSERT INTO content (Content_Id, Title, Type, Release_Year, Subscription_Required, Language, Genre_Id) VALUES
(1,'3 Idiots','Movie',2009,TRUE,'Hindi',2),(2,'Dangal','Movie',2016,TRUE,'Hindi',1),
(3,'Bahubali: The Beginning','Movie',2015,TRUE,'Telugu',3),(4,'Bahubali 2','Movie',2017,TRUE,'Telugu',3),
(5,'PK','Movie',2014,TRUE,'Hindi',2),(6,'Andhadhun','Movie',2018,TRUE,'Hindi',5),(7,'Kahaani','Movie',2012,TRUE,'Hindi',5),
(8,'Gully Boy','Movie',2019,TRUE,'Hindi',1),(9,'Tumbbad','Movie',2018,TRUE,'Hindi',6),(10,'Stree','Movie',2018,TRUE,'Hindi',6),
(11,'Padmaavat','Movie',2018,TRUE,'Hindi',7),(12,'Raazi','Movie',2018,TRUE,'Hindi',5),(13,'Uri: The Surgical Strike','Movie',2019,TRUE,'Hindi',3),
(14,'Mission Mangal','Movie',2019,TRUE,'Hindi',1),(15,'Chhichhore','Movie',2019,TRUE,'Hindi',2),(16,'Shershaah','Movie',2021,TRUE,'Hindi',3),
(17,'Bhool Bhulaiyaa 2','Movie',2022,TRUE,'Hindi',6),(18,'Drishyam','Movie',2015,TRUE,'Malayalam',5),(19,'Raees','Movie',2017,TRUE,'Hindi',3),
(20,'Tamasha','Movie',2015,TRUE,'Hindi',4),(21,'Kabir Singh','Movie',2019,TRUE,'Hindi',4),(22,'Simmba','Movie',2018,TRUE,'Hindi',3),
(23,'Bajrangi Bhaijaan','Movie',2015,TRUE,'Hindi',1),(24,'PK 2','Movie',2023,TRUE,'Hindi',2),(25,'Gangubai Kathiawadi','Movie',2022,TRUE,'Hindi',1),
(26,'Sacred Games','Series',2018,TRUE,'Hindi',5),(27,'Mirzapur','Series',2018,TRUE,'Hindi',3),
(28,'Delhi Crime','Series',2019,TRUE,'Hindi',5),(29,'Panchayat','Series',2020,TRUE,'Hindi',2),
(30,'Made in Heaven','Series',2019,TRUE,'Hindi',4),(31,'Family Man','Series',2019,TRUE,'Hindi',3),
(32,'Kota Factory','Series',2019,TRUE,'Hindi',2),(33,'Criminal Justice','Series',2019,TRUE,'Hindi',5),
(34,'Asur','Series',2020,TRUE,'Hindi',5),(35,'Special Ops','Series',2020,TRUE,'Hindi',5),(36,'Tandav','Series',2021,TRUE,'Hindi',5),
(37,'Farzi','Series',2023,TRUE,'Hindi',5),(38,'Jamtara','Series',2020,TRUE,'Hindi',3),(39,'Breathe','Series',2018,TRUE,'Hindi',5),
(40,'Aarya','Series',2020,TRUE,'Hindi',5),(41,'Raktanchal','Series',2020,TRUE,'Hindi',3),(42,'Tabbar','Series',2021,TRUE,'Hindi',5),
(43,'Ray','Series',2021,TRUE,'Hindi',5),(44,'Kaun Banega Crorepati','Series',2023,TRUE,'Hindi',8),
(45,'Indian Idol','Series',2023,TRUE,'Hindi',8),(46,'Super Singer','Series',2023,TRUE,'Tamil',8),(47,'Taj Mahal 1989','Series',2020,TRUE,'Hindi',4),
(48,'Sunflower','Series',2021,TRUE,'Hindi',5),(49,'Kahi Suni','Series',2021,TRUE,'Hindi',5),(50,'Taboo','Series',2022,TRUE,'Hindi',6);

INSERT INTO actors VALUES
(1,'Amitabh Bachchan'),(2,'Shah Rukh Khan'),(3,'Salman Khan'),(4,'Aamir Khan'),(5,'Ranbir Kapoor'),
(6,'Ranveer Singh'),(7,'Hrithik Roshan'),(8,'Akshay Kumar'),(9,'Vicky Kaushal'),(10,'Varun Dhawan'),
(11,'Alia Bhatt'),(12,'Deepika Padukone'),(13,'Kareena Kapoor'),(14,'Katrina Kaif'),(15,'Anushka Sharma'),
(16,'Priyanka Chopra'),(17,'Kangana Ranaut'),(18,'Sara Ali Khan'),(19,'Taapsee Pannu'),(20,'Bhumi Pednekar'),
(21,'Nawazuddin Siddiqui'),(22,'Pankaj Tripathi'),(23,'Manoj Bajpayee'),(24,'Radhika Apte'),(25,'Sobhita Dhulipala'),
(26,'Vijay Sethupathi'),(27,'Dulquer Salmaan'),(28,'Fahadh Faasil'),(29,'R. Madhavan'),(30,'Shahid Kapoor'),
(31,'Madhuri Dixit'),(32,'Kajol'),(33,'Rani Mukerji'),(34,'Tabu'),(35,'Sridevi'),
(36,'Janhvi Kapoor'),(37,'Kiara Advani'),(38,'Ileana D’Cruz'),(39,'Yami Gautam'),(40,'Riteish Deshmukh'),
(41,'Ajay Devgn'),(42,'Sanjay Dutt'),(43,'Tiger Shroff'),(44,'Jackie Shroff'),(45,'Shreyas Talpade'),
(46,'Emraan Hashmi'),(47,'Rajkummar Rao'),(48,'Vicky Kaushal'),(49,'Rajinikanth'),(50,'Mahesh Babu');


INSERT INTO content_actors VALUES
-- Movies
(1,4),(1,11),(2,4),(2,6),(3,5),(3,1),(4,5),(4,2),(5,4),(5,12),
(6,21),(6,22),(7,23),(7,24),(8,6),(8,11),(9,17),(9,20),(10,14),(10,16),
(11,1),(11,31),(12,12),(12,13),(13,8),(13,22),(14,4),(14,6),(15,5),(15,11),
(16,6),(16,8),(17,20),(17,16),(18,28),(18,27),(19,3),(19,15),(20,2),(20,12),
(21,5),(21,12),(22,8),(22,40),(23,1),(23,15),(24,4),(24,6),(25,11),(25,12),
-- Series
(26,2),(26,22),(27,22),(27,23),(28,21),(28,24),(29,11),(29,12),(30,6),(30,7),
(31,9),(31,22),(32,22),(32,24),(33,21),(33,23),(34,24),(34,25),(35,5),(35,6),
(36,7),(36,11),(37,5),(37,6),(38,26),(38,27),(39,28),(39,29),(40,30),(40,12),
(41,23),(41,24),(42,24),(42,25),(43,2),(43,12),(44,11),(44,15),(45,11),(45,12),
(46,26),(46,27),(47,11),(47,12),(48,22),(48,23),(49,49),(50,50),
-- Additional mappings (for variety)
(1,2),(1,5),(2,1),(2,3),(3,2),(3,7),(4,9),(4,12),(5,6),(5,7),
(6,30),(7,25),(8,13),(9,19),(10,20),(11,4),(12,6),(12,8),
(13,5),(13,9),(14,10),(15,3),(16,2),(16,7),(17,18),(17,19),
(21,1),(21,23),(22,6),(22,9),(23,8),(23,10),(24,5),(24,7),
(26,1),(26,3),(27,4),(27,5),(28,6),(28,7),(29,8),(29,9),
(30,10),(30,11),(31,12),(31,13),(32,14),(32,15),(33,16),(33,17),
(34,18),(34,19),(35,20),(35,21),(36,22),(36,23),(37,24),(37,25),
(40,31);


INSERT INTO seasons VALUES
(1,26,1,2018),(2,26,2,2019),(3,27,1,2018),(4,27,2,2019),(5,28,1,2019),
(6,29,1,2020),(7,30,1,2019),(8,31,1,2019),(9,32,1,2019),(10,32,2,2020),
(11,33,1,2020),(12,34,1,2020),(13,35,1,2021),(14,36,1,2019),(15,37,1,2023),
(16,38,1,2020),(17,39,1,2018),(18,40,1,2020),(19,41,1,2020),(20,42,1,2021),
(21,43,1,2021),(22,44,1,2023),(23,45,1,2023),(24,46,1,2023),(25,47,1,2020),
(26,48,1,2021),(27,49,1,2021),(28,50,1,2022),(29,26,3,2020),(30,27,3,2021),
(31,28,2,2020),(32,29,2,2021),(33,30,2,2021),(34,31,2,2020),(35,32,3,2021),
(36,33,2,2021),(37,34,2,2021),(38,35,2,2023),(39,36,2,2021),(40,37,2,2023);

-- Episode data with a more substantial dataset (~80 records)
INSERT INTO episodes VALUES
(1,1,'Episode 1: Beginnings',50,'2018-07-01'),(2,1,'Episode 2: The Game',55,'2018-07-08'),
(3,2,'Episode 1: Secrets',52,'2019-08-01'),(4,2,'Episode 2: Betrayal',50,'2019-08-08'),
(5,3,'Episode 1: Crime Scene',48,'2018-09-01'),(6,3,'Episode 2: Investigation',52,'2018-09-08'),
(7,4,'Episode 1: Kingpins',55,'2019-10-01'),(8,4,'Episode 2: Power',50,'2019-10-08'),
(9,5,'Episode 1: Case Study',48,'2019-11-01'),(10,5,'Episode 2: Evidence',52,'2019-11-08'),
(11,6,'Episode 1: Village Life',45,'2020-01-01'),(12,6,'Episode 2: Challenges',47,'2020-01-08'),
(13,7,'Episode 1: Wedding Prep',42,'2019-03-01'),(14,7,'Episode 2: Conflicts',44,'2019-03-08'),
(15,8,'Episode 1: Spy Work',50,'2019-04-01'),(16,8,'Episode 2: Danger',52,'2019-04-08'),
(17,9,'Episode 1: Coaching',40,'2019-05-01'),(18,9,'Episode 2: Exams',42,'2019-05-08'),
(19,10,'Episode 1: Court Case',50,'2020-06-01'),(20,10,'Episode 2: Verdict',48,'2020-06-08'),
(21,11,'Part 1',50,'2020-07-01'),(22,11,'Part 2',55,'2020-07-08'),
(23,12,'Chapter 1',52,'2020-09-01'),(24,12,'Chapter 2',50,'2020-09-08'),
(25,13,'The Mission',48,'2021-01-01'),(26,13,'The Aftermath',52,'2021-01-08'),
(27,14,'Political Intrigue',55,'2019-10-01'),(28,14,'The Throne',50,'2019-10-08'),
(29,15,'Bank Heist',48,'2023-01-01'),(30,15,'The Escape',52,'2023-01-08'),
(31,16,'Episode A',45,'2020-01-01'),(32,16,'Episode B',47,'2020-01-08'),
(33,17,'The Wait',42,'2018-09-01'),(34,17,'The Reveal',44,'2018-09-08'),
(35,18,'The Arrival',50,'2020-05-01'),(36,18,'The Confrontation',52,'2020-05-08'),
(37,19,'Raktanchal S01 E01',40,'2020-05-28'),(38,19,'Raktanchal S01 E02',42,'2020-05-29'),
(39,20,'Tabbar S01 E01',50,'2021-10-15'),(40,20,'Tabbar S01 E02',48,'2021-10-22'),
(41,21,'Ray S01 E01',50,'2021-06-25'),(42,21,'Ray S01 E02',50,'2021-06-25'),
(43,22,'KBC S01 E01',60,'2023-08-14'),(44,22,'KBC S01 E02',60,'2023-08-15'),
(45,23,'Indian Idol S01 E01',60,'2023-10-07'),(46,23,'Indian Idol S01 E02',60,'2023-10-08'),
(47,24,'Super Singer S01 E01',60,'2023-10-21'),(48,24,'Super Singer S01 E02',60,'2023-10-22'),
(49,25,'Taj Mahal 1989 E01',35,'2020-02-14'),(50,25,'Taj Mahal 1989 E02',38,'2020-02-14'),
(51,26,'Sunflower E01',45,'2021-06-11'),(52,26,'Sunflower E02',45,'2021-06-11'),
(53,27,'Kahi Suni E01',30,'2021-05-01'),(54,27,'Kahi Suni E02',30,'2021-05-08'),
(55,28,'Taboo S01 E01',50,'2022-01-14'),(56,28,'Taboo S01 E02',50,'2022-01-21'),
(57,29,'Sacred Games S03 E01',50,'2020-05-15'),(58,29,'Sacred Games S03 E02',55,'2020-05-22'),
(59,30,'Mirzapur S03 E01',48,'2021-10-08'),(60,30,'Mirzapur S03 E02',52,'2021-10-15'),
(61,31,'Delhi Crime S02 E01',48,'2020-08-28'),(62,31,'Delhi Crime S02 E02',52,'2020-08-28'),
(63,32,'Panchayat S02 E01',45,'2021-05-20'),(64,32,'Panchayat S02 E02',47,'2021-05-20'),
(65,33,'Made in Heaven S02 E01',42,'2021-08-12'),(66,33,'Made in Heaven S02 E02',44,'2021-08-12'),
(67,34,'Family Man S02 E01',50,'2020-06-04'),(68,34,'Family Man S02 E02',52,'2020-06-11'),
(69,35,'Kota Factory S03 E01',40,'2021-09-24'),(70,35,'Kota Factory S03 E02',42,'2021-09-24'),
(71,36,'Criminal Justice S02 E01',50,'2021-04-30'),(72,36,'Criminal Justice S02 E02',48,'2021-05-07'),
(73,37,'Asur S02 E01',50,'2021-06-01'),(74,37,'Asur S02 E02',50,'2021-06-08'),
(75,38,'Special Ops S02 E01',45,'2023-02-15'),(76,38,'Special Ops S02 E02',47,'2023-02-22'),
(77,39,'Tandav S02 E01',42,'2021-07-30'),(78,39,'Tandav S02 E02',44,'2021-08-06'),
(79,40,'Farzi S02 E01',50,'2023-08-10'),(80,40,'Farzi S02 E02',52,'2023-08-17');


INSERT INTO watchlist VALUES
(1,1,1,'2025-01-01'),(2,1,2,'2025-01-03'),(3,2,3,'2025-01-05'),(4,2,4,'2025-01-07'),
(5,3,5,'2025-01-09'),(6,3,6,'2025-01-11'),(7,4,7,'2025-01-13'),(8,4,8,'2025-01-15'),
(9,5,9,'2025-01-17'),(10,5,10,'2025-01-19'),(11,6,11,'2025-01-21'),(12,6,12,'2025-01-23'),
(13,7,13,'2025-01-25'),(14,7,14,'2025-01-27'),(15,8,15,'2025-01-29'),(16,8,16,'2025-01-31'),
(17,9,17,'2025-02-02'),(18,9,18,'2025-02-04'),(19,10,19,'2025-02-06'),(20,10,20,'2025-02-08'),
(21,11,21,'2025-02-10'),(22,12,22,'2025-02-12'),(23,13,23,'2025-02-14'),(24,14,24,'2025-02-16'),
(25,15,25,'2025-02-18'),(26,16,26,'2025-02-20'),(27,17,27,'2025-02-22'),(28,18,28,'2025-02-24'),
(29,19,29,'2025-02-26'),(30,20,30,'2025-02-28'),(31,21,31,'2025-03-01'),(32,22,32,'2025-03-03'),
(33,23,33,'2025-03-05'),(34,24,34,'2025-03-07'),(35,25,35,'2025-03-09'),(36,26,36,'2025-03-11'),
(37,27,37,'2025-03-13'),(38,28,38,'2025-03-15'),(39,29,39,'2025-03-17'),(40,30,40,'2025-03-19'),
(41,31,41,'2025-03-21'),(42,32,42,'2025-03-23'),(43,33,43,'2025-03-25'),(44,34,44,'2025-03-27'),
(45,35,45,'2025-03-29'),(46,36,46,'2025-03-31'),(47,37,47,'2025-04-02'),(48,38,48,'2025-04-04'),
(49,39,49,'2025-04-06'),(50,40,50,'2025-04-08');

INSERT INTO watch_history VALUES
(1,'2025-01-01',100,1,1),(2,'2025-01-02',80,1,2),(3,'2025-01-03',90,2,3),
(4,'2025-01-04',100,2,4),(5,'2025-01-05',60,3,5),(6,'2025-01-06',70,3,6),
(7,'2025-01-07',50,4,7),(8,'2025-01-08',100,4,8),(9,'2025-01-09',40,5,9),
(10,'2025-01-10',80,5,10),
(11,'2025-01-11',100,6,11),(12,'2025-01-12',90,6,12),(13,'2025-01-13',100,7,13),
(14,'2025-01-14',85,7,14),(15,'2025-01-15',75,8,15),(16,'2025-01-16',100,8,16),
(17,'2025-01-17',60,9,17),(18,'2025-01-18',95,9,18),(19,'2025-01-19',100,10,19),
(20,'2025-01-20',50,10,20),
(21,'2025-01-21',100,11,21),(22,'2025-01-22',100,12,22),(23,'2025-01-23',100,13,23),
(24,'2025-01-24',100,14,24),(25,'2025-01-25',100,15,25),(26,'2025-01-26',100,16,26),
(27,'2025-01-27',100,17,27),(28,'2025-01-28',100,18,28),(29,'2025-01-29',100,19,29),
(30,'2025-01-30',100,20,30);


INSERT INTO ratings VALUES
(1,1,1,5,'Amazing!'),(2,1,2,4,'Great!'),(3,2,3,3,'Good'),(4,2,4,4,'Nice watch'),
(5,3,5,5,'Loved it'),(6,3,6,4,'Good movie'),(7,4,7,5,'Excellent'),(8,4,8,3,'Average'),
(9,5,9,4,'Nice'),(10,5,10,5,'Fantastic'),
(11,6,11,4,'Awesome'),(12,6,12,5,'Superb'),(13,7,13,5,'Action-packed'),(14,7,14,4,'Inspiring'),
(15,8,15,3,'Entertaining'),(16,8,16,5,'Must watch'),(17,9,17,4,'Funny'),(18,9,18,5,'Mindblowing'),
(19,10,19,3,'Decent'),(20,10,20,4,'Emotional'),
(21,11,21,5,'Intense'),(22,12,22,4,'Fun ride'),(23,13,23,5,'Heartwarming'),(24,14,24,3,'OK'),
(25,15,25,4,'Powerful'),(26,16,26,5,'Gritty'),(27,17,27,4,'Violent, but good'),(28,18,28,5,'True story!'),
(29,19,29,4,'Slice of life'),(30,20,30,5,'Romantic drama');

-- NEW TABLES DATA

INSERT INTO payment_history (User_Id, Amount, Payment_Method)
VALUES 
(1,299.99,'Credit Card'),
(2,499.99,'UPI'),
(3,199.99,'Debit Card'),
(4,299.99,'Credit Card'),
(5,699.99,'PayPal'),
(6,499.99,'UPI'),
(7,299.99,'Credit Card'),
(8,199.99,'Debit Card'),
(9,499.99,'UPI'),
(10,299.99,'Credit Card');

INSERT INTO device_info (User_Id, Device_Type, Device_Name)
VALUES
(1,'Mobile','iPhone 14'),(1,'TV','Samsung Smart TV'),(2,'Laptop','MacBook Air'),
(3,'Mobile','OnePlus 9'),(4,'Tablet','iPad Pro'),(5,'Smart TV','LG OLED TV'),
(6,'Laptop','Dell XPS'),(7,'Mobile','Samsung Galaxy S22'),(8,'TV','Sony Bravia'),
(9,'Mobile','Pixel 7'),(10,'Tablet','iPad Mini');

INSERT INTO parental_control (Profile_Id, Restriction_Level)
VALUES
(1,'Teen'),(2,'Adult'),(3,'Teen'),(4,'Adult'),(5,'Adult'),
(6,'Teen'),(7,'Adult'),(8,'Teen'),(9,'Adult'),(10,'Adult');

INSERT INTO notifications (User_Id, Message)
VALUES
(1,'Your subscription will expire in 3 days.'),
(2,'New series "Farzi" now streaming!'),
(3,'Your payment is successful.'),
(4,'New episode of "Mirzapur" added!'),
(5,'We have updated our privacy policy.'),
(6,'Try our new Premium Ultra plan!'),
(7,'Watch “Sacred Games” Season 3 now!'),
(8,'Your download limit has been reached.'),
(9,'Subscription renewed successfully.'),
(10,'Welcome back to Prime OTT!');

INSERT INTO subscription_renewal (User_Id, Renewal_Date, Amount, Payment_Method)
VALUES
(1,'2025-02-01',299.99,'Credit Card'),
(2,'2025-02-10',499.99,'UPI'),
(3,'2025-02-14',199.99,'Debit Card'),
(4,'2025-02-19',299.99,'Credit Card'),
(5,'2025-03-03',699.99,'PayPal');

INSERT INTO search_history (Profile_Id, Search_Query)
VALUES
(1,'Comedy movies'),(2,'Action series'),(3,'Romantic drama'),(4,'Family Man'),(5,'Sacred Games'),
(6,'Bahubali 2'),(7,'Mirzapur Season 3'),(8,'Kota Factory'),(9,'Farzi'),(10,'Gully Boy');

INSERT INTO recommendations (Profile_Id, Recommended_Content_Id, Reason)
VALUES
(1,8,'Because you watched 3 Idiots'),(2,26,'Similar to Mirzapur'),(3,15,'You liked Dangal'),
(4,37,'Trending thriller series'),(5,34,'New from your favorite genre'),(6,13,'Based on your watch history'),
(7,16,'Popular among teens'),(8,6,'Similar to your ratings'),(9,22,'Recommended for action lovers'),
(10,25,'New release this week');

INSERT INTO customer_support (User_Id, Issue_Type, Issue_Description)
VALUES
(1,'Payment','Transaction failed but money deducted'),
(3,'Login','Unable to login on TV'),
(5,'Playback','Video buffering issue'),
(7,'Subscription','Plan not renewed automatically'),
(9,'App','App crashing frequently');

INSERT INTO feedback (User_Id, Message, Rating)
VALUES
(1,'Excellent service!',5),
(2,'Good content but app crashes sometimes.',4),
(3,'Love the variety of shows.',5),
(4,'UI could be better.',3),
(5,'Great experience overall.',5);

-- =========================
-- 3. INITIAL UPDATE OF DERIVED COLUMNS
-- This populates Content_Rating and Total_Views based on the data inserted above.
-- =========================

-- Update Content_Rating
UPDATE content c
SET Content_Rating = (
    SELECT ROUND(AVG(r.Rating),2)
    FROM ratings r
    WHERE r.Content_Id = c.Content_Id
)
WHERE Content_Id IN (SELECT DISTINCT Content_Id FROM ratings);

-- Update Total_Views
UPDATE content c
SET Total_Views = (
    SELECT COUNT(w.History_Id)
    FROM watch_history w
    WHERE w.Content_Id = c.Content_Id
)
WHERE Content_Id IN (SELECT DISTINCT Content_Id FROM watch_history);

-- =========================
-- 4. TRIGGERS (MySQL DELIMITER syntax)
-- =========================
DELIMITER $$

-- 1. Update content rating after new rating
CREATE TRIGGER trg_update_content_rating
AFTER INSERT ON ratings
FOR EACH ROW
BEGIN
    UPDATE content
    SET Content_Rating = (
        SELECT ROUND(AVG(Rating),2)
        FROM ratings
        WHERE Content_Id = NEW.Content_Id
    )
    WHERE Content_Id = NEW.Content_Id;

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Rating Trigger', CONCAT('Updated rating for Content ID ', NEW.Content_Id));
END$$

-- 2. Increment total views after a watch
CREATE TRIGGER trg_increment_total_views
AFTER INSERT ON watch_history
FOR EACH ROW
BEGIN
    UPDATE content
    SET Total_Views = Total_Views + 1
    WHERE Content_Id = NEW.Content_Id;

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Watch Trigger', CONCAT('Incremented view count for Content ID ', NEW.Content_Id));
END$$

-- 3. Renew subscription automatically upon payment 
CREATE TRIGGER trg_subscription_renewal
AFTER INSERT ON payment_history
FOR EACH ROW
BEGIN
    UPDATE users
    SET Subscription_Start_Date = CURRENT_DATE(),
        Subscription_End_Date = DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
    WHERE User_Id = NEW.User_Id;

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Payment Trigger', CONCAT('Subscription renewed for User ID ', NEW.User_Id));
END$$

-- 4. Notify users when support ticket resolved
CREATE TRIGGER trg_customer_support_notification
AFTER UPDATE ON customer_support
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Resolved' AND OLD.Status != 'Resolved' THEN
        INSERT INTO notifications (User_Id, Message)
        VALUES (NEW.User_Id, CONCAT('Your support ticket #', NEW.Ticket_Id, ' has been resolved.'));
    END IF;

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Support Trigger', CONCAT('Support status updated for User ID ', NEW.User_Id));
END$$

-- =========================
-- 5. STORED PROCEDURES (MySQL DELIMITER syntax)
-- =========================

-- 1. Renew subscription manually
CREATE PROCEDURE sp_renew_subscription(IN p_user_id INT, IN p_payment_method VARCHAR(50))
BEGIN
    DECLARE plan_price DECIMAL(10,2);
    
    -- Get the price of the user's current subscription plan
    SELECT s.Price INTO plan_price 
    FROM users u
    JOIN subscription s ON u.Subscription_Id = s.Subscription_Id
    WHERE u.User_Id = p_user_id;
    
    -- Insert payment history (which triggers subscription renewal via trg_subscription_renewal)
    INSERT INTO payment_history (User_Id, Amount, Payment_Method) 
    VALUES (p_user_id, plan_price, p_payment_method);

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Procedure', CONCAT('Manual renewal completed for User ID ', p_user_id));
END$$

-- 2. Generate recommendations for a profile (based on most watched genre)
CREATE PROCEDURE sp_generate_recommendations(IN p_profile_id INT)
BEGIN
    DECLARE v_most_watched_genre_id INT;

    -- Find the most watched Genre_Id for the profile
    SELECT c.Genre_Id INTO v_most_watched_genre_id
    FROM watch_history w
    JOIN content c ON w.Content_Id = c.Content_Id
    WHERE w.Profile_Id = p_profile_id
    GROUP BY c.Genre_Id
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    -- Insert recommendations based on the most watched genre, excluding already watched or recommended content
    INSERT INTO recommendations (Profile_Id, Recommended_Content_Id, Reason)
    SELECT p_profile_id, c.Content_Id, 'Based on your most watched genre'
    FROM content c
    WHERE c.Genre_Id = v_most_watched_genre_id
    AND c.Content_Id NOT IN (
        SELECT Recommended_Content_Id FROM recommendations WHERE Profile_Id = p_profile_id
        UNION
        SELECT Content_Id FROM watch_history WHERE Profile_Id = p_profile_id
    )
    LIMIT 3;

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Procedure', CONCAT('Recommendations generated for Profile ID ', p_profile_id));
END$$

-- 3. Add new feedback
CREATE PROCEDURE sp_add_feedback(IN p_user_id INT, IN p_message TEXT, IN p_rating INT)
BEGIN
    INSERT INTO feedback (User_Id, Message, Rating)
    VALUES (p_user_id, p_message, p_rating);

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Procedure', CONCAT('Feedback added for User ID ', p_user_id));
END$$

-- 4. View user watch summary
CREATE PROCEDURE sp_user_watch_summary(IN p_user_id INT)
BEGIN
    SELECT u.Name AS User_Name, p.Name AS Profile_Name, c.Title AS Content_Title, w.Progress
    FROM watch_history w
    JOIN profiles p ON w.Profile_Id = p.Profile_Id
    JOIN users u ON p.User_Id = u.User_Id
    JOIN content c ON w.Content_Id = c.Content_Id
    WHERE u.User_Id = p_user_id
    ORDER BY w.Watch_Date DESC;
END$$

-- 5. Register a support ticket
CREATE PROCEDURE sp_create_support_ticket(IN p_user_id INT, IN p_issue_type VARCHAR(100), IN p_desc TEXT)
BEGIN
    INSERT INTO customer_support (User_Id, Issue_Type, Issue_Description)
    VALUES (p_user_id, p_issue_type, p_desc);

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Procedure', CONCAT('New support ticket created for User ID ', p_user_id));
END$$

-- 6. Close expired subscriptions
CREATE PROCEDURE sp_close_expired_subscriptions()
BEGIN
    UPDATE users
    SET Subscription_Id = NULL,
        Subscription_End_Date = NULL -- Clear end date for clarity
    WHERE Subscription_End_Date < CURRENT_DATE()
    AND Subscription_Id IS NOT NULL;

    INSERT INTO trigger_logs (Log_Type, Description)
    VALUES ('Procedure', 'Expired subscriptions cleared.');
END$$

DELIMITER ;

