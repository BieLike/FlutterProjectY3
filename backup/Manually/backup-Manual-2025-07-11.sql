-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: dbcpr
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tbauthor`
--

DROP TABLE IF EXISTS `tbauthor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbauthor` (
  `authorID` int(11) NOT NULL,
  `name` varchar(23) NOT NULL,
  PRIMARY KEY (`authorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbauthor`
--

LOCK TABLES `tbauthor` WRITE;
/*!40000 ALTER TABLE `tbauthor` DISABLE KEYS */;
INSERT INTO `tbauthor` VALUES (1,'Eiichiro Oda'),(2,'Hideo Kojima');
/*!40000 ALTER TABLE `tbauthor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbbooks`
--

DROP TABLE IF EXISTS `tbbooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbbooks` (
  `BID` int(8) NOT NULL,
  `Bname` varchar(50) NOT NULL,
  `Bpage` int(5) NOT NULL,
  `Bprice` varchar(10) NOT NULL,
  PRIMARY KEY (`BID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbbooks`
--

LOCK TABLES `tbbooks` WRITE;
/*!40000 ALTER TABLE `tbbooks` DISABLE KEYS */;
INSERT INTO `tbbooks` VALUES (112,'Flutter',225,'225000'),(117,'SQL',335,'335000'),(1112,'Hello WAR 2021 Last ',15000000,'300'),(1123,'Hello WAR 2021',752000,'225'),(1156,'Hello WAR 2021 Last ',300,'15000000');
/*!40000 ALTER TABLE `tbbooks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbcategory`
--

DROP TABLE IF EXISTS `tbcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbcategory` (
  `CategoryID` varchar(15) NOT NULL,
  `CategoryName` varchar(30) NOT NULL,
  PRIMARY KEY (`CategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbcategory`
--

LOCK TABLES `tbcategory` WRITE;
/*!40000 ALTER TABLE `tbcategory` DISABLE KEYS */;
INSERT INTO `tbcategory` VALUES ('1230','book'),('13','Nawatniyai'),('Fd1112','Food'),('Wtr1111','Water');
/*!40000 ALTER TABLE `tbcategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbproduct`
--

DROP TABLE IF EXISTS `tbproduct`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbproduct` (
  `ProductID` varchar(15) NOT NULL,
  `ProductName` varchar(50) NOT NULL,
  `Quantity` int(5) NOT NULL,
  `ImportPrice` int(7) NOT NULL,
  `SellPrice` int(7) NOT NULL,
  `UnitID` varchar(15) NOT NULL,
  `CategoryID` varchar(15) NOT NULL,
  `authorsID` int(11) NOT NULL,
  `Balance` int(5) NOT NULL,
  `Level` int(5) NOT NULL,
  PRIMARY KEY (`ProductID`),
  KEY `UnitID` (`UnitID`,`CategoryID`),
  KEY `CID` (`CategoryID`),
  KEY `AID` (`authorsID`),
  CONSTRAINT `AID` FOREIGN KEY (`authorsID`) REFERENCES `tbauthor` (`authorID`),
  CONSTRAINT `CID` FOREIGN KEY (`CategoryID`) REFERENCES `tbcategory` (`CategoryID`) ON UPDATE CASCADE,
  CONSTRAINT `UID` FOREIGN KEY (`UnitID`) REFERENCES `tbunit` (`UnitID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbproduct`
--

LOCK TABLES `tbproduct` WRITE;
/*!40000 ALTER TABLE `tbproduct` DISABLE KEYS */;
INSERT INTO `tbproduct` VALUES ('Kpo1112','Kraprao_Freeze',256,33000,37000,'14','1230',2,270,5),('Kpo1119','Kraprao_fatasses',79,33000,37000,'Bg1112','Fd1112',1,100,5),('Kpo1155','Kraprao_fastest',85,33000,37000,'Bg1112','Fd1112',1,85,5),('l2','vhf',5,8,1,'15','Wtr1111',1,0,5),('Lay1111','Lay_Original_Big_Bag',115,15000,18000,'Bg1112','Fd1112',1,131,10),('Ois1114','Oishi_small',112,12000,15000,'bt1115','Wtr1111',1,116,10),('Tgh1111','Tiger_Head_Big',120,8000,10000,'bt1115','Wtr1111',1,123,5);
/*!40000 ALTER TABLE `tbproduct` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbrole`
--

DROP TABLE IF EXISTS `tbrole`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbrole` (
  `RID` int(5) NOT NULL AUTO_INCREMENT,
  `RoleName` varchar(20) DEFAULT NULL,
  `BaseSalary` int(8) DEFAULT NULL,
  PRIMARY KEY (`RID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbrole`
--

LOCK TABLES `tbrole` WRITE;
/*!40000 ALTER TABLE `tbrole` DISABLE KEYS */;
INSERT INTO `tbrole` VALUES (1,'Cashier',2500000),(2,'Admin',3500000),(5,'Stocker',2000);
/*!40000 ALTER TABLE `tbrole` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbsupplier`
--

DROP TABLE IF EXISTS `tbsupplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbsupplier` (
  `SupplierID` int(11) NOT NULL AUTO_INCREMENT,
  `SupplierName` varchar(100) NOT NULL,
  `ContactPerson` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Address` text DEFAULT NULL,
  `Status` enum('Active','Inactive') DEFAULT 'Active',
  `CreatedDate` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`SupplierID`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbsupplier`
--

LOCK TABLES `tbsupplier` WRITE;
/*!40000 ALTER TABLE `tbsupplier` DISABLE KEYS */;
INSERT INTO `tbsupplier` VALUES (101,'Cityplex','Hasann','2022136258','Maile@email.com','lao, Laos','Inactive','2025-05-27 12:26:35'),(102,'Maxza','Maxy','2058384765','Maxlnwza004@gmail.com','Khoihong','Active','2025-05-27 12:32:16');
/*!40000 ALTER TABLE `tbsupplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbunit`
--

DROP TABLE IF EXISTS `tbunit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbunit` (
  `UnitID` varchar(15) NOT NULL,
  `UnitName` varchar(30) NOT NULL,
  PRIMARY KEY (`UnitID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbunit`
--

LOCK TABLES `tbunit` WRITE;
/*!40000 ALTER TABLE `tbunit` DISABLE KEYS */;
INSERT INTO `tbunit` VALUES ('14','ຫົວ'),('15','Ted'),('2221','ແພັກ'),('Bg1112','Bag'),('bt1115','Bottle');
/*!40000 ALTER TABLE `tbunit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbuser`
--

DROP TABLE IF EXISTS `tbuser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbuser` (
  `UID` int(8) NOT NULL AUTO_INCREMENT,
  `UserFname` varchar(20) NOT NULL,
  `UserLname` varchar(20) NOT NULL,
  `DateOfBirth` varchar(15) NOT NULL,
  `Gender` varchar(10) NOT NULL,
  `Phone` int(15) NOT NULL,
  `Email` varchar(20) NOT NULL,
  `Position` int(5) NOT NULL,
  `UserPassword` varchar(30) NOT NULL,
  PRIMARY KEY (`UID`),
  KEY `Position` (`Position`),
  CONSTRAINT `Position` FOREIGN KEY (`Position`) REFERENCES `tbrole` (`RID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbuser`
--

LOCK TABLES `tbuser` WRITE;
/*!40000 ALTER TABLE `tbuser` DISABLE KEYS */;
INSERT INTO `tbuser` VALUES (1,'Sanhsaveng','KeoKham','18/07/2013','ຍິງ',123,'Sanhsaveng@gmail.com',2,'123'),(2,'Test','Subject','2011-11-11','ຊາຍ',1,'TestSubject@gmail.co',1,'1'),(7,'tes','tesin','11/07/2002','ຍິງ',2,'Tes@gmail.com',5,'2');
/*!40000 ALTER TABLE `tbuser` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-11 16:44:53
