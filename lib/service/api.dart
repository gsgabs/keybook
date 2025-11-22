import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

String getBaseUrl() {
  // Web uses localhost
  if (kIsWeb) return 'http://localhost:8080';

  // Android emulator (AVD) uses 10.0.2.2 to reach host localhost
  if (Platform.isAndroid) return 'http://10.0.2.2:8080';

  // Default (iOS, desktop) - adjust if necessary
  return 'http://localhost:8080';
}
