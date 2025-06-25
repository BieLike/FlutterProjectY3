-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 25, 2025 at 07:15 AM
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
('12', 'ນະວັດນິຍາຍ'),
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
(1, '2025-06-02', '08:40:00', 15, 375000.00, 'Hasann', '2022136258', '12123', '', 'Pending', 1, '2025-06-02 08:46:43'),
(2, '2025-06-02', '08:47:00', 10, 150000.00, 'Hasann', '2022136258', '12125', '', 'Completed', 1, '2025-06-02 08:47:51'),
(3, '2025-06-02', '09:40:00', 30, 750000.00, 'Cityplex', '2022136258', '', ' [CANCELLED: Status changed from app]', 'Cancelled', 1, '2025-06-02 09:41:09'),
(4, '2025-06-14', '15:56:00', 15, 255000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 15:57:51'),
(5, '2025-06-14', '16:01:00', 21, 453000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 16:02:56'),
(6, '2025-06-14', '16:07:00', 15, 240000.00, 'Maxza', '2058384765', '', '', 'Completed', 1, '2025-06-14 16:08:13');

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
(11, 6, 'Tgh1111', 1, 10000.00, 10000.00, 39, 40, NULL);

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
  `Balance` int(5) NOT NULL,
  `Level` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tbproduct`
--

INSERT INTO `tbproduct` (`ProductID`, `ProductName`, `Quantity`, `ImportPrice`, `SellPrice`, `UnitID`, `CategoryID`, `Balance`, `Level`) VALUES
('Kpo1112', 'Kraprao_Freeze', 35, 33000, 37000, 'Bg1112', 'Fd1112', 54, 5),
('Kpo1119', 'Kraprao_fatasses', 25, 33000, 37000, 'Bg1112', 'Fd1112', 50, 5),
('Kpo1155', 'Kraprao_fastest', 30, 33000, 37000, 'Bg1112', 'Fd1112', 30, 5),
('Lay1111', 'Lay_Original_Big_Bag', 44, 15000, 18000, 'Bg1112', 'Fd1112', 60, 10),
('Ois1114', 'Oishi_small', 45, 12000, 15000, 'bt1115', 'Wtr1111', 46, 10),
('Tgh1111', 'Tiger_Head_Big', 40, 8000, 10000, 'bt1115', 'Wtr1111', 41, 5);

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
(1, '05/12/2025', '', 150000.00, 150000.00, 167000.00, 17000.00, 'card', 1, '1'),
(6, '11/3/2025', '12:30', 20.00, 20.00, 50.00, 30.00, 'Cash', 0, '0'),
(7, '11/3/2025', '12:30', 20.00, 20.00, 50.00, 30.00, 'Cash', 0, '0'),
(8, '2025-05-13', '14:00', 20000.00, 20000.00, 30000.00, 10000.00, 'Cash', 0, '0'),
(9, '2025-05-13', '12:53:19', 111000.00, 111000.00, 120000.00, 9000.00, 'CASH', 0, '0'),
(10, '2025-05-13', '13:01:19', 129000.00, 129000.00, 130000.00, 1000.00, 'CASH', 0, '0'),
(11, '2025-05-13', '13:04:17', 15000.00, 15000.00, 20000.00, 5000.00, 'CASH', 0, '0'),
(12, '2025-05-13', '13:49:16', 185000.00, 185000.00, 200000.00, 15000.00, 'CASH', 0, '0'),
(13, '2025-05-13', '13:52:42', 10000.00, 10000.00, 10000.00, 0.00, 'CASH', 0, '0'),
(14, '2025-05-13', '14:01:58', 370000.00, 370000.00, 400000.00, 30000.00, 'CASH', 0, '0');

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
(1, 1, 'Kpo1112', 15000.00, 2, '30'),
(2, 1, 'Kpo1119', 17000.00, 3, '51000'),
(3, 6, 'Kpo1112', 10.00, 2, '20'),
(4, 6, 'Kpo1119', 15.00, 1, '15'),
(5, 7, 'Kpo1112', 10.00, 2, '20'),
(6, 7, 'Kpo1119', 15.00, 1, '15'),
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
(17, 14, 'Kpo1119', 37000.00, 1, '37000');

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
(1, 'Sanhsaveng', 'KeoKham', '18/07/2013', 'ຍິງ', 2023152562, 'Sanhsaveng@gmail.com', 2, '12123'),
(2, 'Test', 'Subject', '2011-11-11', 'ຊາຍ', 2052135264, 'TestSubject@gmail.co', 1, 'Tes111'),
(7, 'tes', 'tesin', '11/07/2002', 'ຍິງ', 2035262353, 'Tes@gmail.com', 1, '11111111');

--
-- Indexes for dumped tables
--

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
  ADD KEY `CID` (`CategoryID`);

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
  MODIFY `ImportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `tbimportdetail`
--
ALTER TABLE `tbimportdetail`
  MODIFY `ImportDetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `tbrole`
--
ALTER TABLE `tbrole`
  MODIFY `RID` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbsell`
--
ALTER TABLE `tbsell`
  MODIFY `SellID` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `tbselldetail`
--
ALTER TABLE `tbselldetail`
  MODIFY `SellDetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

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
