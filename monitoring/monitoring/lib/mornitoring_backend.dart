import 'dart:async'; // ໃຊ້ Timer ແລະ Future
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //ຈັດຮູບແບບວັນແລະເວລາ
import 'package:intl/intl.dart';
import 'api_service.dart';

// ຄລາສກຳນົດຄ່າ API Host ແລະ URL
class ApiConfig {
  static const String host = "Localhost"; // IP address ຂອງ server
  static const int port = 3000; // port ຂອງ server
  static const String baseUrl = "http://$host:$port/main"; // URL ຫຼັກຂອງ API
}

class MornitoringBackend extends StatefulWidget {
  const MornitoringBackend({Key? key}) : super(key: key);

  @override
  State<MornitoringBackend> createState() => _MornitoringBackendState();
}

class _MornitoringBackendState extends State<MornitoringBackend> {
  List<ActivityLog> logs = []; //ລາຍການບັນທຶກກິດຈະກຳການປ່ຽນແປງໃນລະບົບ
  // Map ສຳລັບເກັບຂໍ້ມູນລ່າສຸດຂອງແຕ່ລະຕາຕະລາງ
  Map<String, List<dynamic>> previousData = {
    'product': [],
    'book': [],
    'unit': [],
    'category': [],
  };
  bool isLoading = true; // ສະຖານະໂຫຼດຂໍ້ມູນ
  bool initialDataLoaded =
      false; // ເພີ່ມຕົວປ່ຽນເພື່ອຕິດຕາມວ່າໂຫຼດຂໍ້ມູນເລີ່ມຕົ້ນແລ້ວຫຼືບໍ່
  Timer? _timer; //ຕັ້ງເວລາສຳລັບກວດສອບການປ່ຽນແປງເປັນໄລຍະ
  final ScrollController _scrollController =
      ScrollController(); // ຕົວຄວບຄຸມການເລື່ອນລາຍການ

  @override
  void initState() {
    super.initState();
    // ເອີ້ນຟັງຊັນ initDeviceInfo ເພື່ອດຶງຂໍ້ມູນອຸປະກອນ
    ApiService.initDeviceInfo().then((_) {
      fetchInitialData(); // ຫຼັງຈາກດຶງຂໍ້ມູນອຸປະກອນແລ້ວ ໃຫ້ດຶງຂໍ້ມູນເລີ່ມຕົ້ນ
    });

    // ຕັ້ງເວລາການກວດການປ່ຽນແປງທຸກ 2 ວິນາທີ
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      checkForChanges(); // ເອີ້ນຟັງຊັນກວດສອບການປ່ຽນແປງ
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ດຶງຂໍ້ມູນເລີ່ມຕົ້ນ
  Future<void> fetchInitialData() async {
    setState(() {
      isLoading = true; //ເລີ່ມສະຖານະການໂຫຼດ
    });

    try {
      // ດຶງຂໍ້ມູນຕາຕະລາງ - ດຶງຂໍ້ມູນມາເກັບໄວ້ເພື່ອປຽບທຽບໃນຄັ້ງຕໍ່ໄປ
      await _loadTableDataSilently('product');
      await _loadTableDataSilently('book');
      await _loadTableDataSilently('unit');
      await _loadTableDataSilently('category');

      // ຕັ້ງຄ່າວ່າໂຫຼດຂໍ້ມູນເລີ່ມຕົ້ນແລ້ວ
      initialDataLoaded = true;
    } catch (e) {
      print('Error loading initial data: $e'); //ສະແດງຂໍ້ຜິດພາດການໂຫຼດ
    } finally {
      setState(() {
        isLoading = false; //ສິ້ນສຸດການໂຫຼດ
      });
    }
  }

  // ຟັງຊັນດຶງຂໍ້ມູນຕາຕະລາງເພື່ອເກັບໄວ້ປຽບທຽບ
  Future<void> _loadTableDataSilently(String endpoint) async {
    try {
      // ສົ່ງ GET request ໄປ API
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/$endpoint'));
      if (response.statusCode == 200) {
        // ຖ້າ request ສຳເລັດ
        List<dynamic> currentData =
            json.decode(response.body); // ແປງຂໍ້ມູນ JSON
        previousData[endpoint] = currentData; //ເກັບຂໍ້ມູນໄວ້ໃນ Map
      }
    } catch (e) {
      print('Error loading initial $endpoint data: $e');
    }
  }

  // ຟັງຊັນສຳລັບກວດສອບການປ່ຽນແປງຂໍ້ມູນໃນຖານຂໍ້ມູນ
  Future<void> checkForChanges() async {
    // ກວດສອບວ່າໂຫຼດຂໍ້ມູນເລີ່ມຕົ້ນແລ້ວຫຼືບໍ່
    if (!initialDataLoaded) return; //ຖ້າບໍ່ໂຫຼດໃຫ້ອອກຈາກຟັງຊັນ

    try {
      //ກວດສອບການປ່ຽນແປງຂອງແຕ່ລະຕາຕະລາງ
      await fetchTableData('product');
      await fetchTableData('book');
      await fetchTableData('unit');
      await fetchTableData('category');
    } catch (e) {
      print('Error checking for changes: $e');
    }
  }

  //ຟັງຊັນດຶງຂໍ້ມູນຈາກຕາຕະລາງ ແລະ ປຽບທຽບກັບຂໍ້ມູນເກົ່າ
  Future<void> fetchTableData(String endpoint) async {
    try {
      final url =
          '${ApiConfig.baseUrl}/$endpoint'; // ສ້າງ URL ສຳລັບການເອີ້ນ API
      print('Fetching data from: $url');
      // ສົ່ງ GET request ໄປ API
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/$endpoint'));

      if (response.statusCode == 200) {
        // ຖ້າ request ສຳເລັດ
        List<dynamic> currentData =
            json.decode(response.body); // ແປງຂໍ້ມູນ JSON
        print('Got ${currentData.length} items from $endpoint'); //ສະແດງຈຳນວນ
        List<dynamic> oldData = previousData[endpoint] ?? []; // ດຶງຂໍ້ມູນເກົ່າ
        print(
            'Comparing with ${oldData.length} previous items'); //ສະແດງຂໍ້ມູນເກົ່າ

        // ກວດສອບການປ່ຽນແປງ
        _detectChanges(oldData, currentData, endpoint);

        // ອັບເດດຂໍ້ມູນເກົ່າດ້ວຍຂໍ້ມູນໃໝ່
        previousData[endpoint] = currentData;
      }
    } catch (e) {
      print('Error fetching $endpoint data: $e');
    }
  }

  // ຟັງຊັນສຳລັບກວດຈັບການປ່ຽນແປງຂໍ້ມູນ
  void _detectChanges(
      List<dynamic> oldData, List<dynamic> newData, String endpoint) {
    String idField = _getIdFieldName(endpoint); // ຊື່feild ID ຂອງຕາຕະລາງ
    String nameField = _getNameFieldName(endpoint); //ຊື່feildຂອງຕາຕະລາງ

    // ສ້າງ map ຈາກຂໍ້ມູນເກົ່າເພື່ອຄົ້ນຫາໄດ້ໄວຂຶ້ນໂດຍໃຊ້ ID ເປັນ key
    Map<String, dynamic> oldMap = {};
    for (var item in oldData) {
      if (item[idField] != null) {
        // ກວດສອບວ່າ ID ມີຄ່າຫຼືບໍ່
        oldMap[item[idField].toString()] = item; // ເກັບຂໍ້ມູນໃນ map
      }
    }
    // ສ້າງ map ຈາກຂໍ້ມູນໃໝ່ເພື່ອຄົ້ນຫາໄດ້ໄວຂຶ້ນໂດຍໃຊ້ ID ເປັນ key
    Map<String, dynamic> newMap = {};
    for (var item in newData) {
      if (item[idField] != null) {
        // ກວດສອບວ່າ ID ມີຄ່າຫຼືບໍ່
        newMap[item[idField].toString()] = item; // ເກັບຂໍ້ມູນໃນ map
      }
    }

    // ກວດສອບຂໍ້ມູນທີ່ເພີ່ມມາໃໝ່
    for (var id in newMap.keys) {
      // ລູບຜ່ານ ID ທັງໝົດໃນຂໍ້ມູນໃໝ່
      if (!oldMap.containsKey(id)) {
        // ຖ້າ ID ນີ້ບໍ່ມີໃນຂໍ້ມູນເກົ່າ ສະແດງວ່າເປັນຂໍ້ມູນໃໝ່
        String name =
            newMap[id][nameField]?.toString() ?? id; // ດຶງຊື່ຂອງລາຍການ
        print('Found new item: $name (ID: $id)'); //ສະແດງຂໍ້ຄວາມ

        // ດຶງຂໍ້ມູນເຄື່ອງທີ່ເຮັດກິດຈະກຳ
        String computerName = 'Unknown Computer'; // ຄ່າເລີ່ມຕົ້ນ
        bool isServer = false;
        if (newMap[id]['clientInfo'] != null) {
          if (newMap[id]['clientInfo']['serverHostname'] != null) {
            // ກິດຈະກຳຈາກ server
            computerName = newMap[id]['clientInfo']['serverHostname'];
            isServer = true;
          } else if (newMap[id]['clientInfo']['hostname'] != null) {
            // ກິດຈະກຳຈາກ client
            computerName = newMap[id]['clientInfo']['hostname'];
            isServer = false;
          }
        }
        //ເພີ່ມບັນທຶກກິດຈະກຳ
        _addLog(
            'ເພີ່ມຂໍ້ມູນໃໝ່: $name (ID: $id)', //ຂໍ້ຄວາມ
            endpoint, //ຕາຕະລາງ
            'ເພີ່ມ', //ປະເພດກິດຈະກຳ
            computerName: computerName, //ຊື່ເຄື່ອງ client
            isServer: isServer //ຊື່ເຄື່ອງ server
            );
      }
    }

    // ກວດສອບຂໍ້ມູນທີ່ຖືກລຶບ
    for (var id in oldMap.keys) {
      // ລູບຜ່ານ ID ທັງໝົດໃນຂໍ້ມູນເກົ່າ
      if (!newMap.containsKey(id)) {
        // ຖ້າ ID ນີ້ບໍ່ມີໃນຂໍ້ມູນໃໝ່ ສະແດງວ່າຖືກລົບ
        String name =
            oldMap[id][nameField]?.toString() ?? id; // ດຶງຊື່ຂອງລາຍການ
        print('Found deleted item: $name (ID: $id)'); //ສະແດງຂໍ້ຄວາມ

        // ດຶງຂໍ້ມູນເຄື່ອງທີ່ເຮັດກິດຈະກຳ
        String computerName = 'Unknown Computer'; // ຄ່າເລີ່ມຕົ້ນ
        bool isServer = false;
        if (oldMap[id]['clientInfo'] != null) {
          if (newMap[id]['clientInfo']['serverHostname'] != null) {
            // ກິດຈະກຳຈາກ server
            computerName = newMap[id]['clientInfo']['serverHostname'];
            isServer = true;
          } else if (newMap[id]['clientInfo']['hostname'] != null) {
            // ກິດຈະກຳຈາກ client
            computerName = newMap[id]['clientInfo']['hostname'];
            isServer = false;
          }
        }
        //ເພີ່ມບັນທຶກກິດຈະກຳ
        _addLog(
            'ລຶບຂໍ້ມູນ: $name (ID: $id)', //ຂໍ້ຄວາມ
            endpoint, //ຕາຕະລາງ
            'ລຶບ', //ປະເພດກິດຈະກຳ
            computerName: computerName, //ຊື່ເຄື່ອງ client
            isServer: isServer //ຊື່ເຄື່ອງ server
            );
      }
    }

    // ກວດສອບຂໍ້ມູນທີ່ຖືກແກ້ໄຂ
    for (var id in oldMap.keys) {
      // ລູບຜ່ານ ID ທັງໝົດໃນຂໍ້ມູນເກົ່າ
      if (newMap.containsKey(id)) {
        // ຖ້າ ID ນີ້ມີໃນຂໍ້ມູນໃໝ່ນຳ
        var oldItem = oldMap[id]; //ຂໍ້ມູນເກົ່າ
        var newItem = newMap[id]; //ຂໍ້ມູນໃໝ່
        // ເກັບລາຍການປ່ຽນແປງ
        List<String> changes = [];
        for (var key in newItem.keys) {
          //ລູບຜ່ານທຸກ feild ໃນຂໍ້ມູນໃໝ່
          //ຂ້າມ feild clientInfo ແລະ ກວດສອບວ່າມີການປ່ຽນແປງຫຼືບໍ່
          if (key != 'clientInfo' &&
              oldItem.containsKey(key) &&
              oldItem[key] != newItem[key]) {
            changes.add(
                '$key: ${oldItem[key]} → ${newItem[key]}'); //ເພີ່ມການປ່ຽນແປງໃນລາຍການ
          }
        }

        if (changes.isNotEmpty) {
          // ຖ້າມີການປ່ຽນແປງ
          String name = newItem[nameField]?.toString() ?? id; //ດຶງຊື່ຂອງລາຍການ
          print(
              'Found updated item: $name (ID: $id) with changes: ${changes.join(", ")}'); //ສະແດງຂໍ້ຄວາມ
          // ດຶງຂໍ້ມູນເຄື່ອງທີ່ເຮັດກິດຈະກຳ
          String computerName = 'Unknown Computer'; // ຄ່າເລີ່ມຕົ້ນ
          bool isServer = false;
          if (newMap[id]['clientInfo'] != null) {
            if (newMap[id]['clientInfo']['serverHostname'] != null) {
              // ກິດຈະກຳຈາກ server
              computerName = newMap[id]['clientInfo']['serverHostname'];
              isServer = true;
            } else if (newMap[id]['clientInfo']['hostname'] != null) {
              // ກິດຈະກຳຈາກ client
              computerName = newMap[id]['clientInfo']['hostname'];
              isServer = false;
            }
          }
          //ເພີ່ມບັນທຶກກິດຈະກຳ
          _addLog(
              'ແກ້ໄຂຂໍ້ມູນ: $name (ID: $id)\nຂໍ້ມູນທີ່ປ່ຽນແປງ: ${changes.join(", ")}', //ຂໍ້ຄວາມ
              endpoint, //ຕາຕະລາງ
              'ແກ້ໄຂ', //ປະເພດກິດຈະກຳ
              computerName: computerName, //ຊື່ເຄື່ອງ client
              isServer: isServer //ຊື່ເຄື່ອງ server
              );
        }
      }
    }
  }

  // ເພີ່ມການບັນທຶກໃໝ່
  void _addLog(String message, String table, String action,
      {bool isError = false,
      required String computerName,
      required bool isServer}) {
    setState(() {
      logs.insert(
          0,
          ActivityLog(
            message: message,
            timestamp: DateTime.now(),
            table: table,
            action: action,
            isError: isError,
            computerName: computerName,
            isServer: isServer,
          ));

      // ຈຳກັດການບັນທຶກສູງສຸດ 100 ລາຍການ
      if (logs.length > 100) {
        logs.removeLast();
      }
    });
  }

  // ຊື່ feild ID ຂອງແຕ່ລະຕາຕະລາງ
  String _getIdFieldName(String endpoint) {
    switch (endpoint) {
      case 'product':
        return 'ProductID';
      case 'book':
        return 'BID';
      case 'unit':
        return 'UnitID';
      case 'category':
        return 'CategoryID';
      default:
        return 'id';
    }
  }

  // ຊື່ feild ທີ່ໃຊ້ສະແດງຊື່ຂອງຕາຕະລາງ
  String _getNameFieldName(String endpoint) {
    switch (endpoint) {
      case 'product':
        return 'ProductName';
      case 'book':
        return 'Bname';
      case 'unit':
        return 'UnitName';
      case 'category':
        return 'CategoryName';
      default:
        return 'name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ສ່ວນສະແດງສະຖານະ
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'ກຳລັງຕິດຕາມຂໍ້ມູນ... (${ApiConfig.host}:${ApiConfig.port})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.sync, color: Colors.blue),
                SizedBox(width: 5),
                Text(
                    'ແກ້ໄຂລ້າສຸດ: ${DateFormat('HH:mm:ss').format(DateTime.now())}')
              ],
            ),
          ),

          // ສ່ວນສະແດງບັນທຶກກິດຈະກຳ
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : logs.isEmpty
                    ? Center(child: Text('ຍັງບໍ່ທັນມີກິດຈະກຳໃໝ່ໃດໆ'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return _buildActivityItem(log);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ສ້າງລາຍການກິດຈະກຳ
  Widget _buildActivityItem(ActivityLog log) {
    Color getActionColor() {
      switch (log.action) {
        case 'ເພີ່ມ':
          return Colors.green;
        case 'ແກ້ໄຂ':
          return Colors.orange;
        case 'ລຶບ':
          return Colors.red;
        default:
          return Colors.blue;
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getActionColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.action,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.table,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Spacer(),
                Text(
                  DateFormat('HH:mm:ss ,dd/MM/yyyy').format(log.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              log.message,
              style: TextStyle(
                fontSize: 14,
                color: log.isError ? Colors.red : Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.computer,
                  size: 14,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4),
                Text(
                  'ຈາກເຄື່ອງ: ${log.isServer ? "server" : "client"}(${log.computerName})', // ສະແດງຊື່ເຄື່ອງ
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityLog {
  final String message;
  final DateTime timestamp;
  final String table;
  final String action;
  final bool isError;
  final String computerName;
  final bool isServer;

  ActivityLog({
    required this.message,
    required this.timestamp,
    required this.table,
    required this.action,
    this.isError = false,
    required this.computerName, //ຊື່ client
    required this.isServer, //ຊື່ Server
  });
}
