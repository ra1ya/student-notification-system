-- Student Notification Mobile System
-- Sanitized demo database for portfolio/local development
-- Database name expected by the current PHP backend: chat

CREATE DATABASE IF NOT EXISTS `chat`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `chat`;

DROP TABLE IF EXISTS `messages`;
DROP TABLE IF EXISTS `student`;
DROP TABLE IF EXISTS `admin`;

CREATE TABLE `admin` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `dep` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admin_username_unique` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `fullname` varchar(255) NOT NULL,
  `dep` varchar(100) NOT NULL,
  `level` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `messages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `mess` text NOT NULL,
  `dep` varchar(100) NOT NULL,
  `level` varchar(20) NOT NULL,
  `times` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `messages_dep_level_index` (`dep`, `level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Demo-only accounts/data. Password for demo_admin: password
-- The password is stored as a bcrypt hash, not plaintext.
INSERT INTO `admin` (`username`, `password`, `dep`) VALUES
('demo_admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'IT');

INSERT INTO `student` (`code`, `fullname`, `dep`, `level`) VALUES
('10001', 'Demo Student One', 'IT', 'L1'),
('10002', 'Demo Student Two', 'IT', 'L2');

INSERT INTO `messages` (`mess`, `dep`, `level`, `times`) VALUES
('Welcome to the Student Notification System demo.', 'IT', 'all', '2026 August 22'),
('L1 students: your demo lecture starts at 10:00 AM.', 'IT', 'L1', '2026 August 22');
