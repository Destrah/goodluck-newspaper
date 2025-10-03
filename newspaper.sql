-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table maindata.newspaper
CREATE TABLE IF NOT EXISTS `newspaper` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL,
  `subtitle` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL,
  `body` longtext CHARACTER SET utf8mb4,
  `titletype` int DEFAULT NULL,
  `subtitletype` int DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

-- Dumping data for table maindata.newspaper: ~7 rows (approximately)
INSERT INTO `newspaper` (`id`, `title`, `subtitle`, `body`, `titletype`, `subtitletype`) VALUES
	(1, 'Available', 'Available', 'Available', 1, 3),
	(2, 'Available', 'Available', 'Available', 1, 3),
	(3, 'Available', 'Available', 'Available', 1, 3),
	(4, 'Available', 'Available', 'Available', 1, 3),
	(5, 'Available', 'Available', 'Available', 1, 3),
	(6, 'Available', 'Available', 'Available', 1, 3),
	(7, 'Available', 'Available', 'Available', 1, 3);

-- Dumping structure for table maindata.newspaper_motd
CREATE TABLE IF NOT EXISTS `newspaper_motd` (
  `id` int DEFAULT NULL,
  `message` text
);

-- Dumping data for table maindata.newspaper_motd: ~0 rows (approximately)
INSERT INTO `newspaper_motd` (`id`, `message`) VALUES
	(1, 'Placeholder');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
