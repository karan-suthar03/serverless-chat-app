const knex = require('knex')({
  client: 'pg',
  connection: process.env.POSTGRES_URL,
});

exports.initializeChat = async (event) => {
  const claims = event.requestContext.authorizer.jwt.claims;
  const uid = claims.user_id; // current user
  const recipientId = event.queryStringParameters.recipientId; // recipient

  try {
    // Check if a private chat already exists between these two users
    const existingChat = await knex.raw(`
      SELECT c.id
      FROM chats c
      JOIN chat_participants cp1 ON c.id = cp1.chat_id
      JOIN chat_participants cp2 ON c.id = cp2.chat_id
      WHERE c.type = 'private'
        AND cp1.user_id = ?
        AND cp2.user_id = ?
      LIMIT 1
    `, [uid, recipientId]);

    if (existingChat.rows.length > 0) {
      // Return existing chat
      return {
        statusCode: 200,
        body: JSON.stringify({
          type: 2,
          chatId: existingChat.rows[0].id,
          message: 'Private chat already exists',
        }),
      };
    }

    // Create new chat with participants
    const result = await knex.raw(`
      WITH new_chat AS (
        INSERT INTO chats (id, type)
        VALUES (uuid_generate_v4(), 'private')
        RETURNING id
      )
      INSERT INTO chat_participants (user_id, chat_id)
      SELECT u.id, nc.id
      FROM (VALUES (?, ?)) AS u(id)
      CROSS JOIN new_chat AS nc
      RETURNING chat_id
    `, [uid, recipientId]);

    const chatId = result.rows[0].chat_id;

    return {
      statusCode: 201,
      body: JSON.stringify({
        type: 1,
        chatId,
        message: 'Chat initialized successfully',
      }),
    };

  } catch (err) {
    console.error("Initialize chat error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({
        type: 3,
        message: "Failed to initialize chat",
        error: err.message,
      }),
    };
  }
};
