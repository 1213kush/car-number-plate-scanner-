import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../services/ocr_service.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImageService _imageService = ImageService();
  final OCRService _ocrService = OCRService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndScan();
    });
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _captureAndScan() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _imageService.captureImage();
      if (image == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final recognizedText = await _ocrService.scanText(image.path);
      final vehicleNumber = _ocrService.extractVehicleNumber(recognizedText);

      if (!mounted) return;

      final saved = await Navigator.pushReplacement<bool, void>(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleResultScreen(
            imagePath: image.path,
            vehicleNumber: vehicleNumber,
          ),
        ),
      );

      if (mounted) {
        Navigator.pop(context, saved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan Error: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning Vehicle'),
      ),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Opening Camera & Processing Plate...'),
                ],
              )
            : ElevatedButton.icon(
                onPressed: _captureAndScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start Scan'),
              ),
      ),
    );
  }
}
