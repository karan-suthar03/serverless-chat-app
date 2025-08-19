const knex = require('knex')({
  client: 'pg',
  connection: process.env.POSTGRES_URL,
});

exports.checkUsername = async (event) => {
  const username = event.queryStringParameters?.username;
  const user = await knex('users').where({ username }).first();
  const isAvailable = !user;
  return {
    statusCode: 200,
    body: JSON.stringify({
      username,
      isAvailable
    }),
  };
};