import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/image_storage_service.dart';

class VehicleResultScreen extends StatefulWidget {
  final String imagePath;
  final String vehicleNumber;

  const VehicleResultScreen({
    super.key,
    required this.imagePath,
    required this.vehicleNumber,
  });

  @override
  State<VehicleResultScreen> createState() => _VehicleResultScreenState();
}

class _VehicleResultScreenState extends State<VehicleResultScreen> {
  late TextEditingController numberController;
  bool isSaving = false;

  final DatabaseService _databaseService = DatabaseService();
  final ImageStorageService _storageService = ImageStorageService();

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController(
      text: widget.vehicleNumber,
    );
  }

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    final vehicleNumber = numberController.text.trim().toUpperCase();

    if (vehicleNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Please enter a valid vehicle number.'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final permanentImagePath =
          await _storageService.saveImagePermanently(widget.imagePath);

      await _databaseService.insertVehicle(
        vehicleNumber,
        permanentImagePath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.cyanAccent),
              const SizedBox(width: 10),
              Text('Vehicle $vehicleNumber saved successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save vehicle: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Vehicle Scan Result',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Color(0xFF059669), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'OCR Text Extraction Complete',
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Captured Image Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.imagePath),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recognized Plate Preview Title
            const Text(
              'Extracted Vehicle Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Verify and edit the number if needed before saving.',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            // Editable Input Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: numberController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter vehicle number',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.directions_car_rounded,
                        color: Color(0xFF2563EB)),
                  ),
                  suffixIcon: numberController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded,
                              color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              numberController.clear();
                            });
                          },
                        )
                      : const Icon(Icons.edit_rounded, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFF2563EB), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _saveVehicle,
                icon: isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save_rounded, color: Colors.white),
                label: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Vehicle Record',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: isSaving
                    ? null
                    : () {
                        Navigator.pop(context, false);
                      },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Rescan / Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
