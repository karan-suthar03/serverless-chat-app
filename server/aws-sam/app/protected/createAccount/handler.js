const knex = require('knex')({
  client: 'pg',
  connection: process.env.POSTGRES_URL,
});

exports.createAccount = async (event) => {
  const claims = event.requestContext.authorizer.jwt.claims;
  const uid = claims.user_id;
  const { username } = JSON.parse(event.body);

  try {
    // Check if user already exists
    const existingUser = await knex('users').where({ id: uid }).first();

    if (existingUser) {
      return {
        statusCode: 200,
        body: JSON.stringify({
          type: 4,
          message: "User already exists",
          user: existingUser
        }),
      };
    }

    // First insert with only id
    await knex('users').insert({ id: uid });

    let usernameStatus = "not_set";

    try {
      // Try updating username
      await knex('users')
        .where({ id: uid })
        .update({ username });

      usernameStatus = "set";
    } catch (err) {
      if (err.code === "23505") {
        // Unique violation (username taken)
        usernameStatus = "failed_duplicate";
      } else {
        throw err;
      }
    }

    if (usernameStatus === "set") {
      return {
        statusCode: 200,
        body: JSON.stringify({
          type: 1,
          message: "User created with username",
          id: uid,
          username
        }),
      };
    } else {
      return {
        statusCode: 200,
        body: JSON.stringify({
          type: 2,
          message: "User created but username failed",
          id: uid,
        }),
      };
    }

  } catch (err) {
    console.error("Create account error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({
        type: 3,
        message: "Totally failed",
        error: err.message
      }),
    };
  }
};
