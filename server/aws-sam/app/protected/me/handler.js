const knex = require('knex')({
  client: 'pg',
  connection: process.env.POSTGRES_URL,
});

exports.getProfile = async (event) => {
  const claims = event.requestContext.authorizer.jwt.claims;
  const uid = claims.user_id;

  try {
    const user = await knex('users').where({ id: uid }).first();
    if (!user) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          type: 3,
          message: "User not found",
        }),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        type: 1,
        message: "Profile retrieved successfully",
        user,
      }),
    };
  } catch (err) {
    console.error("Get profile error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({
        type: 3,
        message: "Failed to retrieve profile",
        error: err.message,
      }),
    };
  }
};
