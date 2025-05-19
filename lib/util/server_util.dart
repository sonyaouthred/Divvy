import 'dart:convert';

import 'package:http/http.dart';

/// Posts the inputted data to the server's serverFunc.
Future<void> postToServer({
  required Map<String, dynamic> data,
  required String serverFunc,
}) async {
  final uri = 'http://127.0.0.1:5000/$serverFunc';
  final headers = {'Content-Type': 'application/json'};
  final response = await post(
    Uri.parse(uri),
    headers: headers,
    body: json.encode(data),
  );
  json.decode(response.body);
}

/// Pulls data from the server's inputted serverFunc
/// will be a single json doc
Future<Map<String, dynamic>> getDataFromServer({
  required String serverFunc,
}) async {
  final uri = 'http://127.0.0.1:5000/$serverFunc';
  final headers = {'Content-Type': 'application/json'};
  final response = await get(Uri.parse(uri), headers: headers);
  return json.decode(response.body);
}
