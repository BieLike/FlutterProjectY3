import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEditProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData;
  const AddEditProductPage({super.key, this.productData});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final String baseurl = basePath().bpath();
  bool isLoading = false;
  bool get isEditMode => widget.productData != null;

  late TextEditingController txtID,
      txtName,
      txtQty,
      txtImP,
      txtSP,
      txtBal,
      txtLvl,
      txtNewID,
      txtNewName,
      txtBpage;

  List uData = [], cData = [], aData = [];
  String? selectedUnit, selectedCategory;
  int? selectedAuthor;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  Uint8List? _webImage;
  String? _existingImagePath;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    txtID = TextEditingController(
        text: widget.productData?['ProductID']?.toString() ?? '');
    txtName = TextEditingController(
        text: widget.productData?['ProductName']?.toString() ?? '');
    txtBpage = TextEditingController(
        text: widget.productData?['Bpage']?.toString() ?? '0');
    txtNewID = TextEditingController();
    txtNewName = TextEditingController();
    txtQty = TextEditingController(
        text: widget.productData?['Quantity']?.toString() ?? '0');
    txtImP = TextEditingController(
        text: widget.productData?['ImportPrice']?.toString() ?? '0');
    txtSP = TextEditingController(
        text: widget.productData?['SellPrice']?.toString() ?? '0');
    txtBal = TextEditingController(
        text: widget.productData?['Balance']?.toString() ?? '0');
    txtLvl = TextEditingController(
        text: widget.productData?['Level']?.toString() ?? '0');
    if (isEditMode) {
      _existingImagePath = widget.productData!['ProductImageURL'];
    }
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    try {
      final responses = await Future.wait([
        http.get(Uri.parse("$baseurl/main/unit")),
        http.get(Uri.parse("$baseurl/main/category")),
        http.get(Uri.parse("$baseurl/main/author")),
      ]);

      if (mounted) {
        setState(() {
          if (responses[0].statusCode == 200)
            uData = json.decode(responses[0].body);
          if (responses[1].statusCode == 200)
            cData = json.decode(responses[1].body);
          if (responses[2].statusCode == 200)
            aData = json.decode(responses[2].body);

          if (isEditMode) {
            String? unitId = widget.productData!['UnitID']?.toString();
            if (uData.any((e) => e['UnitID'].toString() == unitId))
              selectedUnit = unitId;
            String? catId = widget.productData!['CategoryID']?.toString();
            if (cData.any((e) => e['CategoryID'].toString() == catId))
              selectedCategory = catId;
            int? authorId = widget.productData!['authorsID'];
            if (aData.any((e) => e['authorID'] == authorId))
              selectedAuthor = authorId;
          }
        });
      }
    } catch (e) {
      if (mounted)
        showErrorMessage("Failed to load dropdown data: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 800);
    if (pickedFile != null) {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
      } else {
        _selectedImageFile = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                }),
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final employeeData = await _getEmployeeData();
    if (employeeData == null) return;
    setState(() => isLoading = true);

    final uri = isEditMode
        ? Uri.parse("$baseurl/main/product/${widget.productData!['ProductID']}")
        : Uri.parse("$baseurl/main/product");
    var request = http.MultipartRequest(isEditMode ? 'PUT' : 'POST', uri);

    request.fields.addAll({
      "ProductID": txtID.text,
      "ProductName": txtName.text,
      "Bpage": txtBpage.text,
      "NewProductID": txtNewID.text,
      "NewProductName": txtNewName.text,
      "Quantity": txtQty.text,
      "ImportPrice": txtImP.text,
      "SellPrice": txtSP.text,
      "UnitID": selectedUnit ?? '',
      "CategoryID": selectedCategory ?? '',
      "authorsID": selectedAuthor?.toString() ?? '',
      "Balance": txtBal.text,
      "Level": txtLvl.text,
      "EmployeeID": employeeData['UID'].toString(),
      "EmployeeName": employeeData['UserFname']
    });

    if (_selectedImageFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImageFile!.path));
    } else if (_webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('image', _webImage!,
          filename: 'upload.jpg'));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        showSuccessMessage(responseBody['msg'] ?? "Success");
        if (mounted) Navigator.of(context).pop(true);
      } else {
        showErrorMessage(responseBody['msg'] ?? "An error occurred");
      }
    } catch (e) {
      showErrorMessage("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _getEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString == null) {
      showErrorMessage("User data not found");
      return null;
    }
    return json.decode(userDataString);
  }

  void showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  void dispose() {
    txtID.dispose();
    txtName.dispose();
    txtNewID.dispose();
    txtNewName.dispose();
    txtQty.dispose();
    txtImP.dispose();
    txtSP.dispose();
    txtBal.dispose();
    txtLvl.dispose();
    txtBpage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(isEditMode ? 'ແກ້ໄຂປຶ້ມ' : 'ເພີ່ມປຶ້ມໃໝ່'),
          backgroundColor: Color(0xFFE45C58)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Center(
                      child: Stack(children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100]),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildImageWidget()),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Color(0xFFE45C58),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                            onTap: _showImageSourceActionSheet,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.camera_alt,
                                    color: Colors.white, size: 20))),
                      ),
                    ),
                  ])),
                  SizedBox(height: 24),
                  Row(children: [
                    Expanded(
                        child: _buildTextField(
                            controller: txtID,
                            label: 'ID*',
                            enabled: !isEditMode)),
                    SizedBox(width: 10),
                    Expanded(
                        flex: 2,
                        child: _buildTextField(
                            controller: txtName,
                            label: 'ຊື່*',
                            enabled: !isEditMode)),
                  ]),
                  if (isEditMode) SizedBox(height: 12),
                  if (isEditMode)
                    Row(children: [
                      Expanded(
                          child: _buildTextField(
                              controller: txtNewID,
                              label: 'ID ໃໝ່',
                              isOptional: true)),
                      SizedBox(width: 10),
                      Expanded(
                          flex: 2,
                          child: _buildTextField(
                              controller: txtNewName,
                              label: 'ຊື່ໃໝ່',
                              isOptional: true)),
                    ]),
                  SizedBox(height: 12),
                  _buildDropdown<int>(
                    label: 'ຜູ້ແຕ່ງ *',
                    value: selectedAuthor,
                    items: aData
                        .map<DropdownMenuItem<int>>((author) =>
                            DropdownMenuItem<int>(
                                value: author['authorID'],
                                child: Text(author['name'])))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedAuthor = value),
                  ),
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 1,
                          child: _buildTextField(
                              controller: txtBpage,
                              label: 'ຈຳນວນໜ້າ *',
                              isNumber: true)),
                      SizedBox(width: 10),
                      Expanded(
                          flex: 1,
                          child: _buildTextField(
                              controller: txtQty,
                              label: 'ຈຳນວນ *',
                              isNumber: true)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _buildTextField(
                            controller: txtImP,
                            label: 'ລາຄານຳເຂົ້າ *',
                            isNumber: true)),
                    SizedBox(width: 10),
                    Expanded(
                        child: _buildTextField(
                            controller: txtSP,
                            label: 'ລາຄາຂາຍ *',
                            isNumber: true)),
                  ]),
                  SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _buildDropdown<String>(
                      label: 'ຫົວໜ່ວຍ *',
                      value: selectedUnit,
                      items: uData
                          .map<DropdownMenuItem<String>>((unit) =>
                              DropdownMenuItem<String>(
                                  value: unit['UnitID'].toString(),
                                  child: Text(unit['UnitName'])))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedUnit = value),
                    )),
                    SizedBox(width: 10),
                    Expanded(
                        child: _buildDropdown<String>(
                      label: 'ປະເພດ *',
                      value: selectedCategory,
                      items: cData
                          .map<DropdownMenuItem<String>>((cat) =>
                              DropdownMenuItem<String>(
                                  value: cat['CategoryID'].toString(),
                                  child: Text(cat['CategoryName'])))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedCategory = value),
                    )),
                  ]),
                  SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _buildTextField(
                            controller: txtBal,
                            label: 'ຍອດລວມຈຳນວນ *',
                            isNumber: true)),
                    SizedBox(width: 10),
                    Expanded(
                        child: _buildTextField(
                            controller: txtLvl,
                            label: 'ຈຳນວນຂັ້ນຕໍ່າ *',
                            isNumber: true)),
                  ]),
                  SizedBox(height: 24),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('ຍົກເລີກ'),
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Color(0xFFE45C58)),
                                foregroundColor: Color(0xFFE45C58)))),
                    SizedBox(width: 16),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: isLoading ? null : _saveProduct,
                            child: Text(isEditMode ? 'ອັບເດດ' : 'ເພີ່ມ'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE45C58),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16)))),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildImageWidget() {
    final String? fullImageUrl =
        _existingImagePath != null && _existingImagePath!.isNotEmpty
            ? baseurl + _existingImagePath!
            : null;
    if (_webImage != null) return Image.memory(_webImage!, fit: BoxFit.cover);
    if (_selectedImageFile != null)
      return Image.file(_selectedImageFile!, fit: BoxFit.cover);
    if (fullImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: fullImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            Icon(Icons.broken_image, color: Colors.grey, size: 50),
      );
    }
    return Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 60);
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      bool enabled = true,
      bool isNumber = false,
      bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))]
          : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: isOptional ? Colors.green.shade700 : Color(0xFFE45C58)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: isOptional ? Colors.green.shade700 : Color(0xFFE45C58))),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300)),
        filled: !enabled,
        fillColor: Colors.grey[100],
      ),
      validator: (v) {
        if (!isOptional && (v == null || v.isEmpty)) return 'ກະລຸນາປ້ອນຂໍ້ມູນ';
        return null;
      },
    );
  }

  Widget _buildDropdown<T>(
      {required String label,
      T? value,
      required List<DropdownMenuItem<T>> items,
      required void Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFE45C58)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE45C58))),
      ),
      validator: (v) => v == null ? 'ກະລຸນາເລືອກ' : null,
    );
  }
}
