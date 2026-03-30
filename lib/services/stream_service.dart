import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StreamService {
  String? _url;

  void setUrl(String url) {
    _url = url;
  }

  Future<Uint8List?> fetchFrame() async {
    if (_url == null) return null;

    try {
      final res = await http.get(Uri.parse(_url!));
      if (res.statusCode == 200) {
        return res.bodyBytes;
      }
    } catch (_) {}

    return null;
  }
}