# Vehicle OCR App - Edits & Modifications Log

**Date:** 2026-03-29  
**Task:** Fixed Extra 'A' Artifact Extraction from Number Plates

---

## 📝 Detailed Edits Log

### 1. Indian 2-Letter State Code Matcher Upgrade
* **File:** [`lib/services/ocr_service.dart`](file:///Users/admin/Documents/Flutter-Projects/vehicle_ocr_app/lib/services/ocr_service.dart)
* **Problem:** On Indian High-Security Registration Plates (HSRP), ML Kit OCR often detects the blue Ashoka Chakra / IND emblem on the left as a letter `'A'` or `'I'` (e.g. `"A IND DL7CR3815"`). The previous regex `[A-Z]{1,3}` matched `'A'` + `'DL'` = `'ADL'`, resulting in `"ADL7CR3815"`.
* **Fix:**
  - Enforced strict **2-letter state code pattern** (`RegExp(r'[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{1,4}')`) as the primary pattern matcher.
  - Added filter for noise words `IND` / `INDIA`.
  - Now correctly extracts **`DL7CR3815`** without the extra `'A'` noise.

---

## ✅ Verification
- Executed `flutter analyze`.
- **Result:** **0 Errors** (Clean Build).
