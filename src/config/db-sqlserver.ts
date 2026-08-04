import sql from 'mssql';
import EnvVars from '@src/constants/EnvVars.js';

const dbConfig: sql.config = {
  user: EnvVars.Database.User,
  password: EnvVars.Database.Password,
  server: EnvVars.Database.Server,
  database: EnvVars.Database.Name,
  port: EnvVars.Database.Port,
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

// Variable para almacenar el pool de conexiones
let connectionPool: sql.ConnectionPool | null = null;

// Función para conectarse a la base de datos reutilizando el pool
async function connectToDb() {
  if (connectionPool) {
    // Si el pool ya está conectado, lo reutilizamos
    if (connectionPool.connected) {
      return connectionPool;
    }
    // Si el pool existe pero no está conectado, intentamos reconectarlo
    try {
      await connectionPool.connect();
      return connectionPool;
    } catch (error) {
      connectionPool = null; // Reiniciamos el pool si hay un error
    }
  }

  // Si no existe un pool, creamos uno nuevo
  connectionPool = new sql.ConnectionPool(dbConfig);
  try {
    await connectionPool.connect();
    return connectionPool;
  } catch (error) {
    connectionPool = null; // Reiniciamos el pool si hay un error
    let errorMessage = 'Error al conectar a la base de datos.';
    if (error instanceof Error) {
      errorMessage += ' ' + error.message;
    } else {
      errorMessage += ' ' + String(error);
    }
    throw new Error(errorMessage);
  }
}

// Exportar la función connectToDb
export { connectToDb };
