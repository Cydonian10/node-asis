import path from 'path';
import { fileURLToPath } from 'url';
import { readFileSync } from 'fs';
import dotenv from 'dotenv';
import sql from 'mssql';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '../..');

dotenv.config({ path: path.join(projectRoot, `env/${process.env.NODE_ENV ?? 'development'}.env`) });

const dbConfig: sql.config = {
  user: process.env.DB_USER ?? '',
  password: process.env.DB_PASSWORD ?? '',
  server: process.env.DB_SERVER ?? 'localhost',
  database: process.env.DB_NAME ?? '',
  port: Number(process.env.DB_PORT ?? 1433),
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

function splitBatches(sqlText: string): string[] {
  return sqlText
    .split(/^\s*GO\s*$/gim)
    .map((b) => b.trim())
    .filter((b) => b.length > 0);
}

async function run() {
  const files = process.argv.slice(2);
  if (files.length === 0) {
    console.error('Uso: tsx src/scripts/runSqlFile.ts <archivo1.sql> [archivo2.sql ...]');
    process.exit(1);
  }

  console.log(`Conectando a ${dbConfig.server}:${dbConfig.port}/${dbConfig.database} ...`);
  const pool = await new sql.ConnectionPool(dbConfig).connect();

  let ok = 0;
  let fail = 0;

  for (const file of files) {
    try {
      const content = readFileSync(file, 'utf8');
      const batches = splitBatches(content);
      for (const batch of batches) {
        await pool.request().batch(batch);
      }
      ok += 1;
      console.log(`[OK] ${file} (${batches.length} lotes)`);
    } catch (error) {
      fail += 1;
      console.error(`[FAIL] ${file}`);
      console.error(`        ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  await pool.close();

  console.log('----------------------------------------');
  console.log(`Archivos SQL: ${ok} OK, ${fail} FAIL (total ${files.length})`);
  process.exit(fail > 0 ? 1 : 0);
}

run().catch((error) => {
  console.error('Error fatal:', error instanceof Error ? error.message : String(error));
  process.exit(1);
});
