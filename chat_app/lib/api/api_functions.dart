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

enum CreateUserResponseType {
  userAlreadyExists,
  usernameFailed,
  createdSuccessfully,
  unknownError,
}

Future<Map<String, dynamic>> createUser({
  required String username,
  String? token,
}) async {
  final url = Uri.parse(apiLinks['createUser']!);
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  final body = jsonEncode({
    'username': username,
  });
  final response = await http.post(url, headers: headers, body: body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['type'] == 1) {
      return {
        'status': CreateUserResponseType.createdSuccessfully,
        'message': data['message'],
        'username': data['username'],
      };
    } else if (data['type'] == 2) {
      return {
        'status': CreateUserResponseType.usernameFailed,
        'message': data['message'],
      };
    } else if (data['type'] == 3) {
      return {
        'status': CreateUserResponseType.unknownError,
        'message': data['message'],
      };
    } else if (data['type'] == 4) {
      return {
        'status': CreateUserResponseType.userAlreadyExists,
        'message': data['message'],
      };
    } else {
      return {
        'status': CreateUserResponseType.unknownError,
        'message': 'An unknown error occurred.',
      };
    }
  } else {
    return {
      'status': CreateUserResponseType.unknownError,
      'message': 'An unknown error occurred.',
    };
  }
}

enum UpdateUsernameResponseType {
  usernameUpdatedSuccessfully,
  usernameFailed,
  unknownError,
}

Future<Map<String, dynamic>> updateUsername({
  required String username,
  required String token,
}) async {
  final url = Uri.parse(apiLinks['updateUsername']!);
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = jsonEncode({
    'username': username,
  });
  final response = await http.post(url, headers: headers, body: body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return {
      'status': data['type'] == 1 ? UpdateUsernameResponseType.usernameUpdatedSuccessfully : UpdateUsernameResponseType.usernameFailed,
      'message': data['message'],
    };
  } else {
    return {
      'status': UpdateUsernameResponseType.unknownError,
      'message': 'An unknown error occurred.',
    };
  }
}

enum finalizeAccountSetupRequestType{
  skip,
  displayName,
  all
}

enum genericResponseType {
  success,
  failure
}

Future<Map<String, dynamic>> finalizeAccountSetup({
  required String token,
  String? displayName,
  String? profilePictureUrl,
  required finalizeAccountSetupRequestType type,
}) async {
  final url = Uri.parse(apiLinks['finalizeAccountSetup']!);
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  switch (type) {
    case finalizeAccountSetupRequestType.skip:
      final body = jsonEncode({
        'requestType': 'skip',
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['type'] == 1 ? genericResponseType.success : genericResponseType.failure,
          'message': data['message'],
        };
      } else {
        return {
          'status': genericResponseType.failure,
          'message': 'An unknown error occurred.',
        };
      }
    case finalizeAccountSetupRequestType.displayName:
      final body = jsonEncode({
        'requestType': 'displayName',
        'displayName': displayName,
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['type'] == 1 ? genericResponseType.success : genericResponseType.failure,
          'message': data['message'],
        };
      } else {
        return {
          'status': genericResponseType.failure,
          'message': 'An unknown error occurred.',
        };
      }
    case finalizeAccountSetupRequestType.all:
      final body = jsonEncode({
        'requestType': 'all',
        'displayName': displayName,
        'profilePictureUrl': profilePictureUrl,
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['type'] == 1 ? genericResponseType.success : genericResponseType.failure,
          'message': data['message'],
        };
      } else {
        return {
          'status': genericResponseType.failure,
          'message': 'An unknown error occurred.',
        };
      }
  }
}