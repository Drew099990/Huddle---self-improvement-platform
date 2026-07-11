import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const Testing());

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Image Preview',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _selectedImagePath == null
                    ? const Icon(Icons.person, size: 90, color: Colors.grey)
                    : ClipOval(
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                          width: 180,
                          height: 180,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          _selectedImagePath = result.files.single.path!;
                        });
                      }
                    },
                    child: const Text('select file'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('upload file'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
