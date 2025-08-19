// me handler
exports.getProfile = async (event) => {
  // ...handler logic...
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Profile data' })
  };
};
