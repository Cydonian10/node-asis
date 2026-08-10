import { beforeAll, afterAll, afterEach, describe, expect, it, jest } from '@jest/globals';
import supertest from 'supertest';
import app from '../helpers/asistencia-test-app.js';
import {
  getAsistencia,
  getAsistenciaMarcaciones,
  getSeedUsuarioId,
  insertarMarcacion,
  isoDateForTest,
  limpiarDatosAsistenciaSeed,
  nextWeekdayDate,
  setSeedPermissionDate,
  desplegarSpsAsistencia,
} from '../helpers/db.js';

const agent = supertest(app);

describe('Asistencia E2E con API_SCAP_DB', () => {
  let fecha: string;

  beforeAll(async () => {
    await desplegarSpsAsistencia();
    const seed = await agent.post('/seed').expect(201);
    expect(seed.body.State).toBe(1);
    await limpiarDatosAsistenciaSeed();
    fecha = isoDateForTest(nextWeekdayDate());
    await setSeedPermissionDate(fecha);
  });

  afterEach(async () => {
    await limpiarDatosAsistenciaSeed();
  });

  afterAll(async () => {
    await limpiarDatosAsistenciaSeed();
    await agent.delete('/seed').expect(200);
  });

  it('crea entrada y luego actualiza salida', async () => {
    const usuarioId = await getSeedUsuarioId(2002);
    const entradaId = await insertarMarcacion({
      empCode: '20020002',
      punchTime: new Date(`${fecha}T09:00:00Z`),
    });

    const entrada = await agent
      .post('/asistencia/procesar-marcaciones')
      .send({ usuarioId, fecha })
      .expect(200);
    expect(entrada.body.creadas).toBeGreaterThanOrEqual(1);

    const primera = await getAsistencia(usuarioId, fecha);
    expect(primera).not.toBeNull();
    expect(primera.ResultadoAsistencia).toContain('SinMarcacionSalida');

    const salidaId = await insertarMarcacion({
      empCode: '20020002',
      punchTime: new Date(`${fecha}T17:00:00Z`),
    });
    await agent
      .post('/asistencia/procesar-marcaciones')
      .send({ usuarioId, fecha })
      .expect(200);

    const final = await getAsistencia(usuarioId, fecha);
    expect(final.HoraSalida).not.toBeNull();
    expect(final.ResultadoAsistencia).toBe('Asistio');
    const enlaces = await getAsistenciaMarcaciones(final.AsistenciaId);
    expect(enlaces.map((row) => row.MarcacionId)).toEqual(
      expect.arrayContaining([entradaId, salidaId]),
    );
  }, 30000);

  it('reporta EmpCode desconocido sin crear asistencia', async () => {
    await insertarMarcacion({
      empCode: '99999999',
      punchTime: new Date(`${fecha}T09:00:00Z`),
    });

    const response = await agent
      .post('/asistencia/procesar-marcaciones')
      .send({ fecha })
      .expect(200);

    expect(response.body.errores).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ motivo: 'Usuario no encontrado por DNI' }),
      ]),
    );
  }, 30000);

  it('mantiene Permiso como resultado cuando llegan marcaciones', async () => {
    const usuarioId = await getSeedUsuarioId(2003);
    await insertarMarcacion({
      empCode: '20030003',
      punchTime: new Date(`${fecha}T07:00:00Z`),
    });

    await agent
      .post('/asistencia/procesar-marcaciones')
      .send({ usuarioId, fecha })
      .expect(200);

    const asistencia = await getAsistencia(usuarioId, fecha);
    expect(asistencia).not.toBeNull();
    expect(asistencia.ResultadoAsistencia).toBe('Permiso');
  }, 30000);

  it('ejecuta el reprocesamiento contra la base de desarrollo', async () => {
    const response = await agent
      .post('/asistencia/reprocesar-asistencias')
      .send({ fecha })
      .expect(200);

    expect(response.body).toEqual(
      expect.objectContaining({
        procesadas: expect.any(Number),
        creadas: expect.any(Number),
        actualizadas: expect.any(Number),
        ignoradas: expect.any(Number),
      }),
    );
  }, 30000);
});
