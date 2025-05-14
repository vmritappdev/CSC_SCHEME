import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  String savedImageUrl = ''; // Local/Network image path
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => savedImageUrl = picked.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => savedImageUrl = picked.path);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _viewImage(BuildContext context) {
    if (savedImageUrl.isEmpty) {
      _pickImage();
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image(
                  image: savedImageUrl.startsWith('http')
                      ? NetworkImage(savedImageUrl)
                      : FileImage(File(savedImageUrl)) as ImageProvider,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Positioned(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => _viewImage(context),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: savedImageUrl.isNotEmpty
                      ? (savedImageUrl.startsWith('http')
                          ? NetworkImage(savedImageUrl)
                          : FileImage(File(savedImageUrl))) as ImageProvider
                      : null,
                  child: savedImageUrl.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Color.fromRGBO(2, 5, 62, 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
