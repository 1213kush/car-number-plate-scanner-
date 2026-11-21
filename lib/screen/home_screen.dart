import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vehicle_model.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../services/ocr_service.dart';
import '../widgets/vehicle_card.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ImageService _imageService = ImageService();
  final OCRService _ocrService = OCRService();

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  bool _isProcessingScan = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final maps = await _databaseService.getVehicles();
      setState(() {
        _vehicles = maps.map((map) => Vehicle.fromMap(map)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose how you want to scan the vehicle license plate.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.blue.shade100),
                    ),
                    tileColor: Colors.blue.shade50.withValues(alpha: 0.5),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 22),
                    ),
                    title: const Text(
                      'Take Photo (Camera)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: const Text(
                        'Scan plate live using device camera',
                        style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      _startScan(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.purple.shade100),
                    ),
                    tileColor: Colors.purple.shade50.withValues(alpha: 0.5),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.photo_library_rounded,
                          color: Colors.white, size: 22),
                    ),
                    title: const Text(
                      'Choose from Files / Gallery',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: const Text(
                        'Select existing image from phone or Mac',
                        style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      _startScan(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _startScan(ImageSource source) async {
    setState(() {
      _isProcessingScan = true;
    });

    try {
      final capturedImage =
          await _imageService.captureImage(source: source);

      if (capturedImage == null) {
        setState(() {
          _isProcessingScan = false;
        });
        return;
      }

      final recognizedText =
          await _ocrService.scanText(capturedImage.path);

      final vehicleNumber =
          _ocrService.extractVehicleNumber(recognizedText);

      setState(() {
        _isProcessingScan = false;
      });

      if (!mounted) return;

      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleResultScreen(
            imagePath: capturedImage.path,
            vehicleNumber: vehicleNumber,
          ),
        ),
      );

      if (saved == true) {
        _loadVehicles();
      }
    } catch (e) {
      setState(() {
        _isProcessingScan = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during scanning: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Delete Record'),
          ],
        ),
        content: Text(
            'Are you sure you want to delete record for ${vehicle.vehicleNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseService.deleteVehicle(vehicle.id!);
      _loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.directions_car_filled_rounded,
                color: Colors.cyanAccent, size: 28),
            SizedBox(width: 10),
            Text(
              'Vehicle Scanner',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadVehicles,
            tooltip: 'Refresh List',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Dashboard Summary Banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C5364), Color(0xFF203A43)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SAVED VEHICLES',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_vehicles.length} Records',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.cyanAccent.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              color: Colors.cyanAccent, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'scanned today',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main List / Empty State
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _vehicles.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.document_scanner_rounded,
                                      size: 72,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No Vehicles Scanned Yet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap "Scan Plate" to capture a license plate from camera or gallery.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  ElevatedButton.icon(
                                    onPressed: _isProcessingScan
                                        ? null
                                        : _showImageSourcePicker,
                                    icon: const Icon(
                                        Icons.camera_alt_rounded),
                                    label: const Text('Start New Scan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF1E3C72),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 28, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadVehicles,
                            child: ListView.builder(
                              itemCount: _vehicles.length,
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 84),
                              itemBuilder: (context, index) {
                                final vehicle = _vehicles[index];
                                return VehicleCard(
                                  vehicle: vehicle,
                                  onDelete: () => _deleteVehicle(vehicle),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),

          // Processing Overlay Loading Card
          if (_isProcessingScan)
            Container(
              color: Colors.black45,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1E3C72)),
                      SizedBox(height: 18),
                      Text(
                        'Processing Image...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Running ML Kit Text Recognition',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessingScan ? null : _showImageSourcePicker,
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text(
          'Scan Plate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
