import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'config.dart';

class GetResponses {
  Object Get({String url, Map<String, String> body}) async {
    var uri = Uri.http('${config.API_Url}', url, body);
    var response = await http.get(uri, headers: {
      // HttpHeaders.authorizationHeader: 'Token $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    return jsonDecode(response.body);
  }
}
