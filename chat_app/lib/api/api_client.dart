import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {},
  });

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    return Uri.parse(baseUrl + endpoint).replace(queryParameters: queryParams);
  }

  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint, queryParams);
    return await http.get(uri, headers: {...defaultHeaders, ...?headers});
  }

  Future<http.Response> post(String endpoint, {Object? body, Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint);
    return await http.post(
      uri,
      headers: {...defaultHeaders, ...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, {Object? body, Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint);
    return await http.put(
      uri,
      headers: {...defaultHeaders, ...?headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint, {Object? body, Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint);
    return await http.delete(
      uri,
      headers: {...defaultHeaders, ...?headers, 'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
  }
}

// Use these clients for different endpoint types
final apiClientProtected = ApiClient(
  baseUrl: 'https://jvd2c9nr2l.execute-api.ap-south-1.amazonaws.com/api/protected/',
);

final apiClientOpen = ApiClient(
  baseUrl: 'https://jvd2c9nr2l.execute-api.ap-south-1.amazonaws.com/api/open/',
);
