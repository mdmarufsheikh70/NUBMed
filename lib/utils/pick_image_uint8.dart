import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<ImagePickerResult?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
      );

      if (pickedFile == null) return null;

      final Uint8List bytes = await pickedFile.readAsBytes();
      final String base64String = base64Encode(bytes);

      return ImagePickerResult(
        file: pickedFile,
        bytes: bytes,
        base64String: base64String,
      );
    } catch (e) {
      // debugPrint('Image picker error: $e\n$stackTrace');
      return null;
    }
  }
}

class ImagePickerResult {
  final XFile file;
  final Uint8List bytes;
  final String base64String;

  const ImagePickerResult({
    required this.file,
    required this.bytes,
    required this.base64String,
  });

  String get fileName => file.name;
  int get fileSize => bytes.lengthInBytes;
}