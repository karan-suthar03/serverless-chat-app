/**
 * Seed users table with one user
 * @param { import('knex').Knex } knex
 */
exports.seed = async function(knex) {
  await knex('users').del();

  await knex('users').insert([
    {
      id: 'user-1',
      username: 'testuser',
      email: 'testuser@example.com',
      profile_picture_url: 'https://example.com/profile.jpg',
      status: 'Online',
      is_profile_complete: true,
      last_seen: knex.fn.now(),
      created_at: knex.fn.now()
    }
  ]);
};
