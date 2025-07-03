// lib/services/alarm_service.dart

// This is a conditional export.
//
// By default, it exports the 'stub' implementation which does nothing and is web-compatible.
//
// If the 'dart.library.io' is available (meaning we are on a native mobile or desktop platform),
// it exports the real 'mobile' implementation instead.
export 'alarm_service_stub.dart'
    if (dart.library.io) 'alarm_service_mobile.dart';
