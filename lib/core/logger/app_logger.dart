import 'package:flutter/foundation.dart';

void logDebug(String msg, {String? tag}) => debugPrint('🔍 ${_t(tag)}$msg');

void logInfo(String msg, {String? tag}) => debugPrint('✅ ${_t(tag)}$msg');

void logWarn(String msg, {String? tag}) => debugPrint('⚠️ ${_t(tag)}$msg');

void logError(String msg, {String? tag, Object? error}) =>
    debugPrint('❌ ${_t(tag)}$msg${error != null ? '\n   $error' : ''}');

String _t(String? tag) => tag != null ? '[$tag] ' : '';
