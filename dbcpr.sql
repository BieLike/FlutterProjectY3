-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 13, 2025 at 11:49 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dbcpr`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbactivity_log`
--

CREATE TABLE `tbactivity_log` (
  `LogID` int(11) NOT NULL,
  `EmployeeID` int(8) DEFAULT NULL,
  `EmployeeName` varchar(50) DEFAULT NULL,
  `ActionType` varchar(20) NOT NULL COMMENT 'ເຊັ່ນ CREATE, UPDATE, DELETE',
  `TargetTable` varchar(50) NOT NULL COMMENT 'ຈາຈະລາງທີ່ມີກິດຈະກຳເກີດຂຶ້ນ tbproduct',
  `TargetRecordID` varchar(50) DEFAULT NULL COMMENT 'ID ຂອງແຖວທີ່ມີກິດຈະກຳ',
  `ChangeDetails` text DEFAULT NULL COMMENT 'ລາຍລະອຽດ',
  `LogTimestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbactivity_log`
--

INSERT INTO `tbactivity_log` (`LogID`, `EmployeeID`, `EmployeeName`, `ActionType`, `TargetTable`, `TargetRecordID`, `ChangeDetails`, `LogTimestamp`) VALUES
(1, 8, 'kham', 'UPDATE', 'tbproduct', 'Kpo1112', 'แก้ไขข้อมูลหนังสือ ID: Kpo1112. ID ใหม่: Kpo1112, ชื่อใหม่: \'Kraprao_Freeze\'', '2025-07-08 09:55:39'),
(2, 8, 'kham', 'UPDATE', 'tbproduct', 'Kpo1112', 'แก้ไขหนังสือ \'Kraprao_Freeze\':\n- ImportPrice: 35000 -> 33000', '2025-07-08 10:06:42'),
(3, 8, 'kham', 'CREATE', 'tbproduct', '007', 'สร้างหนังสือใหม่: \'Dr.No\' (จำนวน: 50)', '2025-07-08 10:08:08'),
(4, 8, 'kham', 'UPDATE', 'tbcategory', 'Fd1112', 'ແກ້ໄຂປະເພດ ID: Fd1112. ID ໃໝ່: b001, ຊື່ໃໝ່: \'Popupbook\'', '2025-07-08 10:09:24'),
(5, 8, 'kham', 'UPDATE', 'tbunit', 'Bg1112', 'แก้ไขหน่วยนับ ID: Bg1112. ID ใหม่: Bg1112, ชื่อใหม่: \'bag1\'', '2025-07-08 10:10:11'),
(6, 8, 'kham', 'CREATE', 'tbimport', '8', 'ສ້າງໃບນຳເຂົ້າໃໝ່ #8 ຈາກຜູ້ສະໜອງ\'Maxza\' ຈຳນວນ 1 ລາຍການ', '2025-07-08 10:12:46'),
(7, NULL, NULL, 'UPDATE', 'tbimport', '8', 'อัปเดตสถานะใบนำเข้า #8 เป็น \'Completed\'\nยืนยันสินค้า 1 รายการ', '2025-07-08 11:10:46'),
(8, 8, 'kham', 'CREATE', 'tbcategory', '12', 'ສ້າງປະເພດໃໝ່: \'boxset\' (ID: 12)', '2025-07-09 07:27:07'),
(9, 8, 'kham', 'CREATE', 'tbauthor', '2', 'ສ້າງຜູ້ຂຽນໃໝ່: \'gege\' (ID: 2)', '2025-07-09 07:44:54'),
(10, 8, 'kham', 'UPDATE', 'tbauthor', '2', 'ແກ້ໄຂຜູ້ຂຽນ ID: 2. ID ໃໝ່: 2, ຊື່ໃໝ່: \'GEGE\'', '2025-07-09 07:45:11'),
(11, NULL, NULL, 'UPDATE', 'tbimport', '8', 'อัปเดตสถานะใบนำเข้า #8 เป็น \'Completed\'\nยืนยันสินค้า 1 รายการ', '2025-07-09 07:58:35'),
(12, 8, 'kham', 'CREATE', 'tbsell', '17', 'สร้างรายการขาย #17 รวม 1 รายการ', '2025-07-09 08:03:49'),
(13, 8, 'kham', 'CREATE', 'tbsell', '18', 'สร้างรายการขาย #18 รวม 1 รายการ', '2025-07-09 09:16:52'),
(14, 8, 'kham', 'CREATE', 'tbimport', '9', 'ສ້າງໃບນຳເຂົ້າໃໝ່ #9 ຈາກ \'Maxza\'', '2025-07-09 09:43:05'),
(15, 8, 'kham', 'UPDATE', 'tbimport', '9', 'ອັບເດດສະຖານະໃບນຳເຂົ້າ #9 ເປັນ \'Cancelled\'\nເຫດຜົນ: Cancelled from App', '2025-07-09 09:50:25'),
(16, 8, 'kham', 'UPDATE', 'tbimport', '1', 'ອັບເດດສະຖານະໃບນຳເຂົ້າ #1 ເປັນ \'Completed\'', '2025-07-09 09:50:41'),
(17, 8, 'kham', 'CREATE', 'tbimport', '10', 'ສ້າງໃບນຳເຂົ້າ #10 ຈາກ \'Maxza\'', '2025-07-09 10:15:18'),
(18, 8, 'kham', 'CREATE', 'tbimport', '11', 'ສ້າງໃບນຳເຂົ້າ #11 ຈາກ \'Maxza\'', '2025-07-09 10:16:06'),
(19, 8, 'kham', 'CREATE', 'tbimport', '12', 'ສ້າງໃບນຳເຂົ້າ #12 ຈາກ \'Maxza\'', '2025-07-09 10:16:53'),
(20, 8, 'kham', 'UPDATE', 'tbimport', '10', 'ອັບເດດສະຖານະໃບນຳເຂົ້າ #10 ເປັນ \'Completed\'\nເຫດຜົນ: Cancelled from App', '2025-07-09 10:17:18'),
(21, 8, 'kham', 'CREATE', 'tbsupplier', '103', 'สร้างซัพพลายเออร์ใหม่: \'JAA\'', '2025-07-10 09:00:20'),
(22, 8, 'kham', 'UPDATE', 'tbsupplier', '103', 'ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\' (ID: 103)', '2025-07-10 09:07:21'),
(23, 8, 'kham', 'CREATE', 'tbsell', '19', 'สร้างรายการขาย #19 รวม 2 รายการ', '2025-07-10 09:07:48'),
(24, 8, 'kham', 'UPDATE', 'tbsell', '19', 'ແກ້ໄຂລາຍການໃນບິນ #19: ປ່ຽນຈຳນວນສິນຄ້າ \'Dr.No\' ຈາກ 1 ເປັນ 12', '2025-07-11 03:28:10'),
(25, 8, 'kham', 'UPDATE', 'tbsell', '19', 'ແກ້ໄຂລາຍການໃນບິນ #19: ປ່ຽນຈຳນວນສິນຄ້າ \'Dr.No\' ຈາກ 12 ເປັນ 10', '2025-07-11 04:29:40'),
(26, 8, 'kham', 'UPDATE', 'tbsell', '19', 'ແກ້ໄຂລາຍການໃນບິນ #19: ປ່ຽນຈຳນວນສິນຄ້າ \'Dr.No\' ຈາກ 10 ເປັນ 5', '2025-07-11 04:43:57'),
(27, 8, 'kham', 'CREATE', 'tbsell', '20', 'สร้างรายการขาย #20 รวม 1 รายการ', '2025-07-11 06:38:34'),
(28, 8, 'kham', 'CREATE', 'tbsell', '21', 'สร้างรายการขาย #21 รวม 1 รายการ', '2025-07-11 06:38:53'),
(29, 8, 'kham', 'RETURN', 'tbsell', '19', 'ຮັບຄືນສິນຄ້າໃນບິນ #19: ສິນຄ້າ \'Dr.No\' ຈຳນວນ 4 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 480000 ກີບ', '2025-07-11 06:59:41'),
(30, 8, 'kham', 'UPDATE', 'tbsell', '19', 'ລົບສິນຄ້າ \'Dr.No\' ອອກຈາກບິນ #19', '2025-07-11 07:03:26'),
(31, 8, 'kham', 'CREATE', 'tbsell', '22', 'สร้างรายการขาย #22 รวม 1 รายการ', '2025-07-11 07:21:15'),
(32, 8, 'kham', 'RETURN', 'tbsell', '22', 'ຮັບຄືນສິນຄ້າໃນບິນ #22: ສິນຄ້າ \'Kraprao_fastest\' ຈຳນວນ 4 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 148000 ກີບ', '2025-07-11 07:21:34'),
(33, 8, 'kham', 'CREATE', 'tbsell', '23', 'สร้างรายการขาย #23 รวม 1 รายการ', '2025-07-11 07:22:27'),
(34, 8, 'kham', 'CREATE', 'tbsell', '24', 'สร้างรายการขาย #24 รวม 1 รายการ', '2025-07-11 07:22:55'),
(35, 8, 'kham', 'RETURN', 'tbsell', '24', 'ຮັບຄືນສິນຄ້າໃນບິນ #24: ສິນຄ້າ \'Kraprao_fatasses\' ຈຳນວນ 5 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 185000 ກີບ', '2025-07-11 07:23:12'),
(36, 8, 'kham', 'RETURN', 'tbsell', '23', 'ຮັບຄືນສິນຄ້າໃນບິນ #23: ສິນຄ້າ \'Dr.No\' ຈຳນວນ 1 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 120000 ກີບ', '2025-07-11 07:25:40'),
(37, 8, 'kham', 'CREATE', 'tbsell', '25', 'สร้างรายการขาย #25 รวม 1 รายการ', '2025-07-11 07:25:57'),
(38, 8, 'kham', 'RETURN', 'tbsell', '25', 'ຮັບຄືນສິນຄ້າໃນບິນ #25: ສິນຄ້າ \'Kraprao_fatasses\' ຈຳນວນ 5 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 185000 ກີບ', '2025-07-11 07:26:10'),
(39, 8, 'kham', 'CREATE', 'tbsell', '26', 'สร้างรายการขาย #26 รวม 1 รายการ', '2025-07-11 07:26:50'),
(40, 8, 'kham', 'RETURN', 'tbsell', '26', 'ຮັບຄືນສິນຄ້າໃນບິນ #26: ສິນຄ້າ \'Kraprao_fastest\' ຈຳນວນ 1 ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ 37000 ກີບ', '2025-07-11 07:26:59'),
(41, 8, 'kham', 'UPDATE', 'tbsell', '26', 'ລົບສິນຄ້າ \'Kraprao_fastest\' ອອກຈາກບິນ #26', '2025-07-11 07:29:12'),
(42, 8, 'kham', 'DELETE', 'tbsell', '26', 'ລົບການຂາຍທັງໝົດຂອງບິນ #26', '2025-07-11 07:29:20'),
(43, 8, 'kham', 'UPDATE', 'tbcategory', '12', 'ແກ້ໄຂປະເພດ ID: 12. ID ໃໝ່: 12, ຊື່ໃໝ່: \'boxsett\'', '2025-07-11 09:30:23'),
(44, 8, 'kham', 'UPDATE', 'tbproduct', '007', 'ແກ້ໄຂຂໍ້ມູນປຶ້ມ \'Dr.No\':\n- ປ່ຽນຮູບພາບເປັນ: product-1752226615043.jpg', '2025-07-11 09:36:55'),
(45, 8, 'kham', 'CREATE', 'tbsell', '27', 'สร้างรายการขาย #27 รวม 1 รายการ', '2025-07-11 09:44:05'),
(46, 8, 'kham', 'UPDATE', 'tbproduct', '007', 'ແກ້ໄຂຂໍ້ມູນປຶ້ມ \'Dr.No\':\n- Bpage: 0 -> 100', '2025-07-11 10:15:49'),
(47, 8, 'kham', 'UPDATE', 'tbproduct', '01111', 'ແກ້ໄຂຂໍ້ມູນປຶ້ມ \'เจมบอน\':\n- ປ່ຽນຮູບພາບເປັນ: product-1752229002511.jpg', '2025-07-11 10:16:42'),
(48, 8, 'kham', 'CREATE', 'tbsell', '28', 'สร้างรายการขาย #28 รวม 1 รายการ', '2025-07-11 10:17:31'),
(49, 8, 'kham', 'CREATE', 'tbsell', '29', 'สร้างรายการขาย #29 รวม 1 รายการ', '2025-07-11 10:33:48'),
(50, 8, 'kham', 'UPDATE', 'tbsupplier', '103', 'ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\' (ID: 103)', '2025-07-13 04:19:49'),
(51, 8, 'kham', 'UPDATE', 'tbsupplier', '103', 'ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\':\n- ຜູ້ຕິດຕໍ່: \'jamess\' -> \'james\'', '2025-07-13 04:30:58'),
(52, 8, 'kham', 'UPDATE', 'tbsupplier', '103', 'ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ \'JAA\':\n- ເບີໂທ: \'2099999999\' -> \'2099999555\'', '2025-07-13 04:31:22'),
(53, 8, 'kham', 'CREATE', 'tbimport', '13', 'ສ້າງໃບນຳເຂົ້າ #13 ຈາກ \'JAA\'', '2025-07-13 04:35:39'),
(54, 8, 'kham', 'CREATE', 'tbsell', '30', 'ສ້າງລາຍການຂາຍ #30 ລວມ 1 ລາຍການ', '2025-07-13 05:20:13'),
(55, 8, 'kham', 'LOGIN', 'tbuser', '8', 'ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 06:09:04'),
(56, 8, 'kham', 'LOGIN', 'tbuser', '8', 'ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 06:11:26'),
(57, 8, 'kham', 'LOGIN', 'tbuser', '8', 'ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 06:12:50'),
(58, 8, 'kham', 'LOGIN', 'tbuser', '8', 'ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:23:30'),
(59, 8, 'kham', 'LOGIN', 'tbuser', '8', 'ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:26:12'),
(60, 1, 'Sanhsaveng', 'LOGIN', 'tbuser', '1', 'ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:29:36'),
(61, 8, 'kham', 'LOGIN', 'tbuser', '8', 'ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:30:35'),
(62, 8, 'kham', 'LOGIN', 'tbuser', '8', 'ຜູ້ໃຊ້ \'kham\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:32:11'),
(63, 1, 'Sanhsaveng', 'LOGIN', 'tbuser', '1', 'ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:32:27'),
(64, 1, 'Sanhsaveng', 'LOGIN', 'tbuser', '1', 'ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:33:07'),
(65, 2, 'Test', 'LOGIN', 'tbuser', '2', 'ຜູ້ໃຊ້ \'Test\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:33:31'),
(66, 1, 'Sanhsaveng', 'LOGIN', 'tbuser', '1', 'ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:34:11'),
(67, 1, 'Sanhsaveng', 'LOGIN', 'tbuser', '1', 'ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:38:19'),
(68, 1, 'Sanhsaveng', 'LOGIN', 'tbuser', '1', 'ຜູ້ໃຊ້ \'Sanhsaveng\' ໄດ້ເຂົ້າສູ່ລະບົບ.', '2025-07-13 09:40:50');

-- --------------------------------------------------------

--
-- Table structure for table `tbauthor`
--

CREATE TABLE `tbauthor` (
  `authorID` int(11) NOT NULL,
  `name` varchar(23) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbauthor`
--

INSERT INTO `tbauthor` (`authorID`, `name`) VALUES
(1, 'Eiichiro Oda'),
(2, 'GEGE');

-- --------------------------------------------------------

--
-- Table structure for table `tbbooks`
--

CREATE TABLE `tbbooks` (
  `BID` int(8) NOT NULL,
  `Bname` varchar(50) NOT NULL,
  `Bpage` int(5) NOT NULL,
  `Bprice` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbbooks`
--

INSERT INTO `tbbooks` (`BID`, `Bname`, `Bpage`, `Bprice`) VALUES
(112, 'Flutter', 225, '225000'),
(117, 'SQL', 335, '335000'),
(1112, 'Hello WAR 2021 Last ', 15000000, '300'),
(1123, 'Hello WAR 2021', 752000, '225'),
(1156, 'Hello WAR 2021 Last ', 300, '15000000');

-- --------------------------------------------------------

--
-- Table structure for table `tbcategory`
--

CREATE TABLE `tbcategory` (
  `CategoryID` varchar(15) NOT NULL,
  `CategoryName` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbcategory`
--

INSERT INTO `tbcategory` (`CategoryID`, `CategoryName`) VALUES
('', 'manga'),
('12', 'boxsett'),
('1230', 'book'),
('13', 'ນະວັດນິຍາຍ'),
('b001', 'Popupbook'),
('Wtr1111', 'Water');

-- --------------------------------------------------------

--
-- Table structure for table `tbimport`
--

CREATE TABLE `tbimport` (
  `ImportID` int(11) NOT NULL,
  `ImportDate` date NOT NULL,
  `ImportTime` time NOT NULL,
  `TotalItems` int(11) NOT NULL,
  `TotalCost` decimal(10,2) NOT NULL,
  `SupplierName` varchar(100) DEFAULT NULL,
  `SupplierContact` varchar(50) DEFAULT NULL,
  `InvoiceNumber` varchar(50) DEFAULT NULL,
  `Notes` text DEFAULT NULL,
  `Status` enum('Pending','Completed','Cancelled') DEFAULT 'Completed',
  `CreatedBy` int(11) DEFAULT NULL,
  `CreatedDate` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbimport`
--

INSERT INTO `tbimport` (`ImportID`, `ImportDate`, `ImportTime`, `TotalItems`, `TotalCost`, `SupplierName`, `SupplierContact`, `InvoiceNumber`, `Notes`, `Status`, `CreatedBy`, `CreatedDate`) VALUES
(1, '2025-06-02', '08:40:00', 15, 375000.00, 'Hasann', '2022136258', '12123', '', 'Completed', 1, '2025-06-02 08:46:43'),
(2, '2025-06-02', '08:47:00', 10, 150000.00, 'Hasann', '2022136258', '12125', '', 'Completed', 1, '2025-06-02 08:47:51'),
(3, '2025-06-02', '09:40:00', 30, 750000.00, 'Cityplex', '2022136258', '', ' [CANCELLED: Status changed from app]', 'Cancelled', 1, '2025-06-02 09:41:09'),
(4, '2025-06-14', '15:56:00', 15, 255000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 15:57:51'),
(5, '2025-06-14', '16:01:00', 21, 453000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 16:02:56'),
(6, '2025-06-14', '16:07:00', 15, 240000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 16:08:13'),
(7, '2025-07-05', '11:40:00', 6, 20400.00, 'Maxza', '2058384765', 'gesgdr', '', 'Completed', 1, '2025-07-05 11:43:50'),
(8, '2025-07-08', '17:11:00', 50, 5000000.00, 'Maxza', '2058384765', '', '', 'Completed', 8, '2025-07-08 17:12:46'),
(9, '2025-07-09', '16:42:00', 10, 1000000.00, 'Maxza', '2058384765', '', ' [CANCELLED: Cancelled from App]', 'Cancelled', 8, '2025-07-09 16:43:05'),
(10, '2025-07-09', '17:14:00', 35, 700000.00, 'Maxza', NULL, '', '', 'Completed', 8, '2025-07-09 17:15:18'),
(11, '2025-07-09', '17:15:00', 10, 1000000.00, 'Maxza', NULL, '', '', 'Pending', 8, '2025-07-09 17:16:06'),
(12, '2025-07-09', '17:16:00', 15, 300000.00, 'Maxza', NULL, '', '', 'Pending', 8, '2025-07-09 17:16:53'),
(13, '2025-07-13', '11:35:00', 20, 2000000.00, 'JAA', NULL, '', '', 'Pending', 8, '2025-07-13 11:35:39');

-- --------------------------------------------------------

--
-- Table structure for table `tbimportdetail`
--

CREATE TABLE `tbimportdetail` (
  `ImportDetailID` int(11) NOT NULL,
  `ImportID` int(11) NOT NULL,
  `ProductID` varchar(20) NOT NULL,
  `ImportQuantity` int(11) NOT NULL,
  `ImportPrice` decimal(10,2) NOT NULL,
  `TotalCost` decimal(10,2) NOT NULL,
  `PreviousQuantity` int(11) NOT NULL,
  `NewQuantity` int(11) NOT NULL,
  `BatchNumber` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbimportdetail`
--

INSERT INTO `tbimportdetail` (`ImportDetailID`, `ImportID`, `ProductID`, `ImportQuantity`, `ImportPrice`, `TotalCost`, `PreviousQuantity`, `NewQuantity`, `BatchNumber`) VALUES
(1, 1, 'Kpo1119', 15, 25000.00, 375000.00, 25, 40, NULL),
(2, 2, 'Kpo1112', 10, 15000.00, 150000.00, 6, 16, NULL),
(3, 3, 'Kpo1112', 30, 25000.00, 750000.00, 6, 36, NULL),
(4, 4, 'Kpo1112', 5, 25000.00, 125000.00, 16, 21, NULL),
(5, 4, 'Ois1114', 10, 13000.00, 130000.00, 29, 39, NULL),
(6, 5, 'Kpo1112', 5, 25000.00, 125000.00, 21, 26, NULL),
(7, 5, 'Ois1114', 6, 13000.00, 78000.00, 39, 45, NULL),
(8, 5, 'Tgh1111', 10, 25000.00, 250000.00, 29, 39, NULL),
(9, 6, 'Kpo1112', 4, 25000.00, 100000.00, 26, 30, NULL),
(10, 6, 'Ois1114', 10, 13000.00, 130000.00, 45, 55, NULL),
(11, 6, 'Tgh1111', 1, 10000.00, 10000.00, 39, 40, NULL),
(12, 7, 'Kpo1112', 6, 3400.00, 20400.00, 34, 40, NULL),
(13, 8, '007', 50, 100000.00, 5000000.00, 50, 100, NULL),
(14, 9, '007', 10, 100000.00, 1000000.00, 18, 28, NULL),
(15, 10, 'Kpo1112', 15, 20000.00, 300000.00, 56, 0, NULL),
(16, 10, 'Lay1111', 20, 20000.00, 400000.00, 44, 0, NULL),
(17, 11, '007', 10, 100000.00, 1000000.00, 18, 0, NULL),
(18, 12, 'Kpo1112', 15, 20000.00, 300000.00, 56, 0, NULL),
(19, 13, '007', 20, 100000.00, 2000000.00, 11, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tbproduct`
--

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
  `ProductImageURL` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbproduct`
--

INSERT INTO `tbproduct` (`ProductID`, `ProductName`, `Bpage`, `Quantity`, `ImportPrice`, `SellPrice`, `UnitID`, `CategoryID`, `authorsID`, `Balance`, `Level`, `ProductImageURL`) VALUES
('007', 'Dr.No', 100, 10, 100000, 120000, '14', '13', 1, 1000000, 30, '/uploads/product-1752226615043.jpg'),
('01111', 'เจมบอน', 0, 10, 100000, 120000, '14', '13', 2, 10, 5, '/uploads/product-1752229002511.jpg'),
('444', 'jin', 0, 10, 100000, 110000, '14', '', 2, 10, 5, NULL),
('Kpo1112', 'Kraprao_Freeze', 0, 70, 33000, 37000, 'Bg1112', 'b001', 1, 70, 5, '/uploads/product-1752225070728.jpg'),
('Kpo1119', 'Kraprao_fatasses', 0, 42, 33000, 37000, 'Bg1112', 'b001', 1, 50, 5, NULL),
('Kpo1155', 'Kraprao_fastest', 0, 29, 33000, 37000, 'Bg1112', 'b001', 1, 30, 5, NULL),
('Lay1111', 'Lay_Original_Big_Bag', 0, 63, 15000, 18000, 'Bg1112', 'b001', 1, 60, 10, NULL),
('Ois1114', 'Oishi_small', 0, 52, 12000, 15000, 'bt1115', 'Wtr1111', 1, 56, 10, NULL),
('Tgh1111', 'Tiger_Head_Big', 0, 39, 8000, 10000, 'bt1115', 'Wtr1111', 1, 42, 5, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tbrole`
--

CREATE TABLE `tbrole` (
  `RID` int(5) NOT NULL,
  `RoleName` varchar(20) DEFAULT NULL,
  `BaseSalary` int(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbrole`
--

INSERT INTO `tbrole` (`RID`, `RoleName`, `BaseSalary`) VALUES
(1, 'Cashier', 2500000),
(2, 'Admin', 3500000),
(5, 'Stocker', 2000);

-- --------------------------------------------------------

--
-- Table structure for table `tbsell`
--

CREATE TABLE `tbsell` (
  `SellID` int(8) NOT NULL,
  `Date` varchar(11) NOT NULL,
  `Time` varchar(10) NOT NULL,
  `SubTotal` decimal(10,2) NOT NULL,
  `GrandTotal` decimal(10,2) NOT NULL,
  `Money` decimal(10,2) NOT NULL,
  `ChangeTotal` decimal(10,2) NOT NULL,
  `PaymentMethod` varchar(50) NOT NULL,
  `EmployeeID` int(8) NOT NULL,
  `MemberID` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbsell`
--

INSERT INTO `tbsell` (`SellID`, `Date`, `Time`, `SubTotal`, `GrandTotal`, `Money`, `ChangeTotal`, `PaymentMethod`, `EmployeeID`, `MemberID`) VALUES
(8, '2025-05-13', '14:00', 20000.00, 20000.00, 30000.00, 10000.00, 'Cash', 1, '0'),
(9, '2025-05-13', '12:53:19', 111000.00, 111000.00, 120000.00, 9000.00, 'CASH', 1, '0'),
(10, '2025-05-13', '13:01:19', 129000.00, 129000.00, 130000.00, 1000.00, 'CASH', 1, '0'),
(11, '2025-05-13', '13:04:17', 15000.00, 15000.00, 20000.00, 5000.00, 'CASH', 1, '0'),
(12, '2025-05-13', '13:49:16', 185000.00, 185000.00, 200000.00, 15000.00, 'CASH', 1, '0'),
(13, '2025-05-13', '13:52:42', 10000.00, 10000.00, 10000.00, 0.00, 'CASH', 1, '0'),
(14, '2025-05-13', '14:01:58', 370000.00, 370000.00, 400000.00, 30000.00, 'CASH', 1, '0'),
(15, '2025-07-04', '23:51:43', 74000.00, 74000.00, 74000.00, 0.00, 'CASH', 1, 'M001'),
(16, '2025-07-05', '11:17:58', 65000.00, 65000.00, 70000.00, 5000.00, 'CASH', 1, 'M001'),
(17, '2025-07-09', '15:03:49', 120000.00, 120000.00, 150000.00, 30000.00, 'CASH', 8, 'M001'),
(18, '2025-07-09', '16:16:52', 240000.00, 240000.00, 300000.00, 60000.00, 'CASH', 8, 'M001'),
(19, '2025-07-10', '16:07:48', 37000.00, 37000.00, 200000.00, 523000.00, 'CASH', 8, 'M001'),
(20, '2025-07-11', '13:38:34', 120000.00, 120000.00, 120000.00, 0.00, 'TRANSFER', 8, '1'),
(21, '2025-07-11', '13:38:53', 120000.00, 120000.00, 120000.00, 0.00, 'TRANSFER', 8, '1'),
(22, '2025-07-11', '14:21:15', 37000.00, 37000.00, 200000.00, 163000.00, 'CASH', 8, '1'),
(23, '2025-07-11', '14:22:27', 120000.00, 120000.00, 300000.00, 180000.00, 'CASH', 8, '1'),
(24, '2025-07-11', '14:22:55', 37000.00, 37000.00, 230000.00, 193000.00, 'CASH', 8, '1'),
(25, '2025-07-11', '14:25:57', 37000.00, 37000.00, 230000.00, 193000.00, 'CASH', 8, '1'),
(27, '2025-07-11', '16:44:05', 240000.00, 240000.00, 250000.00, 10000.00, 'CASH', 8, '1'),
(28, '2025-07-11', '17:17:31', 18000.00, 18000.00, 18000.00, 0.00, 'TRANSFER', 8, '1'),
(29, '2025-07-11', '17:33:48', 240000.00, 240000.00, 240000.00, 0.00, 'TRANSFER', 8, '1'),
(30, '2025-07-13', '12:20:13', 120000.00, 120000.00, 150000.00, 30000.00, 'CASH', 8, '1');

-- --------------------------------------------------------

--
-- Table structure for table `tbselldetail`
--

CREATE TABLE `tbselldetail` (
  `SellDetailID` int(11) NOT NULL,
  `SellID` int(8) NOT NULL,
  `ProductID` varchar(15) NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  `Quantity` int(5) NOT NULL,
  `Total` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbselldetail`
--

INSERT INTO `tbselldetail` (`SellDetailID`, `SellID`, `ProductID`, `Price`, `Quantity`, `Total`) VALUES
(7, 8, 'kpo1112', 10000.00, 2, '20000'),
(8, 9, 'Kpo1112', 37000.00, 2, '74000'),
(9, 9, 'Kpo1119', 37000.00, 1, '37000'),
(10, 10, 'Kpo1112', 37000.00, 2, '74000'),
(11, 10, 'Kpo1119', 37000.00, 1, '37000'),
(12, 10, 'Lay1111', 18000.00, 1, '18000'),
(13, 11, 'Ois1114', 15000.00, 1, '15000'),
(14, 12, 'Kpo1112', 37000.00, 5, '185000'),
(15, 13, 'Tgh1111', 10000.00, 1, '10000'),
(16, 14, 'Kpo1112', 37000.00, 9, '333000'),
(17, 14, 'Kpo1119', 37000.00, 1, '37000'),
(18, 15, 'Kpo1112', 37000.00, 1, '37000'),
(19, 15, 'Kpo1119', 37000.00, 1, '37000.0'),
(20, 16, 'Ois1114', 15000.00, 3, '45000.0'),
(21, 16, 'Tgh1111', 10000.00, 2, '20000.0'),
(22, 17, '007', 120000.00, 1, '120000'),
(23, 18, '007', 120000.00, 2, '240000'),
(25, 19, 'Kpo1112', 37000.00, 1, '37000'),
(26, 20, '007', 120000.00, 1, '120000'),
(27, 21, '007', 120000.00, 1, '120000'),
(28, 22, 'Kpo1155', 37000.00, 1, '37000'),
(29, 23, '007', 120000.00, 1, '120000'),
(30, 24, 'Kpo1119', 37000.00, 1, '37000'),
(31, 25, 'Kpo1119', 37000.00, 1, '37000'),
(33, 27, '007', 120000.00, 2, '240000'),
(34, 28, 'Lay1111', 18000.00, 1, '18000'),
(35, 29, '007', 120000.00, 2, '240000'),
(36, 30, '007', 120000.00, 1, '120000');

-- --------------------------------------------------------

--
-- Table structure for table `tbsupplier`
--

CREATE TABLE `tbsupplier` (
  `SupplierID` int(11) NOT NULL,
  `SupplierName` varchar(100) NOT NULL,
  `ContactPerson` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Address` text DEFAULT NULL,
  `Status` enum('Active','Inactive') DEFAULT 'Active',
  `CreatedDate` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbsupplier`
--

INSERT INTO `tbsupplier` (`SupplierID`, `SupplierName`, `ContactPerson`, `Phone`, `Email`, `Address`, `Status`, `CreatedDate`) VALUES
(101, 'Cityplex', 'Hasann', '2022136258', 'Maile@email.com', 'lao, Laos', 'Inactive', '2025-05-27 12:26:35'),
(102, 'Maxza', 'Maxy', '2058384765', 'Maxlnwza004@gmail.com', 'Khoihong', 'Active', '2025-05-27 12:32:16'),
(103, 'JAA', 'james', '2099999555', 'jas@gmail.com', 'dongdok,laos', 'Inactive', '2025-07-10 16:00:20');

-- --------------------------------------------------------

--
-- Table structure for table `tbunit`
--

CREATE TABLE `tbunit` (
  `UnitID` varchar(15) NOT NULL,
  `UnitName` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbunit`
--

INSERT INTO `tbunit` (`UnitID`, `UnitName`) VALUES
('101', 'Boxset1'),
('14', 'ຫົວ'),
('15', 'Ted'),
('2221', 'ແພັກ'),
('Bg1112', 'bag1'),
('bt1115', 'Bottle');

-- --------------------------------------------------------

--
-- Table structure for table `tbuser`
--

CREATE TABLE `tbuser` (
  `UID` int(8) NOT NULL,
  `UserFname` varchar(20) NOT NULL,
  `UserLname` varchar(20) NOT NULL,
  `DateOfBirth` varchar(15) NOT NULL,
  `Gender` varchar(10) NOT NULL,
  `Phone` int(15) NOT NULL,
  `Email` varchar(20) NOT NULL,
  `Position` int(5) NOT NULL,
  `UserPassword` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbuser`
--

INSERT INTO `tbuser` (`UID`, `UserFname`, `UserLname`, `DateOfBirth`, `Gender`, `Phone`, `Email`, `Position`, `UserPassword`) VALUES
(1, 'Sanhsaveng', 'KeoKham', '18/07/2013', 'ຍິງ', 123, 'Sanhsaveng@gmail.com', 2, '123'),
(2, 'Test', 'Subject', '2011-11-11', 'ຊາຍ', 2, 'TestSubject@gmail.co', 5, '2'),
(7, 'tes', 'tesin', '11/07/2002', 'ຍິງ', 2035262353, 'Tes@gmail.com', 1, '11111111'),
(8, 'kham', 'kham', '1/1/2000', 'ຊາຍ', 1, 'ggkham@gmail.com', 1, '1');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbactivity_log`
--
ALTER TABLE `tbactivity_log`
  ADD PRIMARY KEY (`LogID`);

--
-- Indexes for table `tbauthor`
--
ALTER TABLE `tbauthor`
  ADD PRIMARY KEY (`authorID`);

--
-- Indexes for table `tbbooks`
--
ALTER TABLE `tbbooks`
  ADD PRIMARY KEY (`BID`);

--
-- Indexes for table `tbcategory`
--
ALTER TABLE `tbcategory`
  ADD PRIMARY KEY (`CategoryID`);

--
-- Indexes for table `tbimport`
--
ALTER TABLE `tbimport`
  ADD PRIMARY KEY (`ImportID`),
  ADD KEY `CreatedBy` (`CreatedBy`);

--
-- Indexes for table `tbimportdetail`
--
ALTER TABLE `tbimportdetail`
  ADD PRIMARY KEY (`ImportDetailID`),
  ADD KEY `ImportID` (`ImportID`),
  ADD KEY `ProductID` (`ProductID`);

--
-- Indexes for table `tbproduct`
--
ALTER TABLE `tbproduct`
  ADD PRIMARY KEY (`ProductID`),
  ADD KEY `UnitID` (`UnitID`,`CategoryID`),
  ADD KEY `CID` (`CategoryID`),
  ADD KEY `FK_Product_Author` (`authorsID`);

--
-- Indexes for table `tbrole`
--
ALTER TABLE `tbrole`
  ADD PRIMARY KEY (`RID`);

--
-- Indexes for table `tbsell`
--
ALTER TABLE `tbsell`
  ADD PRIMARY KEY (`SellID`),
  ADD KEY `FK_Sell_Employee` (`EmployeeID`);

--
-- Indexes for table `tbselldetail`
--
ALTER TABLE `tbselldetail`
  ADD PRIMARY KEY (`SellDetailID`),
  ADD KEY `ProID` (`ProductID`),
  ADD KEY `SID` (`SellID`);

--
-- Indexes for table `tbsupplier`
--
ALTER TABLE `tbsupplier`
  ADD PRIMARY KEY (`SupplierID`);

--
-- Indexes for table `tbunit`
--
ALTER TABLE `tbunit`
  ADD PRIMARY KEY (`UnitID`);

--
-- Indexes for table `tbuser`
--
ALTER TABLE `tbuser`
  ADD PRIMARY KEY (`UID`),
  ADD KEY `Position` (`Position`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbactivity_log`
--
ALTER TABLE `tbactivity_log`
  MODIFY `LogID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `tbimport`
--
ALTER TABLE `tbimport`
  MODIFY `ImportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `tbimportdetail`
--
ALTER TABLE `tbimportdetail`
  MODIFY `ImportDetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `tbrole`
--
ALTER TABLE `tbrole`
  MODIFY `RID` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbsell`
--
ALTER TABLE `tbsell`
  MODIFY `SellID` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `tbselldetail`
--
ALTER TABLE `tbselldetail`
  MODIFY `SellDetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `tbsupplier`
--
ALTER TABLE `tbsupplier`
  MODIFY `SupplierID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT for table `tbuser`
--
ALTER TABLE `tbuser`
  MODIFY `UID` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbimport`
--
ALTER TABLE `tbimport`
  ADD CONSTRAINT `tbimport_ibfk_1` FOREIGN KEY (`CreatedBy`) REFERENCES `tbuser` (`UID`);

--
-- Constraints for table `tbimportdetail`
--
ALTER TABLE `tbimportdetail`
  ADD CONSTRAINT `tbimportdetail_ibfk_1` FOREIGN KEY (`ImportID`) REFERENCES `tbimport` (`ImportID`) ON DELETE CASCADE,
  ADD CONSTRAINT `tbimportdetail_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `tbproduct` (`ProductID`) ON DELETE CASCADE;

--
-- Constraints for table `tbproduct`
--
ALTER TABLE `tbproduct`
  ADD CONSTRAINT `CID` FOREIGN KEY (`CategoryID`) REFERENCES `tbcategory` (`CategoryID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Product_Author` FOREIGN KEY (`authorsID`) REFERENCES `tbauthor` (`authorID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `UID` FOREIGN KEY (`UnitID`) REFERENCES `tbunit` (`UnitID`) ON UPDATE CASCADE;

--
-- Constraints for table `tbsell`
--
ALTER TABLE `tbsell`
  ADD CONSTRAINT `FK_Sell_Employee` FOREIGN KEY (`EmployeeID`) REFERENCES `tbuser` (`UID`) ON UPDATE CASCADE;

--
-- Constraints for table `tbselldetail`
--
ALTER TABLE `tbselldetail`
  ADD CONSTRAINT `ProID` FOREIGN KEY (`ProductID`) REFERENCES `tbproduct` (`ProductID`),
  ADD CONSTRAINT `SID` FOREIGN KEY (`SellID`) REFERENCES `tbsell` (`SellID`);

--
-- Constraints for table `tbuser`
--
ALTER TABLE `tbuser`
  ADD CONSTRAINT `Position` FOREIGN KEY (`Position`) REFERENCES `tbrole` (`RID`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
