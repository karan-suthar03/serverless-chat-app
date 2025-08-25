/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = async function(knex) {
    await knex.raw(`
    CREATE OR REPLACE FUNCTION update_chat_on_new_message_function()
    RETURNS TRIGGER AS $$
    BEGIN
        UPDATE chats
        SET last_message_id = NEW.id,
            updated_at = NOW()
        WHERE id = NEW.chat_id;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER update_chat_on_new_message_trigger
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_chat_on_new_message_function();
  `);
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = async function(knex) {
    await knex.raw(`
    DROP TRIGGER IF EXISTS update_chat_on_new_message_trigger ON messages;
    DROP FUNCTION IF EXISTS update_chat_on_new_message_function();
  `);
};
