-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 11, 2025 at 04:57 AM
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
(2, 'Hideo Kojima');

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
('1230', 'book'),
('13', 'Nawatniyai'),
('Fd1112', 'Food'),
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
(1, '2025-06-02', '08:40:00', 15, 375000.00, 'Hasann', '2022136258', '12123', ' [CANCELLED: Status changed from app]', 'Cancelled', 1, '2025-06-02 08:46:43'),
(2, '2025-06-02', '08:47:00', 10, 150000.00, 'Hasann', '2022136258', '12125', '', 'Completed', 1, '2025-06-02 08:47:51'),
(3, '2025-06-02', '09:40:00', 30, 750000.00, 'Cityplex', '2022136258', '', ' [CANCELLED: Status changed from app]', 'Cancelled', 1, '2025-06-02 09:41:09'),
(4, '2025-06-14', '15:56:00', 15, 255000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 15:57:51'),
(5, '2025-06-14', '16:01:00', 21, 453000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 16:02:56'),
(6, '2025-06-14', '16:07:00', 15, 240000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 16:08:13'),
(7, '2025-07-05', '11:40:00', 6, 20400.00, 'Maxza', '2058384765', 'gesgdr', '', 'Completed', 1, '2025-07-05 11:43:50'),
(8, '2025-07-08', '11:05:00', 100, 2500000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-08 11:06:32'),
(9, '2025-07-08', '11:10:00', 6, 330000.00, 'Cityplex', '2022136258', '', ' [CANCELLED: Status changed from app]', 'Completed', 1, '2025-07-08 11:11:04'),
(10, '2025-07-08', '17:21:00', 4, 200000.00, 'Maxza', '2058384765', '', ' [CANCELLED: No reason provided]', 'Cancelled', 1, '2025-07-08 17:21:41'),
(11, '2025-07-08', '17:29:00', 6, 90000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-08 17:29:24'),
(12, '2025-07-09', '09:14:00', 5, 210000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-09 09:14:53'),
(13, '2025-07-09', '09:23:00', 5, 75000.00, 'Maxza', '2058384765', '', ' [CANCELLED: No reason provided]', 'Completed', 1, '2025-07-09 09:23:56'),
(14, '2025-07-09', '09:45:00', 11, 165000.00, 'Maxza', '2058384765', '', ' [CANCELLED: No reason provided] [CANCELLED: Status changed from app]', 'Cancelled', 1, '2025-07-09 09:46:05'),
(15, '2025-07-09', '09:53:00', 20, 1000000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-09 09:53:30'),
(16, '2025-07-09', '09:55:00', 20, 1000000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-09 09:55:24'),
(17, '2025-07-09', '10:02:00', 10, 1000000.00, 'Cityplex', '2022136258', '', 'ສົງວ', 'Completed', 1, '2025-07-09 10:04:46'),
(18, '2025-07-09', '10:10:00', 20, 300000.00, 'Cityplex', '2022136258', '', '', 'Completed', 1, '2025-07-09 10:10:53'),
(19, '2025-07-09', '10:13:00', 15, 300000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-09 10:13:52'),
(20, '2025-07-09', '10:29:00', 20, 300000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-09 10:29:57'),
(21, '2025-07-09', '10:31:00', 15, 300000.00, 'Cityplex', '2022136258', '', '', 'Completed', 1, '2025-07-09 10:32:02'),
(22, '2025-07-09', '10:57:00', 50, 750000.00, 'Cityplex', '2022136258', '', '', 'Completed', 1, '2025-07-09 10:58:19'),
(23, '2025-07-09', '11:16:00', 30, 600.00, 'Cityplex', '2022136258', '', '', 'Completed', 1, '2025-07-09 11:17:03'),
(24, '2025-07-09', '14:13:00', 50, 250000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-09 14:13:44'),
(25, '2025-07-10', '16:26:00', 20, 300000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-10 16:26:50'),
(26, '2025-07-11', '09:13:00', 25, 375000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-07-11 09:15:00');

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
(13, 8, 'Kpo1112', 100, 25000.00, 2500000.00, 56, 156, NULL),
(14, 9, 'Tgh1111', 6, 55000.00, 330000.00, 39, 45, NULL),
(15, 10, 'Kpo1112', 4, 50000.00, 200000.00, 256, 260, NULL),
(16, 11, 'Lay1111', 6, 15000.00, 90000.00, 44, 50, NULL),
(17, 12, 'Tgh1111', 5, 42000.00, 210000.00, 39, 44, NULL),
(18, 13, 'Tgh1111', 5, 15000.00, 75000.00, 45, 50, NULL),
(19, 14, 'Kpo1112', 11, 15000.00, 165000.00, 256, 267, NULL),
(20, 15, 'Lay1111', 20, 50000.00, 1000000.00, 50, 70, NULL),
(21, 16, 'Tgh1111', 20, 50000.00, 1000000.00, 50, 70, NULL),
(22, 17, 'Lay1111', 10, 100000.00, 1000000.00, 50, 60, NULL),
(23, 18, 'Lay1111', 20, 15000.00, 300000.00, 60, 80, NULL),
(24, 19, 'Lay1111', 15, 20000.00, 300000.00, 100, 115, NULL),
(25, 20, 'Kpo1155', 20, 15000.00, 300000.00, 30, 50, NULL),
(26, 21, 'Kpo1155', 15, 20000.00, 300000.00, 50, 65, NULL),
(27, 22, 'Kpo1119', 50, 15000.00, 750000.00, 29, 79, NULL),
(28, 23, 'Tgh1111', 30, 20.00, 600.00, 70, 100, NULL),
(29, 24, 'Ois1114', 50, 5000.00, 250000.00, 52, 102, NULL),
(30, 25, 'Kpo1155', 20, 15000.00, 300000.00, 65, 85, NULL),
(31, 26, 'Ois1114', 10, 15000.00, 150000.00, 102, 112, NULL),
(32, 26, 'Tgh1111', 15, 15000.00, 225000.00, 105, 120, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tbproduct`
--

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
  `Level` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbproduct`
--

INSERT INTO `tbproduct` (`ProductID`, `ProductName`, `Quantity`, `ImportPrice`, `SellPrice`, `UnitID`, `CategoryID`, `authorsID`, `Balance`, `Level`) VALUES
('Kpo1112', 'Kraprao_Freeze', 256, 33000, 37000, '14', '1230', 2, 270, 5),
('Kpo1119', 'Kraprao_fatasses', 79, 33000, 37000, 'Bg1112', 'Fd1112', 1, 100, 5),
('Kpo1155', 'Kraprao_fastest', 85, 33000, 37000, 'Bg1112', 'Fd1112', 1, 85, 5),
('l2', 'vhf', 5, 8, 1, '15', 'Wtr1111', 1, 0, 5),
('Lay1111', 'Lay_Original_Big_Bag', 115, 15000, 18000, 'Bg1112', 'Fd1112', 1, 131, 10),
('Ois1114', 'Oishi_small', 112, 12000, 15000, 'bt1115', 'Wtr1111', 1, 116, 10),
('Tgh1111', 'Tiger_Head_Big', 120, 8000, 10000, 'bt1115', 'Wtr1111', 1, 123, 5);

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
(1, 'Employee', 2500000),
(2, 'Admin', 3500000),
(5, 'RameNole', 2000);

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
(8, '2025-05-13', '14:00', 20000.00, 20000.00, 30000.00, 10000.00, 'Cash', 0, '0'),
(9, '2025-05-13', '12:53:19', 111000.00, 111000.00, 120000.00, 9000.00, 'CASH', 0, '0'),
(10, '2025-05-13', '13:01:19', 129000.00, 129000.00, 130000.00, 1000.00, 'CASH', 0, '0'),
(11, '2025-05-13', '13:04:17', 15000.00, 15000.00, 20000.00, 5000.00, 'CASH', 0, '0'),
(12, '2025-05-13', '13:49:16', 185000.00, 185000.00, 200000.00, 15000.00, 'CASH', 0, '0'),
(13, '2025-05-13', '13:52:42', 10000.00, 10000.00, 10000.00, 0.00, 'CASH', 0, '0'),
(14, '2025-05-13', '14:01:58', 370000.00, 370000.00, 400000.00, 30000.00, 'CASH', 0, '0'),
(15, '2025-07-04', '23:51:43', 74000.00, 74000.00, 74000.00, 0.00, 'CASH', 1, 'M001'),
(16, '2025-07-05', '11:17:58', 65000.00, 65000.00, 70000.00, 5000.00, 'CASH', 1, 'M001');

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
(21, 16, 'Tgh1111', 10000.00, 2, '20000.0');

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
(102, 'Maxza', 'Maxy', '2058384765', 'Maxlnwza004@gmail.com', 'Khoihong', 'Active', '2025-05-27 12:32:16');

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
('14', 'ຫົວ'),
('15', 'Ted'),
('2221', 'ແພັກ'),
('Bg1112', 'Bag'),
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
(2, 'Test', 'Subject', '2011-11-11', 'ຊາຍ', 1, 'TestSubject@gmail.co', 1, '1'),
(7, 'tes', 'tesin', '11/07/2002', 'ຍິງ', 2035262353, 'Tes@gmail.com', 1, '11111111');

--
-- Indexes for dumped tables
--

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
  ADD KEY `AID` (`authorsID`);

--
-- Indexes for table `tbrole`
--
ALTER TABLE `tbrole`
  ADD PRIMARY KEY (`RID`);

--
-- Indexes for table `tbsell`
--
ALTER TABLE `tbsell`
  ADD PRIMARY KEY (`SellID`);

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
-- AUTO_INCREMENT for table `tbimport`
--
ALTER TABLE `tbimport`
  MODIFY `ImportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `tbimportdetail`
--
ALTER TABLE `tbimportdetail`
  MODIFY `ImportDetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `tbrole`
--
ALTER TABLE `tbrole`
  MODIFY `RID` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbsell`
--
ALTER TABLE `tbsell`
  MODIFY `SellID` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `tbselldetail`
--
ALTER TABLE `tbselldetail`
  MODIFY `SellDetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `tbsupplier`
--
ALTER TABLE `tbsupplier`
  MODIFY `SupplierID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT for table `tbuser`
--
ALTER TABLE `tbuser`
  MODIFY `UID` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  ADD CONSTRAINT `AID` FOREIGN KEY (`authorsID`) REFERENCES `tbauthor` (`authorID`),
  ADD CONSTRAINT `CID` FOREIGN KEY (`CategoryID`) REFERENCES `tbcategory` (`CategoryID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `UID` FOREIGN KEY (`UnitID`) REFERENCES `tbunit` (`UnitID`) ON UPDATE CASCADE;

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
