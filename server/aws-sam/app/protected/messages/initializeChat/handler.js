const knex = require('knex')({
  client: 'pg',
  connection: process.env.POSTGRES_URL,
});

exports.initializeChat = async (event) => {
  const claims = event.requestContext.authorizer.jwt.claims;
  const uid = claims.user_id; // current user
  const recipientId = event.queryStringParameters.recipientId; // recipient
  
  const trx = await knex.transaction();

  try {
    // Check if a private chat already exists between these two users
    const existingChat = await trx('chats as c')
      .select('c.id')
      .join('chat_participants as cp1', 'c.id', 'cp1.chat_id')
      .join('chat_participants as cp2', 'c.id', 'cp2.chat_id')
      .where('c.type', 'private')
      .andWhere('cp1.user_id', uid)
      .andWhere('cp2.user_id', recipientId)
      .first();

    if (existingChat) {
      await trx.commit();
      return {
        statusCode: 200,
        body: JSON.stringify({
          type: 2,
          chatId: existingChat.id,
          message: 'Private chat already exists',
        }),
      };
    }

    // Step 1: Create the new chat within the transaction.
    const [newChat] = await trx('chats').insert({ type: 'private' }).returning('id');
    const chatId = newChat.id;

    // Step 2: Insert both participants into the chat_participants table.
    await trx('chat_participants').insert([
      { user_id: uid, chat_id: chatId },
      { user_id: recipientId, chat_id: chatId },
    ]);

    await trx.commit();

    return {
      statusCode: 201,
      body: JSON.stringify({
        type: 1,
        chatId,
        message: 'Chat initialized successfully',
      }),
    };

  } catch (err) {
    await trx.rollback();
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