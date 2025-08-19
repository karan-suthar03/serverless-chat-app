/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = async function(knex) {
  await knex.raw('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');
  
  await knex.schema.createTable('users', function(table) {
    table.string('id').primary();
    table.string('username', 255).unique();
    table.string('email', 255).notNullable().unique();
    table.string('profile_picture_url', 2048);
    table.string('status').defaultTo('Offline');
    table.boolean('is_profile_complete').notNullable().defaultTo(false);
    table.timestamp('last_seen').defaultTo(knex.fn.now());
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });

  // We create this first without the last_message_id to avoid a circular dependency.
  await knex.schema.createTable('chats', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.enum('type', ['private', 'group']).notNullable();
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.timestamp('updated_at').defaultTo(knex.fn.now());
  });

  await knex.schema.createTable('group_chat_details', function(table) {
    table.uuid('chat_id').primary().references('id').inTable('chats').onDelete('CASCADE');
    table.string('name').notNullable();
    table.string('image_url', 2048);
  });

  await knex.schema.createTable('chat_participants', function(table) {
    table.string('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.uuid('chat_id').references('id').inTable('chats').onDelete('CASCADE');
    table.primary(['user_id', 'chat_id']);
    table.timestamp('joined_at').defaultTo(knex.fn.now());
  });

  await knex.schema.createTable('messages', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
    table.text('text_content');
    table.string('media_url', 2048);
    table.enum('type', ['text', 'image', 'file']).notNullable().defaultTo('text');
    table.uuid('chat_id').notNullable().references('id').inTable('chats').onDelete('CASCADE');
    table.string('sender_id').references('id').inTable('users').onDelete('SET NULL');
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });

  await knex.schema.createTable('message_read_receipts', function(table) {
    table.uuid('message_id').references('id').inTable('messages').onDelete('CASCADE');
    table.string('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.primary(['message_id', 'user_id']);
    table.timestamp('read_at').defaultTo(knex.fn.now());
  });

  // Now that the 'messages' table exists, we can add the foreign key column.
  await knex.schema.alterTable('chats', function(table) {
    table.uuid('last_message_id').nullable().references('id').inTable('messages').onDelete('SET NULL');
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = async function(knex) {
  await knex.schema.alterTable('chats', function(table) {
    table.dropForeign('last_message_id');
    table.dropColumn('last_message_id');
  });

  await knex.schema.dropTableIfExists('message_read_receipts');
  await knex.schema.dropTableIfExists('messages');
  await knex.schema.dropTableIfExists('chat_participants');
  await knex.schema.dropTableIfExists('group_chat_details');
  await knex.schema.dropTableIfExists('chats');
  await knex.schema.dropTableIfExists('users');
};
