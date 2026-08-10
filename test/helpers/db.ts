import sql from 'mssql';
import fs from 'node:fs/promises';
import path from 'node:path';
import { connectToDb } from '@src/config/db-sqlserver.js';

export type FixtureMarcacion = {
  empCode: string;
  punchTime: Date;
  punchState?: string;
  terminalId?: number;
};

export async function insertarMarcacion(
  fixture: FixtureMarcacion,
): Promise<number> {
  const pool = await connectToDb();
  const request = pool.request();
  request.input('EmpCode', sql.VarChar(20), fixture.empCode);
  request.input('PunchTime', sql.DateTime, fixture.punchTime);
  request.input('PunchState', sql.VarChar(5), fixture.punchState ?? '0');
  request.input('TerminalId', sql.Int, fixture.terminalId ?? 1);
  request.input('CreatedBy', sql.Int, 1);

  const result = await request.query<{ MarcacionId: number }>(
    `INSERT INTO Marcacion
       (EmpCode, PunchTime, PunchState, TerminalId, Eliminado, CreatedBy, CreatedAt)
     OUTPUT INSERTED.MarcacionId
     VALUES (@EmpCode, @PunchTime, @PunchState, @TerminalId, 0, @CreatedBy, GETDATE())`,
  );
  return result.recordset[0].MarcacionId;
}

export async function getAsistencia(usuarioId: number, fecha: string) {
  const pool = await connectToDb();
  const request = pool.request();
  request.input('UsuarioId', sql.Int, usuarioId);
  request.input('Fecha', sql.Date, new Date(`${fecha}T00:00:00`));
  const result = await request.query(
    `SELECT TOP 1 *
     FROM Asistencia
     WHERE UsuarioId = @UsuarioId AND Fecha = @Fecha
     ORDER BY AsistenciaId DESC`,
  );
  return result.recordset[0] ?? null;
}

export async function getAsistenciaMarcaciones(asistenciaId: number) {
  const pool = await connectToDb();
  const request = pool.request();
  request.input('AsistenciaId', sql.Int, asistenciaId);
  const result = await request.query(
    `SELECT * FROM AsistenciaMarcacion
     WHERE AsistenciaId = @AsistenciaId
     ORDER BY AsistenciaMarcacionId`,
  );
  return result.recordset;
}

export async function queryDatabase<T = Record<string, unknown>>(
  query: string,
): Promise<T[]> {
  const pool = await connectToDb();
  const result = await pool.request().query<T>(query);
  return result.recordset;
}

export async function getSeedUsuarioId(syncUsuarioId: number): Promise<number> {
  const rows = await queryDatabase<{ UsuarioId: number }>(
    `SELECT UsuarioId FROM Usuario WHERE SyncUsuarioId = ${syncUsuarioId}`,
  );
  if (!rows[0]) throw new Error(`No existe el usuario seed ${syncUsuarioId}`);
  return rows[0].UsuarioId;
}

export async function setSeedPermissionDate(fecha: string): Promise<void> {
  await queryDatabase(
    `UPDATE P
     SET FechaSolicitud = '${fecha}T08:00:00'
     FROM Permisos P
     INNER JOIN Usuario U ON U.UsuarioId = P.UsuarioId
     WHERE U.SyncUsuarioId = 2003`,
  );
}

export async function limpiarDatosAsistenciaSeed(): Promise<void> {
  await queryDatabase(
    `DELETE AM
     FROM AsistenciaMarcacion AM
     INNER JOIN Asistencia A ON A.AsistenciaId = AM.AsistenciaId
     INNER JOIN Usuario U ON U.UsuarioId = A.UsuarioId
     WHERE U.SyncUsuarioId IN (2001, 2002, 2003);
     DELETE A
     FROM Asistencia A
     INNER JOIN Usuario U ON U.UsuarioId = A.UsuarioId
     WHERE U.SyncUsuarioId IN (2001, 2002, 2003);
     DELETE J
     FROM Justificaciones J
     INNER JOIN Usuario U ON U.UsuarioId = J.UsuarioId
     WHERE U.SyncUsuarioId IN (2001, 2002, 2003);
     DELETE M
     FROM Marcacion M
     WHERE M.EmpCode IN ('20010001', '20020002', '20030003');`,
  );
}

export async function desplegarSpsAsistencia(): Promise<void> {
  const basePath = path.join(
    process.cwd(),
    'database',
    'sql-scripts',
    'procedures',
    'ASISTENCIA',
  );
  const pool = await connectToDb();
  for (const file of [
    'usp_GetAsistenciasReprocesar.sql',
    'usp_GetTurnoVigente.sql',
  ]) {
    const script = await fs.readFile(path.join(basePath, file), 'utf8');
    await pool.request().batch(script.replace(/^\s*GO\s*$/gim, ''));
  }
}

export function nextWeekdayDate(base = new Date()): Date {
  const result = new Date(base);
  result.setHours(0, 0, 0, 0);
  while (result.getDay() === 0 || result.getDay() === 6) {
    result.setDate(result.getDate() + 1);
  }
  return result;
}

export function isoDateForTest(date: Date): string {
  return date.toISOString().slice(0, 10);
}
