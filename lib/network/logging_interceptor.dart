import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  final _stopwatches = <String, Stopwatch>{};

  static const _separator = '────────────────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final key = _requestKey(options);
      _stopwatches[key] = Stopwatch()..start();

      final buf = StringBuffer();
      buf.writeln('┌$_separator');
      buf.writeln('│ ➡ REQUEST  ${options.method}  ${options.uri}');
      buf.writeln('│ Headers:');
      options.headers.forEach((k, v) {
        // Mask token values so they don't flood the log
        final display = k.toLowerCase() == 'authorization'
            ? _maskToken(v.toString())
            : v;
        buf.writeln('│   $k: $display');
      });
      if (options.data != null) {
        buf.writeln('│ Body:');
        buf.writeln('│   ${_formatBody(options.data)}');
      }
      buf.write('└$_separator');
      debugPrint(buf.toString());
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final options = response.requestOptions;
      final elapsed = _stopAndGet(options);

      final buf = StringBuffer();
      buf.writeln('┌$_separator');
      buf.writeln(
        '│ ✅ RESPONSE  ${response.statusCode}  ${options.method}  ${options.path}  ($elapsed)',
      );
      buf.writeln('│ Body:');
      buf.writeln('│   ${_formatBody(response.data)}');
      buf.write('└$_separator');
      debugPrint(buf.toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final options = err.requestOptions;
      final elapsed = _stopAndGet(options);

      final buf = StringBuffer();
      buf.writeln('┌$_separator');
      buf.writeln(
        '│ ❌ ERROR  ${err.response?.statusCode ?? err.type.name}  '
        '${options.method}  ${options.path}  ($elapsed)',
      );
      buf.writeln('│ Type   : ${err.type}');
      buf.writeln('│ Message: ${err.message}');
      if (err.response?.data != null) {
        buf.writeln('│ Body:');
        buf.writeln('│   ${_formatBody(err.response!.data)}');
      }
      buf.write('└$_separator');
      debugPrint(buf.toString());
    }
    handler.next(err);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _requestKey(RequestOptions options) =>
      '${options.method}:${options.path}:${options.hashCode}';

  String _stopAndGet(RequestOptions options) {
    final key = _requestKey(options);
    final sw = _stopwatches.remove(key);
    if (sw == null) return '?ms';
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    return ms >= 1000 ? '${(ms / 1000).toStringAsFixed(1)}s' : '${ms}ms';
  }

  String _maskToken(String value) {
    // Keep "Bearer " prefix and last 6 chars; mask the middle
    const prefix = 'Bearer ';
    if (value.startsWith(prefix) && value.length > prefix.length + 6) {
      final token = value.substring(prefix.length);
      return '$prefix${token.substring(0, 4)}…${token.substring(token.length - 4)}';
    }
    return '***';
  }

  String _formatBody(dynamic data) {
    if (data == null) return 'null';
    if (data is Map || data is List) {
      // Truncate large payloads
      final raw = data.toString();
      if (raw.length > 800) return '${raw.substring(0, 800)}… (truncated)';
      return raw;
    }
    return data.toString();
  }
}