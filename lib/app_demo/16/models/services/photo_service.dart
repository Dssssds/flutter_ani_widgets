import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoPickFailure implements Exception {
  const PhotoPickFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class PhotoService {
  /// Returns the persisted file path, or null when the picker was cancelled.
  Future<String?> pickAndStore();
}

class GalleryPhotoService implements PhotoService {
  GalleryPhotoService({ImagePicker? picker, Uuid? uuid})
    : _picker = picker ?? ImagePicker(),
      _uuid = uuid ?? const Uuid();

  final ImagePicker _picker;
  final Uuid _uuid;

  @override
  Future<String?> pickAndStore() async {
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 700,
        maxHeight: 700,
        imageQuality: 82,
      );
    } on Object {
      throw const PhotoPickFailure('这张照片没有读出来，换一张试试');
    }
    if (picked == null) {
      return null;
    }

    try {
      final bytes = await picked.readAsBytes();
      if (!await _isDecodable(bytes)) {
        throw const PhotoPickFailure('这张照片没有读出来，换一张试试');
      }
      final documents = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${documents.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
      final target = File('${photosDir.path}/${_uuid.v4()}.jpg');
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } on PhotoPickFailure {
      rethrow;
    } on Object {
      throw const PhotoPickFailure('这张照片没有读出来，换一张试试');
    }
  }

  Future<bool> _isDecodable(Uint8List bytes) async {
    if (bytes.isEmpty) {
      return false;
    }
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      frame.image.dispose();
      codec.dispose();
      return true;
    } on Object {
      return false;
    }
  }
}
