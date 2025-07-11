import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({Key? key}) : super(key: key);

  @override
  _BackupRestorePageState createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final String _baseUrl = basePath().bpath();
  bool _isProcessing = false;

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// Calls the backup endpoint, lets user save the file
  Future<void> _backupNow() async {
    setState(() => _isProcessing = true);
    try {
      final uri = Uri.parse('$_baseUrl/main/backup');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Use FilePicker to let user choose where to save
        final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.sql';

        try {
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Save backup file',
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['sql'],
          );

          if (result != null) {
            final file = File(result);
            await file.writeAsBytes(response.bodyBytes);
            _showMessage('Backup saved: $result');
          } else {
            _showMessage('Save cancelled');
          }
        } catch (e) {
          // If saveFile is not supported, show the content in a dialog
          _showBackupContent(response.body);
        }
      } else {
        _showMessage('Backup failed (${response.statusCode}): ${response.body}',
            isError: true);
      }
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Show backup content in a dialog if file saving is not supported
  void _showBackupContent(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Backup Complete'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
    _showMessage(
        'Backup content displayed - you can copy and save it manually');
  }

  /// Opens file picker, then uploads the chosen .sql file to restore endpoint.
  /// Opens file picker, then uploads the chosen .sql file to restore endpoint.
  Future<void> _restoreNow() async {
    setState(() => _isProcessing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['sql'],
        withData: true, // Important: This ensures bytes are loaded
      );

      if (result == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final platformFile = result.files.single;

      // Check if we have bytes (web) or path (mobile/desktop)
      if (platformFile.bytes == null && platformFile.path == null) {
        _showMessage('Unable to read file', isError: true);
        return;
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/main/restore'));

      if (platformFile.bytes != null) {
        // Web platform - use bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'sqlfile',
            platformFile.bytes!,
            filename: platformFile.name,
          ),
        );
      } else {
        // Mobile/Desktop platform - use path
        final file = File(platformFile.path!);
        if (!await file.exists()) {
          _showMessage('Selected file does not exist', isError: true);
          return;
        }
        request.files.add(
          await http.MultipartFile.fromPath('sqlfile', file.path),
        );
      }

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200) {
        _showMessage('Restore successful!');
      } else {
        _showMessage('Restore failed (${resp.statusCode}): ${resp.body}',
            isError: true);
      }
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: const Color(0xFFE45C58),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Backup Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE45C58),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                      ),
                      onPressed: _backupNow,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore from File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                      ),
                      onPressed: _restoreNow,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
