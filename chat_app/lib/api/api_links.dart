// Stores all API endpoint links
// so we can change the endpoints easily from external stored file later
// these endpoints will be only used if available or else we'll fetch from github
const Map<String, String> apiLinks = {
  'checkUsername': 'https://jvd2c9nr2l.execute-api.ap-south-1.amazonaws.com/api/open/checkUsername',
  'createUser': 'https://jvd2c9nr2l.execute-api.ap-south-1.amazonaws.com/api/protected/createAccount',
  'updateUsername': 'https://jvd2c9nr2l.execute-api.ap-south-1.amazonaws.com/api/protected/updateUsername',
  'finalizeAccountSetup': 'https://jvd2c9nr2l.execute-api.ap-south-1.amazonaws.com/api/protected/finalizeAccountSetup',
  'me': 'https://jvd2c9nr2l.execute-api.ap-south-1.amazonaws.com/api/protected/me',
};
