import 'dart:convert'; //ແປງຂໍ້ມູນ json
import 'dart:io'; //ເພື່ອໃຊ້ກວດລະບົບປະຕິບັດການ
import 'package:device_info_plus/device_info_plus.dart'; //ລົງເພື່ມເພື່ອໃຊ້ deviceinfo ດຶງຂໍ້ມູນອຸປະກອນ ລົງໃນ pubspec ນຳ device_info_plus: ^11.3.0
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/main';

  //ເພີ່ມຕົວປ່ຽນສຳລັບເກັບຊື່ເຄື່ອງ ເພື່ອເຂົ້າໄດ້ເຖິງຈາກທຸກທີ່
  static String? deviceName;

  //ຟັງຊັນດຶງຊື່ເຄື່ອງຈາກອຸປະກອນນັ້ນ
  static Future<void> initDeviceInfo() async {
    try {
      final deviceInfoPlugin =
          DeviceInfoPlugin(); //instance ຂອງ deviceinfoplugin
      //ກວດສອບລະບົບປະຕິບັດການ
      if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceName = windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macosInfo = await deviceInfoPlugin.macOsInfo;
        deviceName = macosInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceName = linuxInfo.prettyName;
      }
      //ກວດວ່າໄດ້ຊື່ເຄື່ອງຫຼືບໍ່ຖ້າບໍ່ໄດ້ໃຫ້ໃສ່ຊື່ເລີ່ມຕົ້ນ
      if (deviceName == null || deviceName!.isEmpty) {
        deviceName = 'Unknown Device';
      }

      print('Device name: $deviceName'); //ສະແດງຊື່ເຄື່ອງ
    } catch (e) {
      print('Error getting device info: $e');
      deviceName = 'Unknown Device';
    }
  }

  // ສ້າງ cache ເພື່ອເກັບຂໍ້ມູນປັດຈຸບັນ ໃຊ້ປຽບທຽບການປ່ຽນແປງ
  static Map<String, List<dynamic>> _dataCache = {
    'product': [],
    'book': [],
    'unit': [],
    'category': [],
  };

  // ຟັງຊັນດຶງຂໍ້ມູນແລະປຽບທຽບກັບ cache ໃຊ້ກວດຈັບການປ່ຽນແປງ
  static Future<ApiResponse> fetchAndCompareData(String endpoint) async {
    try {
      //ດຶງຊື່ເຄື່ອງກ່ອນ
      if (deviceName == null) {
        await initDeviceInfo(); //ໃຊ້ຟັງຊັຍດຶງຂໍ້ມູນອຸປະກອນ
      }
      //ສົ່ງ get ໄປ API
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

      if (response.statusCode == 200) {
        //ສຳເລັດ
        List<dynamic> newData = json.decode(response.body); //ແປງ json ເປັນ list
        List<dynamic> oldData =
            _dataCache[endpoint] ?? []; //ດຶງຂໍ້ມູນເກົ່າຈາກ cahe

        // ປຽບທຽບຂໍ້ມູນເກົ່າ ແລະ ໃໝ່
        Map<String, dynamic> changes = _compareData(oldData, newData, endpoint);

        // ອັບເດດ cache
        _dataCache[endpoint] = newData;

        //ສ້າງ response object ທີ່ມີຂໍ້ມູນ ແລະ ການປຽບທຽບ
        return ApiResponse(
          success: true,
          data: newData,
          changes: changes,
          endpoint: endpoint,
        );
      } else {
        //ບໍ່ສຳເລັດ ສະແດງຂໍ້ພິດພາດ
        return ApiResponse(
          success: false,
          message: 'Failed to fetch $endpoint data: ${response.statusCode}',
          endpoint: endpoint,
        );
      }
    } catch (e) {
      //ຂໍ້ພິດພາດຈາກ API
      return ApiResponse(
        success: false,
        message: 'Error fetching $endpoint data: $e',
        endpoint: endpoint,
      );
    }
  }

  // ຟັງຊັນປຽບທຽບຂໍ້ມູນເກົ່າແລະໃໝ່ເພື່ອກວດຫາຄ່າປ່ຽນແປງ
  static Map<String, dynamic> _compareData(
      List<dynamic> oldData, List<dynamic> newData, String endpoint) {
    //ໂຄງສ້າງສຳລັບເກັບລາຍການທີ່ປ່ຽນແປງ
    Map<String, dynamic> changes = {
      'added': [],
      'deleted': [],
      'updated': [],
    };

    // ກຳນົດ key ທີ່ໃຊ້ເປັນ ID ໃນການລະບຸຕົວຂໍ້ມູນ
    String idField = _getIdFieldName(endpoint);

    // ສ້າງ map ເພື່ອຄົ້ນຫາຂໍ້ມູນໄວຂຶ້ນ
    Map<String, dynamic> oldMap = {};
    Map<String, dynamic> newMap = {};

    // ສ້າງ map ຈາກຂໍ້ມູນເກົ່າ ໂດຍໃຊ້ ID ເປັນ key
    for (var item in oldData) {
      oldMap[item[idField].toString()] = item;
    }

    // ສ້າງ map ຈາກຊໍ້ມູນໃໝ່ ໂດຍໃຊ້ ID ເປັນ key
    for (var item in newData) {
      newMap[item[idField].toString()] = item;
    }

    // ຫາຂໍ້ມູນທີ່ເພີ່ມຫຼືແກ້ໄຂ
    for (var id in newMap.keys) {
      if (!oldMap.containsKey(id)) {
        // ຂໍ້ມູນໃໝ່
        changes['added'].add(newMap[id]);
      } else {
        // ກວດສອບວ່າມີການແກ້ໄຂຫຼືບໍ່
        var oldItem = oldMap[id];
        var newItem = newMap[id];

        if (_isUpdated(oldItem, newItem)) {
          //ກວດສອບການປ່ຽນແປງ
          //ຖ້າມີການປ່ຽນແປງ ເພີ່ມທັງເກົ່າ-ໃໝ່ໃນລາຍການ ເພີ່ມເຂົ້າ updated
          changes['updated'].add({
            'old': oldItem,
            'new': newItem,
          });
        }
      }
    }

    // ກວດຫາຂໍ້ມູນທີ່ຖືກລົບ
    for (var id in oldMap.keys) {
      if (!newMap.containsKey(id)) {
        //ຖ້າ ID ບໍ່ມີໃນຂໍ້ມູນໃໝ່ ສະແດງວ່າຂໍ້ມູນຖືກລົບ
        changes['deleted'].add(oldMap[id]); //ເພີ່ມເຂົ້າ deleted
      }
    }

    return changes; //ສົ່ງຄືນລາຍການປ່ຽນແປງທັງໝົດ
  }

  // ຟັງຊັນກວດສອບວ່າຂໍ້ມູນຖືກແກ້ໄຂຫຼືບໍ່
  static bool _isUpdated(
      Map<String, dynamic> oldItem, Map<String, dynamic> newItem) {
    // ກວດສອບທຸກ feild ໃນຂໍ້ມູນໃໝ່
    for (var key in newItem.keys) {
      //ຖ້າfeild ມີໃນຂໍ້ມູນເກົ່າ ແລະ ຄ່າບໍ່ເທົ່າ ສະແດງວ່າມີການແກ້ໄຂ
      if (oldItem.containsKey(key) && oldItem[key] != newItem[key]) {
        return true; //ມີການແກ້ໄຂ
      }
    }
    return false; //ບໍ່ມີການແກ້ໄຂ
  }

  // ຟັງຊັນກຳນົດ field ທີ່ໃຊ້ເປັນ ID ຕາມ endpoint(ປະເພດຂໍ້ມູນ)
  static String _getIdFieldName(String endpoint) {
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

  // ຟັງຊັນເພີ່ມຂໍ້ມູນ ສົ່ງ post ໄປ API
  static Future<ApiResponse> addData(
      String endpoint, Map<String, dynamic> data) async {
    try {
      //ດຶງຊື່ເຄື່ອງ
      if (deviceName == null) {
        await initDeviceInfo();
      }

      //ສົ່ງ post ໄປ API ພ້ອມຂໍ້ມູນ ແລະ ຊື່ເຄື່ອງ
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json', //ກຳນົດ content type ເປັນ JSON
          'X-Hostname':
              deviceName ?? 'Unknown Device' //ສົ່ງຊື່ເຄື່ອງໄປໃນ header
        },
        body: json.encode(data), //ແປງຂໍ້ມູນເປັນ JSON
      );

      //ຕົວປ່ຽນສຳລັບເກັບຂໍ້ມູນຈາກ responce
      Map<String, dynamic> responseBody = {};
      String message = '';
      Map<String, dynamic>? clientInfo;

      //ແປງຂໍ້ມູນ responce ເປັນ map ຖ້າມີຂໍ້ມູນ
      if (response.body.isNotEmpty) {
        responseBody = json.decode(response.body);
        message = responseBody['msg'] ?? ''; // ດຶງຂໍ້ຄວາມ response
        clientInfo = responseBody['clientInfo']; // ດຶງຂໍ້ມູນເຄື່ອງຈາກ response
      }

      if (response.statusCode == 200) {
        //ຖ້າ request ສຳເລັດ
        //ສ້າງ reponce ທີ່ສະແດງຂໍ້ຄວາມ
        return ApiResponse(
          success: true,
          message: 'Added new ${_getEndpointName(endpoint)} successfully',
          endpoint: endpoint,
          action: 'POST',
          clientInfo: clientInfo, //ເພີ່ມຂໍ້ມູນເຄື່ອງ
        );
      } else {
        //ຖ້າ request ບໍ່ສຳເລັດ
        return ApiResponse(
          success: false,
          message:
              'Failed to add ${_getEndpointName(endpoint)}: ${response.statusCode} - $message',
          endpoint: endpoint,
          action: 'POST',
          clientInfo: clientInfo, //ເພີ່ມຂໍ້ມູນເຄື່ອງ
        );
      }
    } catch (e) {
      //ຖ້າເກີດຂໍ້ຜິດພາດຈາກການເອີ້ນ API
      return ApiResponse(
        success: false,
        message: 'Error adding ${_getEndpointName(endpoint)}: $e',
        endpoint: endpoint,
        action: 'POST',
      );
    }
  }

  // ຟັງຊັນແກ້ໄຂ ສົ່ງ PUT ໄປ API
  static Future<ApiResponse> updateData(
      String endpoint, String id, Map<String, dynamic> data) async {
    try {
      //ດຶງຊື່ເຄື່ອງ
      if (deviceName == null) {
        await initDeviceInfo();
      }
      //ສົ່ງ PUT ໄປ API ພ້ອມຂໍ້ມູນ ແລະ ຊື່ເຄື່ອງ
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint/$id'), //url ລະບຸ ID ທີ່ຕ້ອງການແກ້ໄຂ
        headers: {
          'Content-Type': 'application/json', // ກຳນົດ content type ເປັນ JSON
          'X-Hostname':
              deviceName ?? 'Unknown Device', // ສົ່ງຊື່ເຄື່ອງໄປໃນ header
        },
        body: json.encode(data), // ແປງຂໍ້ມູນເປັນ JSON string
      );

      // ຕົວປ່ຽນສຳລັບເກັບຂໍ້ມູນຈາກ response
      Map<String, dynamic> responseBody = {};
      String message = '';
      Map<String, dynamic>? clientInfo;

      //ແປງຂໍ້ມູນ response ເປັນ Map ຖ້າມີຂໍ້ມູນ
      if (response.body.isNotEmpty) {
        responseBody = json.decode(response.body);
        message = responseBody['msg'] ?? ''; // ດຶງຂໍ້ຄວາມຈາກ response
        clientInfo = responseBody['clientInfo']; // ດຶງຂໍ້ມູນເຄື່ອງຈາກ response
      }

      if (response.statusCode == 200) {
        //ຖ້າ request ສຳເລັດ
        return ApiResponse(
          success: true,
          message:
              'Updated ${_getEndpointName(endpoint)} with ID $id successfully',
          endpoint: endpoint,
          action: 'PUT',
          clientInfo: clientInfo,
        );
      } else {
        //ຖ້າ request ບໍ່ສຳເັລດ
        return ApiResponse(
          success: false,
          message:
              'Failed to update ${_getEndpointName(endpoint)}: ${response.statusCode} - $message',
          endpoint: endpoint,
          action: 'PUT',
          clientInfo: clientInfo,
        );
      }
    } catch (e) {
      // ຖ້າເກີດຂໍ້ຜິດພາດຈາກການເອີ້ນ API
      return ApiResponse(
        success: false,
        message: 'Error updating ${_getEndpointName(endpoint)}: $e',
        endpoint: endpoint,
        action: 'PUT',
      );
    }
  }

  // ຟັງຊັນລຶບ - ສົ່ງ DELETE request ໄປ API
  static Future<ApiResponse> deleteData(String endpoint, String id) async {
    try {
      // ດຶງຊື່ເຄື່ອງ
      if (deviceName == null) {
        await initDeviceInfo();
      }
      // ສົ່ງ DELETE request ໄປ API
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint/$id'), // URL ລະບຸ ID ທີ່ຕ້ອງການລົບ
        headers: {
          'X-Hostname':
              deviceName ?? 'Unknown Device', // ສົ່ງຊື່ເຄື່ອງໄປ header
        },
      );

      // ຕົວປ່ຽນສຳລັບເກັບຂໍ້ມູນຈາກ response
      Map<String, dynamic> responseBody = {};
      String message = '';
      Map<String, dynamic>? clientInfo;

      // ແປງຂໍ້ມູນ response ເປັນ Map ຖ້າມີຂໍ້ມູນ
      if (response.body.isNotEmpty) {
        responseBody = json.decode(response.body);
        message = responseBody['msg'] ?? ''; // ດຶງຂໍ້ຄວາມຈາກ response
        clientInfo = responseBody['clientInfo']; // ດຶງຂໍ້ມູນເຄື່ອງຈາກ response
      }

      if (response.statusCode == 200) {
        // ຖ້າ request ສຳເລັດ
        return ApiResponse(
          success: true,
          message:
              'Deleted ${_getEndpointName(endpoint)} with ID $id successfully',
          endpoint: endpoint,
          action: 'DELETE',
          clientInfo: clientInfo,
        );
      } else {
        // ຖ້າ request ບໍ່ສຳເລັດ
        return ApiResponse(
          success: false,
          message:
              'Failed to delete ${_getEndpointName(endpoint)}: ${response.statusCode} - $message',
          endpoint: endpoint,
          action: 'DELETE',
          clientInfo: clientInfo,
        );
      }
    } catch (e) {
      //ຂໍ້ຜິດພາດຈາກການເອີ້ນ API
      return ApiResponse(
        success: false,
        message: 'Error deleting ${_getEndpointName(endpoint)}: $e',
        endpoint: endpoint,
        action: 'DELETE',
      );
    }
  }

  // ຟັງຊັນປ່ຽນຊື່ endpoint ເປັນຊື່ທີ່ອ່ານໄດ້
  static String _getEndpointName(String endpoint) {
    switch (endpoint) {
      case 'product':
        return 'Product'; // ຊື່ສະແດງຜົນຂອງ endpoint product
      case 'book':
        return 'Book'; // ຊື່ສະແດງຜົນຂອງ endpoint book
      case 'unit':
        return 'Unit'; // ຊື່ສະແດງຜົນຂອງ endpoint unit
      case 'category':
        return 'Category'; // ຊື່ສະແດງຜົນຂອງ endpoint category
      default:
        return endpoint; // ໃຊ້ຊື່ endpoint ເດີມຖ້າບໍ່ມີການກຳນົດ
    }
  }
}

//ຄລາສສຳລັບເກັບຜົນລັບຈາກການເອີ້ນ API
class ApiResponse {
  final bool success; //ສະຖານະຄວາມສຳເລັດຂອງການເອີ້ນ API
  final String? message; //ຂໍ້ຄວາມເພີ່ມເຕີມ
  final List<dynamic>? data; // ຂໍ້ມູນທີ່ໄດ້ຈາກ API
  final Map<String, dynamic>? changes; // ຂໍ້ມູນການປ່ຽນແປງ
  final String endpoint; // ຊື່ endpoint ທີ່ເອີ້ນ
  final String action; // ກິດຈະກຳ (GET, POST, PUT, DELETE)
  final Map<String, dynamic>? clientInfo; // ຂໍ້ມູນເຄື່ອງທີ່ເຮັດກິດຈະກຳ

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.changes,
    required this.endpoint,
    this.action = 'GET',
    this.clientInfo,
  });
}
