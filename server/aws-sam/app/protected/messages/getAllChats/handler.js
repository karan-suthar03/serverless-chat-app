const knex = require('knex')({
  client: 'pg',
  connection: process.env.POSTGRES_URL,
});

exports.getAllChats = async (event) => {
  const claims = event.requestContext.authorizer.jwt.claims;
  const uid = claims.user_id; // current user

  const query = event.queryStringParameters || {};
  const page = parseInt(query.page) || 1;
  const limit = parseInt(query.limit) || 20;
  const offset = (page - 1) * limit;

  try {

    const chatsPromise = knex.raw(`
      SELECT
        c.*,
        json_build_object(
          'id', u.id,
          'username', u.username,
          'display_name', u.display_name,
          'profile_picture_url', u.profile_picture_url,
          'status', u.status,
          'last_seen', u.last_seen
        ) AS other_user,
        
        CASE
          WHEN m.id IS NOT NULL THEN json_build_object(
            'id', m.id,
            'text_content', m.text_content,
            'media_url', m.media_url,
            'type', m.type,
            'chat_id', m.chat_id,
            'sender_id', m.sender_id,
            'created_at', m.created_at,
            'sender', json_build_object(
              'id', sender.id,
              'username', sender.username,
              'display_name', sender.display_name
            )
          )
          ELSE NULL
        END AS last_message

      FROM
        chats AS c
      INNER JOIN
        chat_participants AS cp1 ON c.id = cp1.chat_id
      INNER JOIN
        chat_participants AS cp2 ON c.id = cp2.chat_id
      INNER JOIN
        users AS u ON cp2.user_id = u.id
      LEFT JOIN
        messages AS m ON c.last_message_id = m.id
      LEFT JOIN
        users AS sender ON m.sender_id = sender.id
      WHERE
        c.type = 'private'
        AND cp1.user_id = ?
        AND cp2.user_id != ?
      
      -- Add ORDER BY for consistent pagination
      ORDER BY
        c.updated_at DESC
      
      -- Add LIMIT and OFFSET for pagination
      LIMIT ?
      OFFSET ?;
    `, [uid, uid, limit, offset]);

    const totalPromise = knex.raw(`
      SELECT COUNT(c.id)
      FROM chats AS c
      INNER JOIN chat_participants AS cp1 ON c.id = cp1.chat_id
      WHERE cp1.user_id = ? AND c.type = 'private'
    `, [uid]);
    const [chatsResult, totalResult] = await Promise.all([chatsPromise, totalPromise]);
    
    const totalChats = parseInt(totalResult.rows[0].count, 10);
    const totalPages = Math.ceil(totalChats / limit);

    return {
      statusCode: 200,
      body: JSON.stringify({
        type: 1, // success
        pagination: {
          page,
          limit,
          totalChats,
          totalPages,
        },
        chats: chatsResult.rows, 
      }),
    };
  } catch (error) {
    console.error("Get all chats error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        type: 3, // error
        message: "Failed to fetch chats",
        error: error.message,
      }),
    };
  }
};