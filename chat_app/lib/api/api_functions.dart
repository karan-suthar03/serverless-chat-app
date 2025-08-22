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

enum FinalizeAccountSetupRequestType{
  skip,
  displayName,
  all
}

enum GenericResponseType {
  success,
  failure
}

Future<Map<String, dynamic>> finalizeAccountSetup({
  required String token,
  String? displayName,
  String? profilePictureUrl,
  required FinalizeAccountSetupRequestType type,
}) async {
  final url = Uri.parse(apiLinks['finalizeAccountSetup']!);
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  switch (type) {
    case FinalizeAccountSetupRequestType.skip:
      final body = jsonEncode({
        'requestType': 'skip',
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['type'] == 1 ? GenericResponseType.success : GenericResponseType.failure,
          'message': data['message'],
        };
      } else {
        return {
          'status': GenericResponseType.failure,
          'message': 'An unknown error occurred.',
        };
      }
    case FinalizeAccountSetupRequestType.displayName:
      final body = jsonEncode({
        'requestType': 'displayName',
        'data': {
          'displayName': displayName,
        },
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['type'] == 1 ? GenericResponseType.success : GenericResponseType.failure,
          'message': data['message'],
        };
      } else {
        return {
          'status': GenericResponseType.failure,
          'message': 'An unknown error occurred.',
        };
      }
    case FinalizeAccountSetupRequestType.all:
      final body = jsonEncode({
        'requestType': 'all',
        'data': {
          'displayName': displayName,
          'profilePictureUrl': profilePictureUrl,
        }
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['type'] == 1 ? GenericResponseType.success : GenericResponseType.failure,
          'message': data['message'],
        };
      } else {
        return {
          'status': GenericResponseType.failure,
          'message': 'An unknown error occurred.',
        };
      }
  }
}

Future<Map<String, dynamic>> getUserData({
  required String token,
}) async {
  final url = Uri.parse(apiLinks['me']!);
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return {
      'status': data['type'] == 1 ? GenericResponseType.success : GenericResponseType.failure,
      'message': data['message'],
      'user': data['user'],
    };
  } else {
    return {
      'status': GenericResponseType.failure,
      'message': 'An unknown error occurred.',
    };
  }
}

Future<Map<String, dynamic>> searchUsers({
  required String query,
  required String token,
}) async {
  final url = Uri.parse('${apiLinks['searchUsers']}?searchQuery=$query');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return {
      'status': data['type'] == 1 ? GenericResponseType.success : GenericResponseType.failure,
      'message': data['message'],
      'users': data['users'],
    };
  } else if(response.statusCode == 500){
    return {
      'status': GenericResponseType.failure,
      'message': response.body,
    };
  }
  return {
    'status': GenericResponseType.failure,
    'message': 'An unknown error occurred.',
  };
}

enum InitializeChatResponseType {
  success,
  alreadyPresent,
  failure,
}

Future<Map<String, dynamic>> initializeChat({
  required String otherUserId,
  required String token,
}) async {
  final url = Uri.parse('${apiLinks['initializeChat']}?recipientId=$otherUserId');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    if (data['type'] == 1) {
      return {
        'status': InitializeChatResponseType.success,
        'message': data['message'],
        'chatId': data['chatId'],
      };
    } else if(data['type'] == 2) {
      return {
        'status': InitializeChatResponseType.alreadyPresent,
        'message': data['message'],
        'chatId': data['chatId'],
      };
    }else{
      return {
        'status': InitializeChatResponseType.failure,
        'message': data['message'],
      };
    }
  } else {
    return {
      'status': GenericResponseType.failure,
      'message': 'An unknown error occurred.',
    };
  }
}