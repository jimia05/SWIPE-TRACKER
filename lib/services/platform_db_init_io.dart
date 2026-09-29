import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// iOS, Android and macOS ship a native sqflite implementation already;
/// only Linux/Windows need the FFI-backed factory swapped in.
void initializeDatabaseFactory() {
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
