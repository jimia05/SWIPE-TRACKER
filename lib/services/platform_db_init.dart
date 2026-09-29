// Picks the right sqflite backend for the current platform. Call
// initializeDatabaseFactory() once, before any DatabaseService use.
export 'platform_db_init_stub.dart'
    if (dart.library.io) 'platform_db_init_io.dart'
    if (dart.library.js_interop) 'platform_db_init_web.dart';
