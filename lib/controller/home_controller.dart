// import 'dart:io';

// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class HomeController extends GetxController {
//   File? image;

//   static const platform = MethodChannel('imageUploader/sharedImage');

//   Future<void> loadImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final imagePath = prefs.getString('selected_image_path');

//     if (imagePath != null) {
//       image = File(imagePath);
//       update();
//     }
//   }

//   imagepicked(source) async {
//     final picker = ImagePicker();
//     final pickedfile = await picker.pickImage(source: source);
//     if (pickedfile != null) {
//       image = File(pickedfile.path);
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('selected_image_path', pickedfile.path);
//       update();
//     }
//   }

//   Future<void> handleSharedImage() async {
//     try {
//       final String? imagePath = await platform.invokeMethod('getSharedImage');
//       if (imagePath != null) {
//         image = File(imagePath);
//         print("============image=======$image==");
//         update();
//       }
//     } on PlatformException catch (e) {
//       print("Failed to get shared image: '${e.message}'.");
//     }
//   }
// }

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomeController extends GetxController {
  File? image;

  static const platform = MethodChannel('imageUploader/sharedImage');

  Future<void> loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('selected_image_path');

    if (imagePath != null) {
      image = File(imagePath);
      update();
    }
  }

  imagepicked(source) async {
    final picker = ImagePicker();
    final pickedfile = await picker.pickImage(source: source);
    if (pickedfile != null) {
      image = File(pickedfile.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_image_path', pickedfile.path);
      update();
    }
  }

  Future<void> handleSharedImage() async {
    try {
      final String? imagePath = await platform.invokeMethod('getSharedImage');
      if (imagePath != null) {
        File? sharedImageFile = await _getFileFromUri(imagePath);
        if (sharedImageFile != null) {
          image = sharedImageFile;
          print("============image=======$image==");
          update();
        }
      }
    } on PlatformException catch (e) {
      print("Failed to get shared image: '${e.message}'.");
    }
  }

  Future<File?> _getFileFromUri(String uriString) async {
    try {
      final Uri uri = Uri.parse(uriString);
      if (uri.scheme == 'content') {
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath = path.join(tempDir.path, 'shared_image.jpg');
        final File tempFile = File(tempPath);
        final byteData = await platform.invokeMethod('readBytes', uriString);
        await tempFile.writeAsBytes(byteData);
        return tempFile;
      } else {
        return File(uriString);
      }
    } catch (e) {
      print("Error while converting URI to file: $e");
      return null;
    }
  }

  removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    image = null;
    update();
  }
}
