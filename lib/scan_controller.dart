import 'services/image_service.dart';
import 'services/ocr_service.dart';
import 'services/image_storage_service.dart';
import 'services/database_service.dart';

class ScanController {
  final ImageService imageService = ImageService();
  final OCRService ocrService = OCRService();
  final ImageStorageService storageService = ImageStorageService();
  final DatabaseService databaseService = DatabaseService();

  Future<void> scanVehicle() async {
    final image = await imageService.captureImage();

    if (image == null) return;

    final text = await ocrService.scanText(image.path);

    final vehicleNumber = ocrService.extractVehicleNumber(text);
    final permanentImagePath = await storageService.saveImagePermanently(image.path);

    await databaseService.insertVehicle(
      vehicleNumber,
      permanentImagePath,
    );

    // Scan completed successfully
  }

  void dispose() {
    ocrService.dispose();
  }
}