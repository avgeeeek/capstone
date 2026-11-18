import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// StorageService — image picking only.
/// Firebase Storage requires Blaze plan so uploads are disabled.
/// Menu items use a default placeholder instead of uploaded images.
class StorageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({bool fromGallery = true}) async {
    final picked = await _picker.pickImage(
      source: fromGallery ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked == null) return null;
    return File(picked.path);
  }
}
