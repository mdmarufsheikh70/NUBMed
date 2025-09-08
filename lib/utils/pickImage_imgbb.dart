import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';

class ImgBBImagePicker {
  static const String apiKey = "117a14bd3560bd307339ef10aa2a9323";
  static const String _uploadUrl = "https://api.imgbb.com/1/upload";

  /// Picks an image from gallery
  static Future<XFile?> pickImage({
    int? imageQuality,
  }) async {
    try {
      return await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality ?? 80,
      );
    } catch (e) {
      debugPrint('Image pick error: $e');
      return null;
    }
  }

  /// Uploads image to ImgBB
  static Future<ImgBBResponse?> uploadImage({
    required XFile imageFile,
    required BuildContext context,
  }) async {
    try {
      // 1. Validate image size
      final fileSizeKB = (await imageFile.length()) ~/ 1024;
      if (fileSizeKB > 2048) { // 2MB limit
        showSnackBar(context, 'Image must be under 2MB', false);
        return null;
      }

      // 2. Prepare upload
      print('Here');
      final bytes = await imageFile.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_uploadUrl?key=$apiKey'),
      )..files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      // 3. Execute upload and parse response
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      debugPrint('ImgBB Response: $jsonData'); // Log full response

      // 4. Validate response structure
      if (response.statusCode != 200) {
        final error = jsonData['error']?['message'] ?? 'Unknown error';
        throw Exception('Upload failed: $error (Status: ${response.statusCode})');
      }

      if (jsonData['success'] != true) {
        throw Exception('Upload failed: ${jsonData['error']?.toString() ?? 'Unknown error'}');
      }

      // 5. Parse response with null checks
      return ImgBBResponse.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint('Image upload error: $e\n$stackTrace');
      showSnackBar(
        context,
        'Upload failed: ${e is FormatException ? "Invalid image format" : e.toString()}',
        false,
      );
      return null;
    }
  }

  static Future<bool> deleteImage(String deleteUrl, BuildContext context) async {
    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        showSnackBar(context, "Image deleted successfully", true);
        return true;
      } else {
        print(response.body);
        showSnackBar(context, "Failed to delete image: ${response.body}", false);
        return false;
      }
    } catch (e) {
      showSnackBar(context, "Error deleting image: $e", false);
      return false;
    }
  }
}

class ImgBBResponse {
  final String imageUrl;
  final String deleteUrl;


  const ImgBBResponse({
    required this.imageUrl,
    required this.deleteUrl,

  });

  factory ImgBBResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Safely access nested data with null checks
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final imageUrl = data['url'] as String?;
      final deleteUrl = data['delete_url'] as String?;

      if (imageUrl == null || deleteUrl == null ) {
        throw FormatException('Missing required fields in ImgBB response. Received: $json');
      }

      return ImgBBResponse(
        imageUrl: imageUrl,
        deleteUrl: deleteUrl,
      );
    } catch (e, stackTrace) {
      debugPrint('ImgBB Response Parsing Error: $e\n$stackTrace');
      rethrow;
    }
  }
}