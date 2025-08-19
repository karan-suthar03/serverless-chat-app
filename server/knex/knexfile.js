// Update with your config settings.

const fs = require('fs');
const yaml = require('js-yaml');
let POSTGRES_URL = process.env.POSTGRES_URL;
try {
  if (!POSTGRES_URL) {
    const secrets = yaml.load(fs.readFileSync('../aws-sam/.secrets.yml', 'utf8'));
    POSTGRES_URL = secrets.POSTGRES_URL;
  }
} catch (e) {
  console.warn('Could not load .secrets.yml:', e);
}

/**
 * @type { Object.<string, import("knex").Knex.Config> }
 */
module.exports = {

  development: {
    client: 'pg',
    connection: POSTGRES_URL,
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  staging: {
    client: 'pg',
    connection: POSTGRES_URL,
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  production: {
    client: 'pg',
    connection: POSTGRES_URL,
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }

};
