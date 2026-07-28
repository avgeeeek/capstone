import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/helpers.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  Future<String> uploadMenuImage(File file, String vendorId) async {
    final fileName = '${Helpers.generateId()}.jpg';
    final ref = _storage
        .ref()
        .child(ApiConstants.menuImagesPath)
        .child(vendorId)
        .child(fileName);

    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage(File file, String userId) async {
    final fileName = '$userId.jpg';
    final ref = _storage
        .ref()
        .child(ApiConstants.profileImagesPath)
        .child(fileName);

    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadVendorImage(File file, String vendorId) async {
    final fileName = '$vendorId.jpg';
    final ref = _storage
        .ref()
        .child(ApiConstants.vendorImagesPath)
        .child(fileName);

    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // Ignore errors during deletion
    }
  }
}
