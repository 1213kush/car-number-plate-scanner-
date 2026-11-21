import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker picker = ImagePicker();

  Future<XFile?> captureImage({ImageSource source = ImageSource.camera}) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    return image;
  }

  Future<XFile?> pickFromGallery() async {
    return captureImage(source: ImageSource.gallery);
  }
}
