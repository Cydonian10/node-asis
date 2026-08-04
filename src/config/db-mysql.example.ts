/**
 * TEMPLATE ONLY - not compiled. Copy to {name}.ts when implementing.
 */
import mysql from 'mysql2/promise';
import EnvVars from '@src/constants/EnvVars';

const dbConfig = {
  host: EnvVars.Database.Server,
  user: EnvVars.Database.User,
  password: EnvVars.Database.Password,
  database: EnvVars.Database.Name,
  port: EnvVars.Database.Port,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
};

// Variable para almacenar el pool
let pool: mysql.Pool | null = null;

async function connectToDb() {
  if (!pool) {
    pool = mysql.createPool(dbConfig);
    // Verificar la conexión
    const connection = await pool.getConnection();
    const [rows] = await connection.query('SELECT 1 AS Test');
    connection.release();
    if (!Array.isArray(rows) || rows.length === 0) {
      throw new Error('Error al verificar la conexión.');
    }
  }
  return pool;
}

export { connectToDb };
