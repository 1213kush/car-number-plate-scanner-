import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {

  Future<String> saveImagePermanently(String imagePath) async {

    final directory = await getApplicationDocumentsDirectory();

    final fileName =
        'vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final permanentPath = '${directory.path}/$fileName';

    final image = File(imagePath);

    await image.copy(permanentPath);

    return permanentPath;
  }
}