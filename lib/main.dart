import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';

void main() {
  runApp(const VehicleScannerApp());
}

class VehicleScannerApp extends StatelessWidget {
  const VehicleScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


