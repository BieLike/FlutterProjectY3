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
-- Table structure for table `tbactivity_log`
--

DROP TABLE IF EXISTS `tbactivity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbactivity_log` (
  `LogID` int(11) NOT NULL AUTO_INCREMENT,
  `EmployeeID` int(8) DEFAULT NULL,
  `EmployeeName` varchar(50) DEFAULT NULL,
  `ActionType` varchar(20) NOT NULL COMMENT 'ເຊັ່ນ CREATE, UPDATE, DELETE',
  `TargetTable` varchar(50) NOT NULL COMMENT 'ຈາຈະລາງທີ່ມີກິດຈະກຳເກີດຂຶ້ນ tbproduct',
  `TargetRecordID` varchar(50) DEFAULT NULL COMMENT 'ID ຂອງແຖວທີ່ມີກິດຈະກຳ',
  `ChangeDetails` text DEFAULT NULL COMMENT 'ລາຍລະອຽດ',
  `LogTimestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`LogID`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbactivity_log`
--

LOCK TABLES `tbactivity_log` WRITE;
/*!40000 ALTER TABLE `tbactivity_log` DISABLE KEYS */;
INSERT INTO `tbactivity_log` VALUES (1,8,'kham','UPDATE','tbproduct','Kpo1112','แก้ไขข้อมูลหนังสือ ID: Kpo1112. ID ใหม่: Kpo1112, ชื่อใหม่: \'Kraprao_Freeze\'','2025-07-08 09:55:39'),(2,8,'kham','UPDATE','tbproduct','Kpo1112','แก้ไขหนังสือ \'Kraprao_Freeze\':\n- ImportPrice: 35000 -> 33000','2025-07-08 10:06:42'),(3,8,'kham','CREATE','tbproduct','007','สร้างหนังสือใหม่: \'Dr.No\' (จำนวน: 50)','2025-07-08 10:08:08'),(4,8,'kham','UPDATE','tbcategory','Fd1112','ແກ້ໄຂປະເພດ ID: Fd1112. ID ໃໝ່: b001, ຊື່ໃໝ່: \'Popupbook\'','2025-07-08 10:09:24'),(5,8,'kham','UPDATE','tbunit','Bg1112','แก้ไขหน่วยนับ ID: Bg1112. ID ใหม่: Bg1112, ชื่อใหม่: \'bag1\'','2025-07-08 10:10:11'),(6,8,'kham','CREATE','tbimport','8','ສ້າງໃບນຳເຂົ້າໃໝ່ #8 ຈາກຜູ້ສະໜອງ\'Maxza\' ຈຳນວນ 1 ລາຍການ','2025-07-08 10:12:46'),(7,NULL,NULL,'UPDATE','tbimport','8','อัปเดตสถานะใบนำเข้า #8 เป็น \'Completed\'\nยืนยันสินค้า 1 รายการ','2025-07-08 11:10:46'),(8,8,'kham','CREATE','tbcategory','12','ສ້າງປະເພດໃໝ່: \'boxset\' (ID: 12)','2025-07-09 07:27:07'),(9,8,'kham','CREATE','tbauthor','2','ສ້າງຜູ້ຂຽນໃໝ່: \'gege\' (ID: 2)','2025-07-09 07:44:54'),(10,8,'kham','UPDATE','tbauthor','2','ແກ້ໄຂຜູ້ຂຽນ ID: 2. ID ໃໝ່: 2, ຊື່ໃໝ່: \'GEGE\'','2025-07-09 07:45:11'),(11,NULL,NULL,'UPDATE','tbimport','8','อัปเดตสถานะใบนำเข้า #8 เป็น \'Completed\'\nยืนยันสินค้า 1 รายการ','2025-07-09 07:58:35'),(12,8,'kham','CREATE','tbsell','17','สร้างรายการขาย #17 รวม 1 รายการ','2025-07-09 08:03:49'),(13,8,'kham','CREATE','tbsell','18','สร้างรายการขาย #18 รวม 1 รายการ','2025-07-09 09:16:52'),(14,8,'kham','CREATE','tbimport','9','ສ້າງໃບນຳເຂົ້າໃໝ່ #9 ຈາກ \'Maxza\'','2025-07-09 09:43:05'),(15,8,'kham','UPDATE','tbimport','9','ອັບເດດສະຖານະໃບນຳເຂົ້າ #9 ເປັນ \'Cancelled\'\nເຫດຜົນ: Cancelled from App','2025-07-09 09:50:25'),(16,8,'kham','UPDATE','tbimport','1','ອັບເດດສະຖານະໃບນຳເຂົ້າ #1 ເປັນ \'Completed\'','2025-07-09 09:50:41'),(17,8,'kham','CREATE','tbimport','10','ສ້າງໃບນຳເຂົ້າ #10 ຈາກ \'Maxza\'','2025-07-09 10:15:18'),(18,8,'kham','CREATE','tbimport','11','ສ້າງໃບນຳເຂົ້າ #11 ຈາກ \'Maxza\'','2025-07-09 10:16:06'),(19,8,'kham','CREATE','tbimport','12','ສ້າງໃບນຳເຂົ້າ #12 ຈາກ \'Maxza\'','2025-07-09 10:16:53'),(20,8,'kham','UPDATE','tbimport','10','ອັບເດດສະຖານະໃບນຳເຂົ້າ #10 ເປັນ \'Completed\'\nເຫດຜົນ: Cancelled from App','2025-07-09 10:17:18'),(21,8,'kham','CREATE','tbsupplier','103','สร้างซัพพลายเออร์ใหม่: \'JAA\'','2025-07-10 09:00:20'),(22,8,'kham','UPDATE','tbsupplier','103','ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\' (ID: 103)','2025-07-10 09:07:21'),(23,8,'kham','CREATE','tbsell','19','สร้างรายการขาย #19 รวม 2 รายการ','2025-07-10 09:07:48'),(24,8,'kham','UPDATE','tbsell','19','ແກ້ໄຂລາຍການໃນບິນ #19: ປ່ຽນຈຳນວນສິນຄ້າ \'Dr.No\' ຈາກ 1 ເປັນ 12','2025-07-11 03:28:10'),(25,8,'kham','UPDATE','tbsell','19','ແກ້ໄຂລາຍການໃນບິນ #19: ປ່ຽນຈຳນວນສິນຄ້າ \'Dr.No\' ຈາກ 12 ເປັນ 10','2025-07-11 04:29:40'),(26,8,'kham','UPDATE','tbsell','19','ແກ້ໄຂລາຍການໃນບິນ #19: ປ່ຽນຈຳນວນສິນຄ້າ \'Dr.No\' ຈາກ 10 ເປັນ 5','2025-07-11 04:43:57'),(27,8,'kham','CREATE','tbsell','20','สร้างรายการขาย #20 รวม 1 รายการ','2025-07-11 06:38:34'),(28,8,'kham','CREATE','tbsell','21','สร้างรายการขาย #21 รวม 1 รายการ','2025-07-11 06:38:53'),(29,8,'kham','RETURN','tbsell','19','ຮັບຄືນສິນຄ້າໃນບິນ #19: ສິນຄ້າ \'Dr.No\' ຈຳນວນ 4 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 480000 ກີບ','2025-07-11 06:59:41'),(30,8,'kham','UPDATE','tbsell','19','ລົບສິນຄ້າ \'Dr.No\' ອອກຈາກບິນ #19','2025-07-11 07:03:26'),(31,8,'kham','CREATE','tbsell','22','สร้างรายการขาย #22 รวม 1 รายการ','2025-07-11 07:21:15'),(32,8,'kham','RETURN','tbsell','22','ຮັບຄືນສິນຄ້າໃນບິນ #22: ສິນຄ້າ \'Kraprao_fastest\' ຈຳນວນ 4 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 148000 ກີບ','2025-07-11 07:21:34'),(33,8,'kham','CREATE','tbsell','23','สร้างรายการขาย #23 รวม 1 รายการ','2025-07-11 07:22:27'),(34,8,'kham','CREATE','tbsell','24','สร้างรายการขาย #24 รวม 1 รายการ','2025-07-11 07:22:55'),(35,8,'kham','RETURN','tbsell','24','ຮັບຄືນສິນຄ້າໃນບິນ #24: ສິນຄ້າ \'Kraprao_fatasses\' ຈຳນວນ 5 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 185000 ກີບ','2025-07-11 07:23:12'),(36,8,'kham','RETURN','tbsell','23','ຮັບຄືນສິນຄ້າໃນບິນ #23: ສິນຄ້າ \'Dr.No\' ຈຳນວນ 1 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 120000 ກີບ','2025-07-11 07:25:40'),(37,8,'kham','CREATE','tbsell','25','สร้างรายการขาย #25 รวม 1 รายการ','2025-07-11 07:25:57'),(38,8,'kham','RETURN','tbsell','25','ຮັບຄືນສິນຄ້າໃນບິນ #25: ສິນຄ້າ \'Kraprao_fatasses\' ຈຳນວນ 5 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 185000 ກີບ','2025-07-11 07:26:10'),(39,8,'kham','CREATE','tbsell','26','สร้างรายการขาย #26 รวม 1 รายการ','2025-07-11 07:26:50'),(40,8,'kham','RETURN','tbsell','26','ຮັບຄືນສິນຄ້າໃນບິນ #26: ສິນຄ້າ \'Kraprao_fastest\' ຈຳນວນ 1 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 37000 ກີບ','2025-07-11 07:26:59'),(41,8,'kham','UPDATE','tbsell','26','ລົບສິນຄ້າ \'Kraprao_fastest\' ອອກຈາກບິນ #26','2025-07-11 07:29:12'),(42,8,'kham','DELETE','tbsell','26','ລົບການຂາຍທັງໝົດຂອງບິນ #26','2025-07-11 07:29:20'),(43,8,'kham','UPDATE','tbcategory','12','ແກ້ໄຂປະເພດ ID: 12. ID ໃໝ່: 12, ຊື່ໃໝ່: \'boxsett\'','2025-07-11 09:30:23'),(44,8,'kham','UPDATE','tbproduct','007','ແກ້ໄຂຂໍ້ມູນປຶ້ມ \'Dr.No\':\n- ປ່ຽນຮູບພາບເປັນ: product-1752226615043.jpg','2025-07-11 09:36:55'),(45,8,'kham','CREATE','tbsell','27','สร้างรายการขาย #27 รวม 1 รายการ','2025-07-11 09:44:05'),(46,8,'kham','UPDATE','tbproduct','007','ແກ້ໄຂຂໍ້ມູນປຶ້ມ \'Dr.No\':\n- Bpage: 0 -> 100','2025-07-11 10:15:49'),(47,8,'kham','UPDATE','tbproduct','01111','ແກ້ໄຂຂໍ້ມູນປຶ້ມ \'เจมบอน\':\n- ປ່ຽນຮູບພາບເປັນ: product-1752229002511.jpg','2025-07-11 10:16:42'),(48,8,'kham','CREATE','tbsell','28','สร้างรายการขาย #28 รวม 1 รายการ','2025-07-11 10:17:31'),(49,8,'kham','CREATE','tbsell','29','สร้างรายการขาย #29 รวม 1 รายการ','2025-07-11 10:33:48'),(50,8,'kham','UPDATE','tbsupplier','103','ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\' (ID: 103)','2025-07-13 04:19:49'),(51,8,'kham','UPDATE','tbsupplier','103','ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\':\n- ຜູ້ຕິດຕໍ່: \'jamess\' -> \'james\'','2025-07-13 04:30:58'),(52,8,'kham','UPDATE','tbsupplier','103','ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\':\n- ເບີໂທ: \'2099999999\' -> \'2099999555\'','2025-07-13 04:31:22'),(53,8,'kham','CREATE','tbimport','13','ສ້າງໃບນຳເຂົ້າ #13 ຈາກ \'JAA\'','2025-07-13 04:35:39'),(54,8,'kham','CREATE','tbsell','30','ສ້າງລາຍການຂາຍ #30 ລວມ 1 ລາຍການ','2025-07-13 05:20:13'),(55,8,'kham','LOGIN','tbuser','8','ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 06:09:04'),(56,8,'kham','LOGIN','tbuser','8','ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 06:11:26'),(57,8,'kham','LOGIN','tbuser','8','ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 06:12:50'),(58,8,'kham','LOGIN','tbuser','8','ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:23:30'),(59,8,'kham','LOGIN','tbuser','8','ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:26:12'),(60,1,'Sanhsaveng','LOGIN','tbuser','1','ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:29:36'),(61,8,'kham','LOGIN','tbuser','8','ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:30:35'),(62,8,'kham','LOGIN','tbuser','8','ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:32:11'),(63,1,'Sanhsaveng','LOGIN','tbuser','1','ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:32:27'),(64,1,'Sanhsaveng','LOGIN','tbuser','1','ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:33:07'),(65,2,'Test','LOGIN','tbuser','2','ຜູ້ໃຊ້ \'Test\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:33:31'),(66,1,'Sanhsaveng','LOGIN','tbuser','1','ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:34:11'),(67,1,'Sanhsaveng','LOGIN','tbuser','1','ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:38:19'),(68,1,'Sanhsaveng','LOGIN','tbuser','1','ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.','2025-07-13 09:40:50');
/*!40000 ALTER TABLE `tbactivity_log` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `tbauthor` VALUES (1,'Eiichiro Oda'),(2,'GEGE');
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
INSERT INTO `tbcategory` VALUES ('','manga'),('12','boxsett'),('1230','book'),('13','ນະວັດນິຍາຍ'),('b001','Popupbook'),('Wtr1111','Water');
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
  `Bpage` int(5) DEFAULT 0,
  `Quantity` int(5) NOT NULL,
  `ImportPrice` int(7) NOT NULL,
  `SellPrice` int(7) NOT NULL,
  `UnitID` varchar(15) NOT NULL,
  `CategoryID` varchar(15) NOT NULL,
  `authorsID` int(11) NOT NULL,
  `Balance` int(5) NOT NULL,
  `Level` int(5) NOT NULL,
  `ProductImageURL` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ProductID`),
  KEY `UnitID` (`UnitID`,`CategoryID`),
  KEY `CID` (`CategoryID`),
  KEY `FK_Product_Author` (`authorsID`),
  CONSTRAINT `CID` FOREIGN KEY (`CategoryID`) REFERENCES `tbcategory` (`CategoryID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_Product_Author` FOREIGN KEY (`authorsID`) REFERENCES `tbauthor` (`authorID`) ON UPDATE CASCADE,
  CONSTRAINT `UID` FOREIGN KEY (`UnitID`) REFERENCES `tbunit` (`UnitID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbproduct`
--

LOCK TABLES `tbproduct` WRITE;
/*!40000 ALTER TABLE `tbproduct` DISABLE KEYS */;
INSERT INTO `tbproduct` VALUES ('007','Dr.No',100,10,100000,120000,'14','13',1,1000000,30,'/uploads/product-1752226615043.jpg'),('01111','เจมบอน',0,10,100000,120000,'14','13',2,10,5,'/uploads/product-1752229002511.jpg'),('444','jin',0,10,100000,110000,'14','',2,10,5,NULL),('Kpo1112','Kraprao_Freeze',0,70,33000,37000,'Bg1112','b001',1,70,5,'/uploads/product-1752225070728.jpg'),('Kpo1119','Kraprao_fatasses',0,42,33000,37000,'Bg1112','b001',1,50,5,NULL),('Kpo1155','Kraprao_fastest',0,29,33000,37000,'Bg1112','b001',1,30,5,NULL),('Lay1111','Lay_Original_Big_Bag',0,63,15000,18000,'Bg1112','b001',1,60,10,NULL),('Ois1114','Oishi_small',0,52,12000,15000,'bt1115','Wtr1111',1,56,10,NULL),('Tgh1111','Tiger_Head_Big',0,39,8000,10000,'bt1115','Wtr1111',1,42,5,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbsupplier`
--

LOCK TABLES `tbsupplier` WRITE;
/*!40000 ALTER TABLE `tbsupplier` DISABLE KEYS */;
INSERT INTO `tbsupplier` VALUES (101,'Cityplex','Hasann','2022136258','Maile@email.com','lao, Laos','Inactive','2025-05-27 12:26:35'),(102,'Maxza','Maxy','2058384765','Maxlnwza004@gmail.com','Khoihong','Active','2025-05-27 12:32:16'),(103,'JAA','james','2099999555','jas@gmail.com','dongdok,laos','Inactive','2025-07-10 16:00:20');
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
INSERT INTO `tbunit` VALUES ('101','Boxset1'),('14','ຫົວ'),('15','Ted'),('2221','ແພັກ'),('Bg1112','bag1'),('bt1115','Bottle');
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbuser`
--

LOCK TABLES `tbuser` WRITE;
/*!40000 ALTER TABLE `tbuser` DISABLE KEYS */;
INSERT INTO `tbuser` VALUES (1,'Sanhsaveng','KeoKham','18/07/2013','ຍິງ',123,'Sanhsaveng@gmail.com',2,'123'),(2,'Test','Subject','2011-11-11','ຊາຍ',2,'TestSubject@gmail.co',5,'2'),(7,'tes','tesin','11/07/2002','ຍິງ',2035262353,'Tes@gmail.com',1,'11111111'),(8,'kham','kham','1/1/2000','ຊາຍ',1,'ggkham@gmail.com',1,'1');
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

-- Dump completed on 2025-07-13 16:45:53
