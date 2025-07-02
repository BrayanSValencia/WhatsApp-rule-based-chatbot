-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: medicalappointment
-- ------------------------------------------------------
-- Server version	8.4.4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointmentstate`
--

DROP TABLE IF EXISTS `appointmentstate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointmentstate` (
  `id` int NOT NULL AUTO_INCREMENT,
  `state` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointmentstate`
--

LOCK TABLES `appointmentstate` WRITE;
/*!40000 ALTER TABLE `appointmentstate` DISABLE KEYS */;
INSERT INTO `appointmentstate` VALUES (1,'Scheduled'),(2,'Completed'),(3,'Canceled'),(4,'Free');
/*!40000 ALTER TABLE `appointmentstate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor`
--

DROP TABLE IF EXISTS `doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dni` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `start_shift` time NOT NULL,
  `end_shift` time NOT NULL,
  `start_break` time DEFAULT NULL,
  `end_break` time DEFAULT NULL,
  `day_off_id` tinyint DEFAULT NULL,
  `specialty_id` int NOT NULL,
  `document_type_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `specialty_id` (`specialty_id`),
  KEY `document_type_id` (`document_type_id`),
  KEY `day_off_id` (`day_off_id`),
  CONSTRAINT `doctor_ibfk_1` FOREIGN KEY (`specialty_id`) REFERENCES `specialty` (`id`),
  CONSTRAINT `doctor_ibfk_2` FOREIGN KEY (`document_type_id`) REFERENCES `documenttype` (`id`),
  CONSTRAINT `doctor_ibfk_3` FOREIGN KEY (`day_off_id`) REFERENCES `week_days` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor`
--

LOCK TABLES `doctor` WRITE;
/*!40000 ALTER TABLE `doctor` DISABLE KEYS */;
INSERT INTO `doctor` VALUES (1,'1234567890','Laura','Gonzalez',1,'08:00:00','14:00:00','12:00:00','13:00:00',1,1,1),(2,'9876543210','Carlos','Martinez',1,'10:00:00','18:00:00','14:00:00','15:00:00',2,1,1),(3,'4567891230','Ana','Lopez',1,'09:00:00','15:00:00','12:30:00','13:30:00',3,2,2);
/*!40000 ALTER TABLE `doctor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctoragenda`
--

DROP TABLE IF EXISTS `doctoragenda`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctoragenda` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` int NOT NULL,
  `appointment_state_id` int NOT NULL,
  `time_slot` datetime NOT NULL,
  `notes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `appointment_state_id` (`appointment_state_id`),
  CONSTRAINT `doctoragenda_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`),
  CONSTRAINT `doctoragenda_ibfk_2` FOREIGN KEY (`appointment_state_id`) REFERENCES `appointmentstate` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=205 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctoragenda`
--

LOCK TABLES `doctoragenda` WRITE;
/*!40000 ALTER TABLE `doctoragenda` DISABLE KEYS */;
INSERT INTO `doctoragenda` VALUES (1,1,4,'2025-06-24 08:00:00',NULL),(2,1,4,'2025-06-24 08:30:00',NULL),(3,1,4,'2025-06-24 09:00:00',NULL),(4,1,4,'2025-06-24 09:30:00',NULL),(5,1,4,'2025-06-24 10:00:00',NULL),(6,1,4,'2025-06-24 10:30:00',NULL),(7,1,4,'2025-06-24 11:00:00',NULL),(8,1,4,'2025-06-24 11:30:00',NULL),(9,1,4,'2025-06-24 13:00:00',NULL),(10,1,4,'2025-06-24 13:30:00',NULL),(11,1,4,'2025-06-25 08:00:00',NULL),(12,1,4,'2025-06-25 08:30:00',NULL),(13,1,4,'2025-06-25 09:00:00',NULL),(14,1,4,'2025-06-25 09:30:00',NULL),(15,1,4,'2025-06-25 10:00:00',NULL),(16,1,4,'2025-06-25 10:30:00',NULL),(17,1,4,'2025-06-25 11:00:00',NULL),(18,1,4,'2025-06-25 11:30:00',NULL),(19,1,4,'2025-06-25 13:00:00',NULL),(20,1,4,'2025-06-25 13:30:00',NULL),(21,1,4,'2025-06-26 08:00:00',NULL),(22,1,4,'2025-06-26 08:30:00',NULL),(23,1,4,'2025-06-26 09:00:00',NULL),(24,1,4,'2025-06-26 09:30:00',NULL),(25,1,4,'2025-06-26 10:00:00',NULL),(26,1,4,'2025-06-26 10:30:00',NULL),(27,1,4,'2025-06-26 11:00:00',NULL),(28,1,4,'2025-06-26 11:30:00',NULL),(29,1,4,'2025-06-26 13:00:00',NULL),(30,1,4,'2025-06-26 13:30:00',NULL),(31,1,4,'2025-06-27 08:00:00',NULL),(32,1,4,'2025-06-27 08:30:00',NULL),(33,1,4,'2025-06-27 09:00:00',NULL),(34,1,4,'2025-06-27 09:30:00',NULL),(35,1,4,'2025-06-27 10:00:00',NULL),(36,1,4,'2025-06-27 10:30:00',NULL),(37,1,4,'2025-06-27 11:00:00',NULL),(38,1,4,'2025-06-27 11:30:00',NULL),(39,1,4,'2025-06-27 13:00:00',NULL),(40,1,4,'2025-06-27 13:30:00',NULL),(41,1,4,'2025-06-28 08:00:00',NULL),(42,1,4,'2025-06-28 08:30:00',NULL),(43,1,4,'2025-06-28 09:00:00',NULL),(44,1,4,'2025-06-28 09:30:00',NULL),(45,1,4,'2025-06-28 10:00:00',NULL),(46,1,4,'2025-06-28 10:30:00',NULL),(47,1,4,'2025-06-28 11:00:00',NULL),(48,1,4,'2025-06-28 11:30:00',NULL),(49,1,4,'2025-06-28 13:00:00',NULL),(50,1,4,'2025-06-28 13:30:00',NULL),(51,1,4,'2025-06-29 08:00:00',NULL),(52,1,4,'2025-06-29 08:30:00',NULL),(53,1,4,'2025-06-29 09:00:00',NULL),(54,1,4,'2025-06-29 09:30:00',NULL),(55,1,4,'2025-06-29 10:00:00',NULL),(56,1,4,'2025-06-29 10:30:00',NULL),(57,1,4,'2025-06-29 11:00:00',NULL),(58,1,4,'2025-06-29 11:30:00',NULL),(59,1,4,'2025-06-29 13:00:00',NULL),(60,1,4,'2025-06-29 13:30:00',NULL),(61,2,4,'2025-06-25 10:00:00',NULL),(62,2,4,'2025-06-25 10:30:00',NULL),(63,2,4,'2025-06-25 11:00:00',NULL),(64,2,4,'2025-06-25 11:30:00',NULL),(65,2,4,'2025-06-25 12:00:00',NULL),(66,2,4,'2025-06-25 12:30:00',NULL),(67,2,4,'2025-06-25 13:00:00',NULL),(68,2,4,'2025-06-25 13:30:00',NULL),(69,2,4,'2025-06-25 15:00:00',NULL),(70,2,4,'2025-06-25 15:30:00',NULL),(71,2,4,'2025-06-25 16:00:00',NULL),(72,2,4,'2025-06-25 16:30:00',NULL),(73,2,4,'2025-06-25 17:00:00',NULL),(74,2,4,'2025-06-25 17:30:00',NULL),(75,2,4,'2025-06-26 10:00:00',NULL),(76,2,4,'2025-06-26 10:30:00',NULL),(77,2,4,'2025-06-26 11:00:00',NULL),(78,2,4,'2025-06-26 11:30:00',NULL),(79,2,4,'2025-06-26 12:00:00',NULL),(80,2,4,'2025-06-26 12:30:00',NULL),(81,2,4,'2025-06-26 13:00:00',NULL),(82,2,4,'2025-06-26 13:30:00',NULL),(83,2,4,'2025-06-26 15:00:00',NULL),(84,2,4,'2025-06-26 15:30:00',NULL),(85,2,4,'2025-06-26 16:00:00',NULL),(86,2,4,'2025-06-26 16:30:00',NULL),(87,2,4,'2025-06-26 17:00:00',NULL),(88,2,4,'2025-06-26 17:30:00',NULL),(89,2,4,'2025-06-27 10:00:00',NULL),(90,2,4,'2025-06-27 10:30:00',NULL),(91,2,4,'2025-06-27 11:00:00',NULL),(92,2,4,'2025-06-27 11:30:00',NULL),(93,2,4,'2025-06-27 12:00:00',NULL),(94,2,4,'2025-06-27 12:30:00',NULL),(95,2,4,'2025-06-27 13:00:00',NULL),(96,2,4,'2025-06-27 13:30:00',NULL),(97,2,4,'2025-06-27 15:00:00',NULL),(98,2,4,'2025-06-27 15:30:00',NULL),(99,2,4,'2025-06-27 16:00:00',NULL),(100,2,4,'2025-06-27 16:30:00',NULL),(101,2,4,'2025-06-27 17:00:00',NULL),(102,2,4,'2025-06-27 17:30:00',NULL),(103,2,4,'2025-06-28 10:00:00',NULL),(104,2,4,'2025-06-28 10:30:00',NULL),(105,2,4,'2025-06-28 11:00:00',NULL),(106,2,4,'2025-06-28 11:30:00',NULL),(107,2,4,'2025-06-28 12:00:00',NULL),(108,2,4,'2025-06-28 12:30:00',NULL),(109,2,4,'2025-06-28 13:00:00',NULL),(110,2,4,'2025-06-28 13:30:00',NULL),(111,2,4,'2025-06-28 15:00:00',NULL),(112,2,4,'2025-06-28 15:30:00',NULL),(113,2,4,'2025-06-28 16:00:00',NULL),(114,2,4,'2025-06-28 16:30:00',NULL),(115,2,4,'2025-06-28 17:00:00',NULL),(116,2,4,'2025-06-28 17:30:00',NULL),(117,2,4,'2025-06-29 10:00:00',NULL),(118,2,4,'2025-06-29 10:30:00',NULL),(119,2,4,'2025-06-29 11:00:00',NULL),(120,2,4,'2025-06-29 11:30:00',NULL),(121,2,4,'2025-06-29 12:00:00',NULL),(122,2,4,'2025-06-29 12:30:00',NULL),(123,2,4,'2025-06-29 13:00:00',NULL),(124,2,4,'2025-06-29 13:30:00',NULL),(125,2,4,'2025-06-29 15:00:00',NULL),(126,2,4,'2025-06-29 15:30:00',NULL),(127,2,4,'2025-06-29 16:00:00',NULL),(128,2,4,'2025-06-29 16:30:00',NULL),(129,2,4,'2025-06-29 17:00:00',NULL),(130,2,4,'2025-06-29 17:30:00',NULL),(131,2,4,'2025-06-30 10:00:00',NULL),(132,2,4,'2025-06-30 10:30:00',NULL),(133,2,4,'2025-06-30 11:00:00',NULL),(134,2,4,'2025-06-30 11:30:00',NULL),(135,2,4,'2025-06-30 12:00:00',NULL),(136,2,4,'2025-06-30 12:30:00',NULL),(137,2,4,'2025-06-30 13:00:00',NULL),(138,2,4,'2025-06-30 13:30:00',NULL),(139,2,4,'2025-06-30 15:00:00',NULL),(140,2,4,'2025-06-30 15:30:00',NULL),(141,2,4,'2025-06-30 16:00:00',NULL),(142,2,4,'2025-06-30 16:30:00',NULL),(143,2,4,'2025-06-30 17:00:00',NULL),(144,2,4,'2025-06-30 17:30:00',NULL),(145,3,4,'2025-06-24 09:00:00',NULL),(146,3,4,'2025-06-24 09:30:00',NULL),(147,3,4,'2025-06-24 10:00:00',NULL),(148,3,4,'2025-06-24 10:30:00',NULL),(149,3,4,'2025-06-24 11:00:00',NULL),(150,3,4,'2025-06-24 11:30:00',NULL),(151,3,4,'2025-06-24 12:00:00',NULL),(152,3,4,'2025-06-24 13:30:00',NULL),(153,3,4,'2025-06-24 14:00:00',NULL),(154,3,4,'2025-06-24 14:30:00',NULL),(155,3,4,'2025-06-26 09:00:00',NULL),(156,3,4,'2025-06-26 09:30:00',NULL),(157,3,4,'2025-06-26 10:00:00',NULL),(158,3,4,'2025-06-26 10:30:00',NULL),(159,3,4,'2025-06-26 11:00:00',NULL),(160,3,4,'2025-06-26 11:30:00',NULL),(161,3,4,'2025-06-26 12:00:00',NULL),(162,3,4,'2025-06-26 13:30:00',NULL),(163,3,4,'2025-06-26 14:00:00',NULL),(164,3,4,'2025-06-26 14:30:00',NULL),(165,3,4,'2025-06-27 09:00:00',NULL),(166,3,4,'2025-06-27 09:30:00',NULL),(167,3,4,'2025-06-27 10:00:00',NULL),(168,3,4,'2025-06-27 10:30:00',NULL),(169,3,4,'2025-06-27 11:00:00',NULL),(170,3,4,'2025-06-27 11:30:00',NULL),(171,3,4,'2025-06-27 12:00:00',NULL),(172,3,4,'2025-06-27 13:30:00',NULL),(173,3,4,'2025-06-27 14:00:00',NULL),(174,3,4,'2025-06-27 14:30:00',NULL),(175,3,4,'2025-06-28 09:00:00',NULL),(176,3,4,'2025-06-28 09:30:00',NULL),(177,3,4,'2025-06-28 10:00:00',NULL),(178,3,4,'2025-06-28 10:30:00',NULL),(179,3,4,'2025-06-28 11:00:00',NULL),(180,3,4,'2025-06-28 11:30:00',NULL),(181,3,4,'2025-06-28 12:00:00',NULL),(182,3,4,'2025-06-28 13:30:00',NULL),(183,3,4,'2025-06-28 14:00:00',NULL),(184,3,4,'2025-06-28 14:30:00',NULL),(185,3,4,'2025-06-29 09:00:00',NULL),(186,3,4,'2025-06-29 09:30:00',NULL),(187,3,4,'2025-06-29 10:00:00',NULL),(188,3,4,'2025-06-29 10:30:00',NULL),(189,3,4,'2025-06-29 11:00:00',NULL),(190,3,4,'2025-06-29 11:30:00',NULL),(191,3,4,'2025-06-29 12:00:00',NULL),(192,3,4,'2025-06-29 13:30:00',NULL),(193,3,4,'2025-06-29 14:00:00',NULL),(194,3,4,'2025-06-29 14:30:00',NULL),(195,3,4,'2025-06-30 09:00:00',NULL),(196,3,4,'2025-06-30 09:30:00',NULL),(197,3,4,'2025-06-30 10:00:00',NULL),(198,3,4,'2025-06-30 10:30:00',NULL),(199,3,4,'2025-06-30 11:00:00',NULL),(200,3,4,'2025-06-30 11:30:00',NULL),(201,3,4,'2025-06-30 12:00:00',NULL),(202,3,4,'2025-06-30 13:30:00',NULL),(203,3,4,'2025-06-30 14:00:00',NULL),(204,3,4,'2025-06-30 14:30:00',NULL);
/*!40000 ALTER TABLE `doctoragenda` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documenttype`
--

DROP TABLE IF EXISTS `documenttype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documenttype` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documenttype`
--

LOCK TABLES `documenttype` WRITE;
/*!40000 ALTER TABLE `documenttype` DISABLE KEYS */;
INSERT INTO `documenttype` VALUES (1,'CC'),(2,'TI'),(3,'Passport');
/*!40000 ALTER TABLE `documenttype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `specialty`
--

DROP TABLE IF EXISTS `specialty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `specialty` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `specialty`
--

LOCK TABLES `specialty` WRITE;
/*!40000 ALTER TABLE `specialty` DISABLE KEYS */;
INSERT INTO `specialty` VALUES (1,'General Medicine'),(2,'Cardiology'),(3,'Dermatology'),(4,'Pediatrics');
/*!40000 ALTER TABLE `specialty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dni` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `document_type_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `document_type_id` (`document_type_id`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`document_type_id`) REFERENCES `documenttype` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'3216549870','Luis','Rodriguez',1,1),(2,'7418529630','Camila','Torres',1,2);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userappointments`
--

DROP TABLE IF EXISTS `userappointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `userappointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `doctor_agenda_id` int NOT NULL,
  `booked_datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `doctor_agenda_id` (`doctor_agenda_id`),
  CONSTRAINT `userappointments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `userappointments_ibfk_2` FOREIGN KEY (`doctor_agenda_id`) REFERENCES `doctoragenda` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userappointments`
--

LOCK TABLES `userappointments` WRITE;
/*!40000 ALTER TABLE `userappointments` DISABLE KEYS */;
/*!40000 ALTER TABLE `userappointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `week_days`
--

DROP TABLE IF EXISTS `week_days`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `week_days` (
  `id` tinyint NOT NULL AUTO_INCREMENT,
  `name` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `week_days`
--

LOCK TABLES `week_days` WRITE;
/*!40000 ALTER TABLE `week_days` DISABLE KEYS */;
INSERT INTO `week_days` VALUES (1,'Monday'),(2,'Tuesday'),(3,'Wednesday'),(4,'Thursday'),(5,'Friday'),(6,'Saturday'),(7,'Sunday');
/*!40000 ALTER TABLE `week_days` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-01 23:06:41
