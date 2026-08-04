USE API_SCAP_DB

GO

INSERT INTO Sync_Temporada
  (idTemporada, cTemporada, idPeriodoLectivo, cPeriodoLectivo)
VALUES
  (1, 'Temporada 2025-1', 20251, 'Periodo 2025'),
  (2, 'Temporada 2025-2', 20251, 'Periodo 2025'),
  (3, 'Temporada 2026-1', 20261, 'Periodo 2026'),
  (4, 'Temporada 2026-2', 20261, 'Periodo 2026'),
  (5, 'Temporada 2025-0', 20251, 'Periodo 2025');
GO


-- Usuarios

INSERT INTO Sync_Usuario
  (id,cUsuario, cNombre, cApellido, cTipo, cDni)
VALUES
  (1, 'avasquezu', 'Gabriel', 'Vasquez', 'CO', '71232786'),
  (2, 'asmith', 'Alice', 'Smith', 'AL', '87654321'),
  (3, 'bwayne', 'Bruce', 'Wayne', 'CO', '11223344'),
  (4, 'ckent', 'Clark', 'Kent', 'FA', '44332211'),
  (5, 'bwayne', 'Bruce', 'Wayne', 'CO', '11223344');
GO

INSERT INTO Sync_Unidad
  (id, cTitulo)
VALUES
  ('UO1', 'Academia Ingenieria'),
  ('UO2', 'Colegio Ingenieria'),
  ('UO3', 'Pre Academia Ingenieria');

GO

INSERT INTO Unidad
  (unidadOrgId_fk, horaEstandar, horaTotal, nCreatedBy, tCreatedAt)
VALUES
  ( 'UO1', 9, 48, 1, GETDATE()),
  ( 'UO2', 9, 48, 1, GETDATE()),
  ( 'UO3', 9, 48, 1, GETDATE());

GO

INSERT INTO Sync_Anio
  (cDenominacion, cDescripcion)
VALUES
  (1455, '2023'),
  (1456, '2024'),
  (1457, '2025');


GO

INSERT INTO DenominacionFeriado
  (codigo, cDenominacion, cDescripcion, nCreatedBy, tCreatedAt)
VALUES
  ('2', 'Feriado 1', 'Feriado Nacional', 1, GETDATE()),
  ('3', 'Feriado 2', 'Feriado Nacional', 1, GETDATE()),
  ('4', 'Feriado 3', 'Feriado Nacional', 1, GETDATE());

GO
INSERT INTO FechaFeriado
  (denominacionFeriadoId_fk, anioId_fk, fecha, nCreatedBy, tCreatedAt)
VALUES
  (1, 3, '2025-01-01', 1, GETDATE()),
  (2, 3, '2025-07-04', 1, GETDATE()),
  (3, 3, '2025-12-25', 1, GETDATE());

GO

INSERT INTO UnidadFeriado
  (unidadId_pk, fechaFeriadoId_pk, nCreatedBy, tCreatedAt)
VALUES
  (1, 1, 1, GETDATE()),
  -- Academia Ingenieria - Feriado 2025-01-01
  (2, 2, 1, GETDATE()),
  -- Colegio Ingenieria - Feriado 2025-07-04
  (3, 3, 1, GETDATE()); -- Pre Academia Ingenieria - Feriado 2025-12-25

GO


INSERT INTO Rol
  (unidadId_fk, cTitulo, cDescripcion, bSupervision, nCreatedBy, tCreatedAt)
VALUES
  (1, 'Estudiante', 'Rol de estudiante para la academia', 0, 1, GETDATE()),
  (2, 'Estudiante', 'Rol de estudiante para el colegio', 0, 1, GETDATE()),
  (3, 'Estudiante', 'Rol de estudiante para la pre academia', 0, 1, GETDATE()),
  (1, 'Profesor', 'Rol de profesor para la academia', 0, 1, GETDATE()),
  (2, 'Profesor', 'Rol de profesor para el colegio', 0, 1, GETDATE()),
  (3, 'Profesor', 'Rol de profesor para la pre academia', 0, 1, GETDATE()),
  (1, 'Coordinador', 'Rol de coordinador para la academia', 1, 1, GETDATE()),
  (2, 'Coordinador', 'Rol de coordinador para el colegio', 1, 1, GETDATE()),
  (3, 'Coordinador', 'Rol de coordinador para la pre academia', 1, 1, GETDATE()),
  (2, 'Programador', 'Rol de programador para el colegio', 1, 1, GETDATE());

GO

INSERT INTO Supervisor
  (usuarioId_pk, unidadId_pk, nCreatedBy, tCreatedAt)
VALUES
  (1, 1, 1, GETDATE()),
  -- Gabriel Vasquez Uscuvilca - Academia Ingenieria
  (4, 2, 1, GETDATE()),
  -- Clark Kent - Colegio Ingenieria
  (1, 3, 1, GETDATE()); 
  -- Gabriel Vasquez Uscuvilca - Pre Academia Ingenieria
GO

INSERT INTO RolUsuario
  (usuarioId_fk, rolId_fk, nCreatedBy, tCreatedAt)
VALUES
  (1, 1, 1, GETDATE()),
  -- Gabriel Vasquez Uscuvilca - Estudiante - Academia Ingenieria idRRolUsuario 1
  (2, 2, 1, GETDATE()),
  -- Alice Smith - Estudiante - Colegio Ingenieria
  (3, 4, 1, GETDATE()),
  -- Bruce Wayne - Profesor - Academia Ingenieria
  (4, 5, 1, GETDATE()),
  -- Clark Kent - Profesor - Colegio Ingenieria
  (1, 7, 1, GETDATE()),
  -- Gabriel Vasquez Uscuvilca - Coordinador - Academia Ingenieria idRRolUsuario 5
  (4, 8, 1, GETDATE()),
  -- Clark Kent - Coordinador - Colegio Ingenieria
  (1, 10, 1, GETDATE()); 
  -- Gabriel Vasquez Uscuvilca - Programador - Colegio Ingenieria idRRolUsuario 7

GO

INSERT INTO Controles
  (nTolerancia, nLimiteFalta, nLimiteMarcacion, nCreatedBy, tCreatedAt)
VALUES
  (5, 3, 2, 1, GETDATE()),
  -- Valores de ejemplo para Controles
  (10, 5, 3, 1, GETDATE());

GO

INSERT INTO ControlVacaciones
  (rolUsuarioId_fk, nDiasDisponibles, nDiasTomados, bAprobado, nCreatedBy, tCreatedAt)
VALUES
  (1, 15, 5, 1, 1, GETDATE()),
  -- Gabriel Vasquez Uscuvilca - Academia Ingenieria
  (2, 10, 2, 1, 1, GETDATE()),
  -- Alice Smith - Colegio Ingenieria
  (3, 20, 8, 1, 1, GETDATE()); -- Bruce Wayne - Academia Ingenieria

GO

INSERT INTO PeriodoVacacional
  (controlVacacionalId_fk, fechaInicio, fechaFin, nDiasConsumidos, nCreatedBy, tCreatedAt)
VALUES
  (1, '2025-06-01', '2025-06-10', 8, 1, GETDATE()),
  -- Gabriel Vasquez Uscuvilca
  (2, '2025-07-15', '2025-07-20', 4, 1, GETDATE()),
  -- Alice Smith
  (3, '2025-08-05', '2025-08-15', 9, 1, GETDATE()); -- Bruce Wayne


GO

INSERT INTO RolControl
  (rolId_fk, controlId_fk, nCreatedby, tCreatedAt)
VALUES
  (1, 1, 1, GETDATE()),
  -- Estudiante - Controles
  (4, 1, 1, GETDATE()),
  -- Profesor - Controles
  (7, 2, 1, GETDATE()),
  -- Coordinador - Controles
  (10, 2, 1, GETDATE()); -- Programador - Controles

GO

INSERT INTO ControlRolUsuario
  (controlId_fk, rolUsuarioId_fk, nCreatedBy, tCreatedAt)
VALUES
  (1, 1, 1, GETDATE()),
  -- Controles - Gabriel Vasquez Uscuvilca
  (1, 2, 1, GETDATE()),
  -- Controles - Alice Smith
  (2, 1, 1, GETDATE()),
  -- Controles - Gabriel Vasquez Uscuvilca
  (2, 4, 1, GETDATE()); -- Controles - Clark Kent

GO

INSERT INTO ControlUnidad
  (controlId_fk, unidadId_fk, nCreatedBy, tCreatedAt)
VALUES
  (1, 1, 1, GETDATE()),
  -- Controles - Academia Ingenieria
  (1, 2, 1, GETDATE()),
  -- Controles - Colegio Ingenieria
  (2, 3, 1, GETDATE()); -- Controles - Pre Academia Ingenieria
  
GO

INSERT INTO Biometrico
  (marca, tipoBD, bEliminado, nCreatedBy, tCreatedAt)
VALUES
  ('BIO12345', 'POSTGRES', 0, 1, GETDATE()),
  ('BIO67890', 'MONGO', 0, 1, GETDATE());

GO

INSERT INTO DetalleBiometrico
  (biometricoId_fk, cNombre, ip, serie, ubicacion, bTarjeta, bHuella, bRostro, nCreatedBy, tCreatedAt)
VALUES
  (1, 'Dispositivo A', '193.123.123.123', 'SER12345', 'Entrada Principal', 1, 1, 0, 1, GETDATE()),
  (2, 'Dispositivo B', '193.123.123.124', 'SER67890', 'Entrada Secundaria', 1, 0, 1, 1, GETDATE());

GO

INSERT Motivo
  (nombre, detalle, bDocumento, bEliminado, nCreatedBy, tCreatedAt)
VALUES
  ('Falta Justificada', 'Falta por motivo justificado', 1, 0, 1, GETDATE()),
  -- Requiere documento
  ('Tardanza', 'Llegada tarde al trabajo', 0, 0, 1, GETDATE()),
  -- No requiere documento
  ('Permiso Médico', 'Permiso por razones médicas', 1, 0, 1, GETDATE()),
  -- Requiere documento
  ('Permiso Personal', 'Permiso por asuntos personales', 0, 0, 1, GETDATE()),-- No requiere documento
  ('Licencia por Maternidad', 'Licencia otorgada por maternidad', 1, 0, 1, GETDATE()),
  -- Requiere documento
  ('Licencia por Paternidad', 'Licencia otorgada por paternidad', 1, 0, 1, GETDATE()),
  -- Requiere documento
  ('Fallecimiento Familiar', 'Permiso por fallecimiento de familiar', 1, 0, 1, GETDATE()),
  -- Requiere documento
  ('Citación Judicial', 'Permiso por citación judicial', 1, 0, 1, GETDATE());
-- Requiere documento

GO

INSERT INTO Dia
  (cTitulo, nCreatedBy, tCreatedAt)
VALUES
  ('Lunes', 1, GETDATE()),
  ('Martes', 1, GETDATE()),
  ('Miércoles', 1, GETDATE()),
  ('Jueves', 1, GETDATE()),
  ('Viernes', 1, GETDATE()),
  ('Sábado', 1, GETDATE()),
  ('Domingo', 1, GETDATE());


INSERT INTO Horario
  (cTitulo, horaDia, bGeneral, bExtendido, bRotativo, nCreatedBy, tCreatedAt, idTemporada)
VALUES
  ('Horario Gabriel', '09', 1, 0, 0, 1, GETDATE(), null),
  ('Horario Vespertino', '14', 1, 0, 0, 1, GETDATE(), null),
  ('Horario Nocturno', '20', 1, 0, 0, 1, GETDATE(), null),
  ('Horario Extendido Mañana', '07', 0, 1, 0, 1, GETDATE(), null),
  ('Horario Extendido Tarde', '13', 0, 1, 0, 1, GETDATE(), null),
  ('Horario Rotativo Semanal', '09', 0, 0, 1, 1, GETDATE(), null),
  ('Horario Profesor', '09', 0, 0, 1, 1, GETDATE(), null);
GO

-- Insertamos los días asociados al Horario Gabriel (id 1) para Lunes a Viernes
INSERT INTO HorarioDias
  (horarioId_fk, diaId_fk, bLibre, bEliminado, tCreatedAt, nCreatedBy)
VALUES
  (1, 1, 0, 0, GETDATE(), 1),
  -- id 1
  (1, 2, 0, 0, GETDATE(), 1),
  -- id 2
  (1, 3, 0, 0, GETDATE(), 1),
  -- id 3
  (1, 4, 0, 0, GETDATE(), 1),
  -- id 4
  (1, 5, 0, 0, GETDATE(), 1),
  -- id 5
  (1, 6, 1, 0, GETDATE(), 1),
  -- id 6
  (1, 7, 1, 0, GETDATE(), 1); -- id 7
GO

SELECT * FROM Vigencia
update Vigencia set tFechaInicio = '2026-01-01', tFechaFin = '2026-12-31' where id in (6,7,8,9,10,11)


INSERT INTO TurnoRegular
  -- 0 Es Entrada y 1 es Salida en bTipo
  (horarioDiasId_fk, orden, horaInicio, bTipo, bEliminado, nCreatedBy, tCreatedAt)
VALUES
  -- Lunes entrda
  (1, 1, '08:00', 1, 0, 1, GETDATE()),
  -- Lunes salida
  (1, 2, '14:00', 2, 0, 1, GETDATE()),
  -- Lunes entrada
  (1, 3, '15:00', 1, 0, 1, GETDATE()),
  -- Lunes salida
  (1, 4, '18:00', 2, 0, 1, GETDATE()),
  -- Martes entrda
  (2, 1, '08:00', 1, 0, 1, GETDATE()),
  -- Martes salida
  (2, 2, '14:00', 2, 0, 1, GETDATE()),
  -- Martes entrada
  (2, 3, '15:00', 1, 0, 1, GETDATE()),
  -- Martes salida
  (2, 4, '18:00', 2, 0, 1, GETDATE()),
  -- Miercoles entrda
  (3, 1, '08:00', 1, 0, 1, GETDATE()),
  -- Miercoles salida
  (3, 2, '14:00', 2, 0, 1, GETDATE()),
  -- Miercoles entrada
  (3, 3, '15:00', 1, 0, 1, GETDATE()),
  -- Miercoles salida
  (3, 4, '18:00', 2, 0, 1, GETDATE()),
  -- Jueves entrda
  (4, 1, '08:00', 1, 0, 1, GETDATE()),
  -- Jueves salida
  (4, 2, '14:00', 2, 0, 1, GETDATE()),
  -- Jueves entrada
  (4, 3, '15:00', 1, 0, 1, GETDATE()),
  -- Jueves salida
  (4, 4, '18:00', 2, 0, 1, GETDATE()); 
GO

INSERT INTO TurnoExtendido
  -- significa que entrasa un dia salia al dia siguiente o segun dia conectado
  (horarioDiasId_fk, horaInicio, horaFin, nCreatedBy)
VALUES
  (5, '20:00', '01:00', 1) -- id 1;

GO

INSERT INTO ConectadoDias
  (turnoExtendidoId_pk, diasId_pk, nCreatedBy, tCreatedAt)
VALUES
  (1, 6, 1, GETDATE());

GO


-- Insertamos los días asociados al Horario Profesor (id 7) para Lunes a Viernes
INSERT INTO HorarioDias
  (horarioId_fk, diaId_fk, bLibre, bEliminado, tCreatedAt, nCreatedBy)
VALUES
  (7, 1, 0, 0, GETDATE(), 1);
  -- (7, 2, 0, 0, GETDATE(), 1),
  -- (7, 3, 0, 0, GETDATE(), 1),
  -- (7, 4, 0, 0, GETDATE(), 1),
  -- (7, 5, 0, 0, GETDATE(), 1);
GO


INSERT INTO TurnoRegular
  -- 0 Es Entrada y 1 es Salida en bTipo
  (horarioDiasId_fk, orden, horaInicio, bTipo, bEliminado, nCreatedBy, tCreatedAt)
VALUES
  -- Lunes entrda
  (8, 1, '08:00', 0, 0, 1, GETDATE()),
  (8, 2, '10:00', 1, 0, 2, GETDATE()),
  (8, 3, '11:00', 0, 0, 1, GETDATE()),
  (8, 4, '13:00', 1, 0, 2, GETDATE()),
  (8, 5, '14:00', 0, 0, 1, GETDATE()),
  (8, 6, '16:00', 1, 0, 2, GETDATE());

--
INSERT INTO Horario
  (cTitulo, horaDia, bGeneral, bExtendido, bRotativo, nCreatedBy, tCreatedAt, idTemporada)
VALUES
  ('Horario Profesor 2', '09', 0, 0, 1, 1, GETDATE(), 5);


--
-- Insertemos los dias asociados alhoraio profesor (id 7) para martes 2025 tempordara 2025-0
INSERT INTO HorarioDias
  (horarioId_fk, diaId_fk, bLibre, bEliminado, tCreatedAt, nCreatedBy)
VALUES
  (11, 2, 0, 0, GETDATE(), 1);

INSERT INTO TurnoRegular
  -- 0 Es Entrada y 1 es Salida en bTipo
  (horarioDiasId_fk, orden, horaInicio, bTipo, bEliminado, nCreatedBy, tCreatedAt)
VALUES
  -- Martes entrda
  (9, 1, '08:00', 0, 0, 1, GETDATE()),
  (9, 2, '10:00', 1, 0, 2, GETDATE()),
  (9, 3, '11:00', 0, 0, 1, GETDATE()),
  (9, 4, '13:00', 1, 0, 2, GETDATE()),
  (9, 5, '14:00', 0, 0, 1, GETDATE()),
  (9, 6, '16:00', 1, 0, 2, GETDATE());


INSERT into Marcacion
  (emp_code, punch_time, punch_state, terminal_sn, terminal_alias, emp_id, terminal_id, nCreatedBy)
VALUES
  ('71232786', '2026-01-05 08:05:00', 0, 'T001', 'Terminal 1', 1, 1, 0),
  -- Entrada Lunes
  ('71232786', '2026-01-05 14:02:00', 1, 'T001', 'Terminal 1', 1, 1, 0),
  -- Salida Lunes
  ('71232786', '2026-01-05 15:03:00', 0, 'T001', 'Terminal 1', 1, 1, 0),
  -- Entrada Lunes
  ('71232786', '2026-01-05 18:00:00', 1, 'T001', 'Terminal 1', 1, 1, 0),
  -- Salida Lunes
  ('71232786', '2026-01-06 08:00:00', 0, 'T001', 'Terminal 1', 1, 1, 0);
GO

INSERT INTO HorarioUsuario
  (rolUsuarioId_fk, horarioId_fk, tFechaFin, tfechaInicio, nCreatedBy, tCreatedAt)
VALUES
  (7, 1, '2026-01-01' , '2026-12-31', 1, GETDATE());

GO
INSERT INTO Asistencia
  (horaEntrada, horaSalida, rolUsuarioid_fk, tFecha, vigenciaFin, vigenciaInicio, tCreatedAt, turnoEntradaid, turnoSalidaid, nCreatedBy)
VALUES
  ('08:00:00', '14:00:00', 7, '2026-01-05', '2026-12-31', '2026-01-01', GETDATE(), 1, 2, 1),
  ('15:00:00', '18:00:00', 7, '2026-01-05', '2026-12-31', '2026-01-01', GETDATE(), 3, 4, 1),
  ('08:00:00', '14:00:00', 7, '2026-01-06', '2026-12-31', '2026-01-01', GETDATE(), 1, 2, 1),
  ('15:00:00', '18:00:00', 7, '2026-01-06', '2026-12-31', '2026-01-01', GETDATE(), 3, 4, 1);
GO


INSERT INTO AsistenciaRegular
  (turnoRegularId_fk, asistenciaId_fk, marcacionId_fk, detalleBiometricoId_fk, nCreatedBy )
VALUES
  -- Lunes Entrada
  (1, 1, 1, 1, 1),
  -- Lunes Salida
  (2, 1, 2, 1, 1),
  -- Lunes Entrada
  (3, 2, 3, 1, 1),
  -- Lunes Salida
  (4, 2, 4, 1, 1),
  -- Martes Entrada
  (5, 3, 5, 1, 1);

GO

INSERT INTO EstadoAsistencia
  (cNombre, nCreatedBy)
VALUES
  ('Asistio', 1),
  ('Falta', 1),
  ('Tarde', 1),
  ('Salida_Acticipada', 1),
  ('Justificado', 1),
  ('Vacaciones', 1),
  ('Vigencia_Vencida', 1),
  ('Permiso', 1),
  ('Pendiente', 1);

GO

INSERT INTO Sync_ConfiguracionEtapa
  (cEtapaEducativa, cNivelEducativo, idPeriodoLectivo, cPeriodoLectivo)
VALUES

  ('3 AÑOS', 'INICIAL', 20251 , 'Periodo Lectivo 2025'),
  ('4 AÑOS', 'INICIAL', 20251 , 'Periodo Lectivo 2025'),
  ('5 AÑOS', 'INICIAL', 20251 , 'Periodo Lectivo 2025'),
  ('1° GRADO', 'PRIMARIA', 20251 , 'Periodo Lectivo 2025'),
  ('2° GRADO', 'PRIMARIA', 20251 , 'Periodo Lectivo 2025'),
  ('3° GRADO', 'PRIMARIA', 20251 , 'Periodo Lectivo 2025'),
  ('4° GRADO', 'PRIMARIA', 20251 , 'Periodo Lectivo 2025'),
  ('5° GRADO', 'PRIMARIA', 20251 , 'Periodo Lectivo 2025'),
  ('6° GRADO', 'PRIMARIA', 20251 , 'Periodo Lectivo 2025'),
  ('1° AÑO', 'SECUNDARIA', 20251 , 'Periodo Lectivo 2025'),
  ('2° AÑO', 'SECUNDARIA', 20251 , 'Periodo Lectivo 2025'),
  ('3° AÑO', 'SECUNDARIA', 20251 , 'Periodo Lectivo 2025'),
  ('4° AÑO', 'SECUNDARIA', 20251 , 'Periodo Lectivo 2025'),
  ('5° AÑO', 'SECUNDARIA', 20251 , 'Periodo Lectivo 2025'),
  ('3 AÑOS', 'INICIAL', 20262 , 'Periodo Lectivo 2026'),
  ('4 AÑOS', 'INICIAL', 20262 , 'Periodo Lectivo 2026'),
  ('5 AÑOS', 'INICIAL', 20262 , 'Periodo Lectivo 2026'),
  ('1° GRADO', 'PRIMARIA', 20262 , 'Periodo Lectivo 2026'),
  ('2° GRADO', 'PRIMARIA', 20262 , 'Periodo Lectivo 2026'),
  ('3° GRADO', 'PRIMARIA', 20262 , 'Periodo Lectivo 2026'),
  ('4° GRADO', 'PRIMARIA', 20262 , 'Periodo Lectivo 2026'),
  ('5° GRADO', 'PRIMARIA', 20262 , 'Periodo Lectivo 2026'),
  ('6° GRADO', 'PRIMARIA', 20262 , 'Periodo Lectivo 2026'),
  ('1° AÑO', 'SECUNDARIA', 20262 , 'Periodo Lectivo 2026'),
  ('2° AÑO', 'SECUNDARIA', 20262 , 'Periodo Lectivo 2026'),
  ('3° AÑO', 'SECUNDARIA', 20262 , 'Periodo Lectivo 2026'),
  ('4° AÑO', 'SECUNDARIA', 20262 , 'Periodo Lectivo 2026'),
  ('5° AÑO', 'SECUNDARIA', 20262 , 'Periodo Lectivo 2026');


-- idGrado     cGrado      IdNivel     cNivel    
-- ----------  ----------  ----------  ----------
INSERT INTO Sync_GradoNivel
  (idGrado, cGrado, idNivel, cNivel)
VALUES
  (1, '3 AÑOS', 1, 'INICIAL'),
  (2, '4 AÑOS', 1, 'INICIAL'),
  (3, '5 AÑOS', 1, 'INICIAL'),
  (4, '1° GRADO', 2, 'PRIMARIA'),
  (5, '2° GRADO', 2, 'PRIMARIA'),
  (6, '3° GRADO', 2, 'PRIMARIA'),
  (7, '4° GRADO', 2, 'PRIMARIA'),
  (8, '5° GRADO', 2, 'PRIMARIA'),
  (9, '6° GRADO', 2, 'PRIMARIA'),
  (10, '1° AÑO', 3, 'SECUNDARIA'),
  (11, '2° AÑO', 3, 'SECUNDARIA'),
  (12, '3° AÑO', 3, 'SECUNDARIA'),
  (13, '4° AÑO', 3, 'SECUNDARIA'),
  (14, '5° AÑO', 3, 'SECUNDARIA');


INSERT INTO Sync_CursoSeccionPreUniversitaria
  (
  idPeriodoLectivo, periodoLectivo, idTemporada, temporada, nivel, idNivel, idCentroEstudios, centroEstudios, idAreaAcademica, areaAcademica, idAreaCurricular, areaCurricular, idCursoPreUniversitario, cursoPreUniversitario
  )
VALUES
  (20261, 'Periodo 2026', 3, 'Temporada 2026-1', 'PRE-UNIVERSITARIO', 4, 101, 'UNCP', 201, 'Ciencias Sociales', 301, 'Historia', 401, 'Historia del Perú'),
  (20261, 'Periodo 2026', 3, 'Temporada 2026-1', 'PRE-UNIVERSITARIO', 4, 101, 'UNCP', 201, 'Ciencias Sociales', 301, 'Geografía', 402, 'Geografía del Mundo'),
  (20261, 'Periodo 2026', 3, 'Temporada 2026-1', 'PRE-UNIVERSITARIO', 4, 101, 'UNCP', 202, 'Ciencias Naturales', 302, 'Biología', 403, 'Biología General'),
  (20261, 'Periodo 2026', 3, 'Temporada 2026-1', 'PRE-UNIVERSITARIO', 4, 101, 'UNCP', 202, 'Ciencias Naturales', 302, 'Química', 404, 'Química General'),
  (20261, 'Periodo 2026', 3, 'Temporada  2026-1', 'PRE-UNIVERSITARIO', 4, 101, 'UNCP', 203, 'Matemáticas', 303, 'Álgebra', 405, 'Álgebra I'),
  (20261, 'Periodo 2026', 3, 'Temporada 2026-1', 'PRE-UNIVERSITARIO', 4, 101, 'UNCP', 203, 'Matemáticas', 303, 'Geometría', 406, 'Geometría I');



-- id          cCursoEducacionBasica  cAreaCurricular  cEtapaEducativa  cNivelEducativo  idPeriodoLectivo

INSERT INTO Sync_CursoSeccionBasica
  (cCursoEducacionBasica, cAreaCurricular, cEtapaEducativa, cNivelEducativo, idPeriodoLectivo)
VALUES
  ('Geometrica', 'Matematica', '1° GRADO', 'PRIMARIA', 20251),
  ('Algebra', 'Matematica', '2° GRADO', 'PRIMARIA', 20251),
  ('Aritmetica', 'Matematica', '3° GRADO', 'PRIMARIA', 20251),
  ('Razonamiento Matematico', 'Matematica', '4° GRADO', 'PRIMARIA', 20251),
  ('Geometria', 'Matematica', '5° GRADO', 'PRIMARIA', 20251),
  ('Trigonometria', 'Matematica', '6° GRADO', 'PRIMARIA', 20251),
  ('Razonamiento Verbal', 'Comunicacion', '1° GRADO', 'PRIMARIA', 20251),
  ('Letras', 'Comunicacion', '2° GRADO', 'PRIMARIA', 20251),
  ('Lenguaje', 'Comunicacion', '3° GRADO', 'PRIMARIA', 20251),
  ('Comprension Lectora', 'Comunicacion', '4° GRADO', 'PRIMARIA', 20251),
  ('Escritura', 'Comunicacion', '5° GRADO', 'PRIMARIA', 20251),
  ('Oratoria', 'Comunicacion', '6° GRADO', 'PRIMARIA', 20251);

SELECT * FROM EstadoAsistencia

INSERT INTO EstadoAsistencia
  (cNombre, nCreatedBy)
VALUES
  ('Licencia', 1);