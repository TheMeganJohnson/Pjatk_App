import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

class NetworkHelper {
  static Dio? _dio;
  static PersistCookieJar? _cookieJar;

  static Future<Dio> getDio({List<String>? sha256Pins}) async {
    if (_dio != null && _cookieJar != null) return _dio!;
    final appDocDir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );
    _dio = Dio();

    _dio!.interceptors.add(CookieManager(_cookieJar!));

    (_dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) {
        if (sha256Pins != null && sha256Pins.isNotEmpty) {
          final der = cert.der;
          final sha256 = sha256Convert(der);
          return sha256Pins.contains(sha256);
        }
        return false;
      };
      return client;
    };

    return _dio!;
  }

  static String sha256Convert(Uint8List der) {
    final hash = sha256.convert(der);
    return hash.toString();
  }
}
