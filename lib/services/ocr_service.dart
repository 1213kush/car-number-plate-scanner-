import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> scanText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final recognizedText = await recognizer.processImage(inputImage);

    return recognizedText.text;
  }

  // Helper to fix digit misreads in letter positions (e.g. '0' -> 'O', '1' -> 'I')
  String _toLetters(String text) {
    return text
        .replaceAll('0', 'O')
        .replaceAll('1', 'I')
        .replaceAll('2', 'Z')
        .replaceAll('5', 'S')
        .replaceAll('8', 'B')
        .replaceAll('6', 'G');
  }

  // Helper to fix letter misreads in digit positions (e.g. 'O' -> '0', 'I' -> '1', 'S' -> '5')
  String _toDigits(String text) {
    return text
        .replaceAll('O', '0')
        .replaceAll('Q', '0')
        .replaceAll('I', '1')
        .replaceAll('L', '1')
        .replaceAll('Z', '2')
        .replaceAll('S', '5')
        .replaceAll('B', '8')
        .replaceAll('G', '6');
  }

  // Disambiguates & formats Indian License Plate structure (e.g., D17CR3B1S -> DL 7CR 3815)
  String _correctAndFormatIndianPlate(String state, String rto, String series, String number) {
    final correctedState = _toLetters(state);
    final correctedRto = _toDigits(rto);
    final correctedSeries = _toLetters(series);
    final correctedNumber = _toDigits(number);

    return '$correctedState $correctedRto $correctedSeries $correctedNumber';
  }

  String extractVehicleNumber(String text) {
    if (text.trim().isEmpty) return '';

    // Remove noise words/prefixes like "IND", "INDIA", "ROYAL", etc.
    final cleanedRaw = text.toUpperCase();
    final cleanNoInd = cleanedRaw.replaceAll(RegExp(r'\b(IND|INDIA)\b'), '');
    final cleanedText = cleanNoInd.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    // 1. Structure-Aware Indian Plate Pattern with Auto Disambiguation
    // Group 1: State (2 chars) | Group 2: RTO (1-2 chars) | Group 3: Series (1-3 chars) | Group 4: Number (1-4 chars)

    // Check if cleanedText contains a valid state-code starting pattern
    final indianExactPattern = RegExp(
        r'([A-Z]{2})([0-9OILSZB]{1,2})([A-Z0-9]{1,3})([0-9OILSZB]{1,4})');

    final exactMatch = indianExactPattern.firstMatch(cleanedText);
    if (exactMatch != null) {
      return _correctAndFormatIndianPlate(
        exactMatch.group(1)!,
        exactMatch.group(2)!,
        exactMatch.group(3)!,
        exactMatch.group(4)!,
      );
    }

    // Check raw cleaned text
    final rawCleanedText = cleanedRaw.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final exactMatchRaw = indianExactPattern.firstMatch(rawCleanedText);
    if (exactMatchRaw != null) {
      return _correctAndFormatIndianPlate(
        exactMatchRaw.group(1)!,
        exactMatchRaw.group(2)!,
        exactMatchRaw.group(3)!,
        exactMatchRaw.group(4)!,
      );
    }

    // 2. Secondary: International / Flexible Plate format
    final standardPattern = RegExp(r'[A-Z]{1,3}[0-9]{1,2}[A-Z]{1,3}[0-9]{1,4}');
    final standardMatch = standardPattern.firstMatch(cleanedText);
    if (standardMatch != null) {
      return standardMatch.group(0)!;
    }

    // 3. Line by line search for plate format
    final lines = text.split('\n');
    for (var line in lines) {
      final cleanLine = line.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\s-]'), '').trim();
      final compactLine = cleanLine.replaceAll(RegExp(r'[^A-Z0-9]'), '');

      if (compactLine.length >= 3 &&
          compactLine.length <= 12 &&
          RegExp(r'[A-Z]').hasMatch(compactLine) &&
          RegExp(r'[0-9]').hasMatch(compactLine)) {
        return cleanLine;
      }
    }

    // 4. General Alphanumeric block
    final generalPattern = RegExp(r'[A-Z0-9]{3,12}');
    final matches = generalPattern.allMatches(cleanedText);
    for (var match in matches) {
      final str = match.group(0)!;
      if (RegExp(r'[0-9]').hasMatch(str)) {
        return str;
      }
    }

    // 5. Fallback: First non-empty line
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        return trimmed.toUpperCase();
      }
    }

    return cleanedText.isNotEmpty ? cleanedText : text.trim();
  }

  void dispose() {
    recognizer.close();
  }
}
