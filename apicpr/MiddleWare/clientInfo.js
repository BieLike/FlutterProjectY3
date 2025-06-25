// ເພີ່ມການເກັບ client info ໃນ middleware 
/*
 ໃຊ້ middleware ເພື່ອກຳນົດ logic ເຮັດວຽກທີ່ຕ້ອງໃຊ້ຊໍ້າໃນຫຼາຍ route ໃນເທື່ອດຽວ,
 ເພື່ອໃສ່ໃນແອັບພຣິເຄຊັ່ນມັນຈະເຮັດວຽກກັບທຸກ request ທີ່ເຂົ້າມາໂດຍບໍ່ເພື່ມໂຄດໃນແຕ່ລະ endpoint
 ເຮັດຫນ້າທີ່:ດຶງ ip ແລະ user-agent ຈາກ request headers, ດຶງຊື່ເຄື່ອງຈາກ header ທີ່ client ສົ່ງມາ,ເກັບຂໍ້ມູນໄວ້ໃນ req.clientInfo ເພື່ອໃຫ້ route ຕ່າງໆ ສາມາດເຂົ້າເຖິງ ແລະ ໃຊ້ງານໄດ້ໂດບບໍ່ດຶງຂໍ້ມູນຊໍ້າ
*/ 
const express = require('express');
const os = require('os'); // ໃຊ້ເພື່ອດຶງຂໍ້ມູນເຄື່ອງ

const clientInfoMiddleware = (req, res, next) => {
  // ເກັບຂໍ້ມູນ IP address ແລະ hostname ຂອງ client
  const clientIP = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  const serverHostname = os.hostname(); // ຊື່ເຄື່ອງ server
  
  // ເກັບຂໍ້ມູນໃນ request object ເພື່ອໃຊ້ໃນການບັນທຶກຄັ້ງຕໍ້ໄປ
  req.clientInfo = {
    ip: clientIP,
    userAgent: req.headers['user-agent'] || 'Unknown',
    hostname: req.headers['x-hostname'] || 'Unknown Computer', // client ຈະສົ່ງ header ມາໃຫ້
    serverHostname: serverHostname
  };

  next();
};

module.exports = clientInfoMiddleware;