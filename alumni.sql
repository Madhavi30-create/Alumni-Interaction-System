-- ============================================
-- COLLEGE ALUMNI INTERACTION SYSTEM DATABASE
-- Focus: Profile Evaluation & Privacy
-- ============================================

-- Drop and recreate database (for clean setup)
DROP DATABASE IF EXISTS AlumniDB;
CREATE DATABASE AlumniDB;
USE AlumniDB;

-- ============================================
-- 1. USERS TABLE (CORE + PRIVACY)
-- ============================================
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'alumni', 'admin') DEFAULT 'student',
    graduation_year INT,
    branch VARCHAR(50),
    current_company VARCHAR(100),
    designation VARCHAR(100),

    -- Privacy
    profile_visibility ENUM('public', 'alumni_only', 'private') DEFAULT 'alumni_only',
    email_visibility BOOLEAN DEFAULT FALSE,
    profile_photo_visibility BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. ALUMNI PROFILES
-- ============================================
CREATE TABLE AlumniProfiles (
    alumni_id INT PRIMARY KEY,
    bio TEXT,
    linkedin_url VARCHAR(255),
    skills TEXT,
    achievements TEXT,
    FOREIGN KEY (alumni_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 3. STUDENT PROFILES
-- ============================================
CREATE TABLE StudentProfiles (
    student_id INT PRIMARY KEY,
    interests TEXT,
    resume_link VARCHAR(255),
    FOREIGN KEY (student_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 4. PROFILE RATINGS (EVALUATION)
-- ============================================
CREATE TABLE ProfileRatings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    reviewer_id INT,
    reviewed_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (reviewer_id) REFERENCES Users(user_id),
    FOREIGN KEY (reviewed_id) REFERENCES Users(user_id)
);

-- ============================================
-- 5. ENDORSEMENTS
-- ============================================
CREATE TABLE Endorsements (
    endorsement_id INT AUTO_INCREMENT PRIMARY KEY,
    endorser_id INT,
    endorsed_id INT,
    skill VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (endorser_id) REFERENCES Users(user_id),
    FOREIGN KEY (endorsed_id) REFERENCES Users(user_id)
);

-- ============================================
-- 6. CONNECTIONS
-- ============================================
CREATE TABLE Connections (
    connection_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT,
    receiver_id INT,
    status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',

    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);

-- ============================================
-- 7. MESSAGES
-- ============================================
CREATE TABLE Messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT,
    receiver_id INT,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);

-- ============================================
-- 8. PRIVACY SETTINGS
-- ============================================
CREATE TABLE PrivacySettings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    allow_messages BOOLEAN DEFAULT TRUE,
    allow_profile_view BOOLEAN DEFAULT TRUE,
    allow_search BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 9. SAMPLE DATA
-- ============================================
INSERT INTO Users (full_name, email, password_hash, role, graduation_year, branch, current_company, designation)
VALUES
('Amit Sharma', 'amit@gmail.com', 'hashed123', 'alumni', 2020, 'CSE', 'Google', 'Software Engineer'),
('Riya Gupta', 'riya@gmail.com', 'hashed456', 'student', 2024, 'IT', NULL, NULL);

INSERT INTO AlumniProfiles (alumni_id, bio, linkedin_url, skills, achievements)
VALUES
(1, 'Working at Google', 'linkedin.com/amit', 'Java, AI, Cloud', 'Top Performer 2022');

INSERT INTO StudentProfiles (student_id, interests, resume_link)
VALUES
(2, 'AI, Web Development', 'resume_link_here');

INSERT INTO ProfileRatings (reviewer_id, reviewed_id, rating, feedback)
VALUES
(2, 1, 5, 'Very helpful mentor');

INSERT INTO Endorsements (endorser_id, endorsed_id, skill)
VALUES
(2, 1, 'Java');

INSERT INTO PrivacySettings (user_id)
VALUES
(1), (2);

-- ============================================
-- 10. TEST QUERIES
-- ============================================

-- View Users
SELECT * FROM Users;

-- Average Rating
SELECT reviewed_id, AVG(rating) AS avg_rating
FROM ProfileRatings
GROUP BY reviewed_id;

-- Privacy-based Profile View
SELECT u.user_id, u.full_name, u.branch, u.current_company
FROM Users u
JOIN PrivacySettings p ON u.user_id = p.user_id
WHERE 
    u.profile_visibility = 'public'
    OR (u.profile_visibility = 'alumni_only' AND u.role = 'alumni')
    OR (u.user_id = 2);

-- ============================================
-- END OF SCRIPT
-- ============================================