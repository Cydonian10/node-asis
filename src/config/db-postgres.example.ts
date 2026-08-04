/**
 * TEMPLATE ONLY - not compiled. Copy to {name}.ts when implementing.
 */
import { Pool, PoolClient } from 'pg';
import EnvVars from '@src/constants/EnvVars';

const pgConfig = {
  user: EnvVars.Database.User,
  password: EnvVars.Database.Password,
  host: EnvVars.Database.Server,
  database: EnvVars.Database.Name,
  port: EnvVars.Database.Port,
  ssl: EnvVars.Database.Ssl === 'true',
};

// Función para conectarse a la base de datos PostgreSQL
async function connectToPostgres(): Promise<Pool> {
  const pool = new Pool(pgConfig);

  try {
    const client: PoolClient = await pool.connect();
    const result = await client.query<{ test: number }>('SELECT 1 AS test');
    client.release();

    if (result.rowCount === 1) {
      return pool;
    }
    throw new Error('Error al verificar la conexión con PostgreSQL.');
  } catch (error) {
    const errorMessage =
      error instanceof Error
        ? `Error al conectar a la base de datos PostgreSQL: ${error.message}`
        : `Error al conectar a la base de datos PostgreSQL: ${String(error)}`;
    throw new Error(errorMessage);
  }
}

export { connectToPostgres };
