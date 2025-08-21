const knex = require('knex')({
  client: 'pg',
  connection: process.env.POSTGRES_URL,
});

exports.searchUsers = async (event) => {
  // TODO: add pagination
  const claims = event.requestContext.authorizer.jwt.claims;
  const uid = claims.user_id;
  const searchQuery = (event.queryStringParameters && event.queryStringParameters.searchQuery) || "";

  try {
    const users = await knex('users')
      .where('username', 'ilike', `%${searchQuery}%`)
      .andWhere('is_profile_complete', true)
      .andWhereNot('id', uid); // exclude current user

    return {
      statusCode: 200,
      body: JSON.stringify({
        type: 1,
        message: "Users retrieved successfully",
        users,
      }),
    };
  } catch (err) {
    console.error("Search users error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({
        type: 3,
        message: "Failed to search users",
        error: err.message,
      }),
    };
  }
};
