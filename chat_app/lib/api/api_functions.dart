import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_links.dart';
/* TODO: probably have to make a make some kind of machanism to do get 
 * requests and other requests with same type of error handling */
Future<bool> checkUsername(String username) async {
  final url = Uri.parse('${apiLinks['checkUsername']}?username=$username');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['isAvailable'] == true;
  }
  return false;
}
