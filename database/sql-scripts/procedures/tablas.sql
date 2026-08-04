
USE SCAP_DB

GO

CREATE TABLE Biometrico
(
	id int IDENTITY(1,1) NOT NULL,
	marca varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	tipoBD varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Biometrico PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Controles definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Controles;

CREATE TABLE Controles
(
	Id int IDENTITY(1,1) NOT NULL,
	nTolerancia int NOT NULL,
	nLimiteFalta int NOT NULL,
	nLimiteMarcacion int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Controles PRIMARY KEY (Id)
);


-- SCAP_DB.dbo.DenominacionFeriado definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.DenominacionFeriado;

CREATE TABLE DenominacionFeriado
(
	id int IDENTITY(1,1) NOT NULL,
	codigo char(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cDenominacion varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cDescripcion varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_DenominacionFeriado PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Dia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Dia;

CREATE TABLE Dia
(
	id int IDENTITY(1,1) NOT NULL,
	cTitulo varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	orden int NULL,
	cAbreviatura varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK_Dia PRIMARY KEY (id)
);


-- SCAP_DB.dbo.EstadoAsistencia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.EstadoAsistencia;

CREATE TABLE EstadoAsistencia
(
	id int IDENTITY(1,1) NOT NULL,
	cNombre varchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt datetime DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdateAt datetime NULL,
	CONSTRAINT PK_EstadoAsistencia PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Marcacion definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Marcacion;

CREATE TABLE Marcacion
(
	id int IDENTITY(1,1) NOT NULL,
	emp_code varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	punch_time datetime NOT NULL,
	punch_state varchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	terminal_sn varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	terminal_alias varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	emp_id int NULL,
	terminal_id int NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdateAt datetime NULL,
	CONSTRAINT PK_Marcacion PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Motivo definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Motivo;

CREATE TABLE Motivo
(
	id int IDENTITY(1,1) NOT NULL,
	nombre varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	detalle varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	bDocumento bit DEFAULT 0 NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Motivo PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Sync_Anio definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_Anio;

CREATE TABLE Sync_Anio
(
	id int IDENTITY(1,1) NOT NULL,
	cDenominacion int NOT NULL,
	cDescripcion varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT PK_Sync_Anio PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Sync_ConfiguracionEtapa definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_ConfiguracionEtapa;

CREATE TABLE Sync_ConfiguracionEtapa
(
	id int IDENTITY(1,1) NOT NULL,
	cEtapaEducativa varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cNivelEducativo varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idPeriodoLectivo int NOT NULL,
	cPeriodoLectivo varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT PK__Sync_Con__3213E83FF4D637FA PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Sync_CursoSeccionBasica definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_CursoSeccionBasica;

CREATE TABLE Sync_CursoSeccionBasica
(
	id int IDENTITY(1,1) NOT NULL,
	cCursoEducacionBasica varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cAreaCurricular varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cEtapaEducativa varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cNivelEducativo varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idPeriodoLectivo int NOT NULL,
	CONSTRAINT PK__Sync_Cur__3213E83F31191959 PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Sync_CursoSeccionPreUniversitaria definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_CursoSeccionPreUniversitaria;

CREATE TABLE Sync_CursoSeccionPreUniversitaria
(
	id int IDENTITY(1,1) NOT NULL,
	idPeriodoLectivo int NOT NULL,
	periodoLectivo varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idTemporada int NOT NULL,
	temporada varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	nivel varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idNivel int NOT NULL,
	idCentroEstudios int NOT NULL,
	centroEstudios varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idAreaAcademica int NOT NULL,
	areaAcademica varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idAreaCurricular int NOT NULL,
	areaCurricular varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idCursoPreUniversitario int NOT NULL,
	cursoPreUniversitario varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT UK_Sync_CursoSeccionPreUniversitaria UNIQUE (id)
);


-- SCAP_DB.dbo.Sync_GradoNivel definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_GradoNivel;

CREATE TABLE Sync_GradoNivel
(
	idGrado char(3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cGrado varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	IdNivel char(4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cNivel varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT PK_Sync_GradoNivel PRIMARY KEY (idGrado)
);


-- SCAP_DB.dbo.Sync_Temporada definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_Temporada;

CREATE TABLE Sync_Temporada
(
	idTemporada int NOT NULL,
	cTemporada varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	idPeriodoLectivo int NOT NULL,
	cPeriodoLectivo varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT PK_Sync_Temporada PRIMARY KEY (idTemporada)
);


-- SCAP_DB.dbo.Sync_Unidad definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_Unidad;

CREATE TABLE Sync_Unidad
(
	id char(3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cTitulo varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT PK_Sync_Unidad PRIMARY KEY (id)
);


-- SCAP_DB.dbo.Sync_Usuario definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Sync_Usuario;

CREATE TABLE Sync_Usuario
(
	id int NOT NULL,
	cUsuario varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cNombre varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cApellido varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cTipo char(2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cDni varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK_Sync_Usuario PRIMARY KEY (id)
);


-- SCAP_DB.dbo.DetalleBiometrico definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.DetalleBiometrico;

CREATE TABLE DetalleBiometrico
(
	id int IDENTITY(1,1) NOT NULL,
	biometricoId_fk int NOT NULL,
	cNombre varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ip char(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	serie varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ubicacion varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	bTarjeta bit DEFAULT 0 NOT NULL,
	bHuella bit DEFAULT 0 NOT NULL,
	bRostro bit DEFAULT 0 NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_DetalleBiometrico PRIMARY KEY (id),
	CONSTRAINT Fk_Biometrico_detalleBiometrico FOREIGN KEY (biometricoId_fk) REFERENCES Biometrico(id)
);


-- SCAP_DB.dbo.FechaFeriado definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.FechaFeriado;

CREATE TABLE FechaFeriado
(
	id int IDENTITY(1,1) NOT NULL,
	denominacionFeriadoId_fk int NOT NULL,
	anioId_fk int NOT NULL,
	fecha date NOT NULL,
	bEliminado bit DEFAULT 0 NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	CONSTRAINT PK_fechaFeriado PRIMARY KEY (id),
	CONSTRAINT FK_FechaFeriado_anio FOREIGN KEY (anioId_fk) REFERENCES Sync_Anio(id),
	CONSTRAINT FK_FechaFeriado_denominacionFeriado FOREIGN KEY (denominacionFeriadoId_fk) REFERENCES DenominacionFeriado(id)
);


-- SCAP_DB.dbo.Horario definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Horario;

CREATE TABLE Horario
(
	id int IDENTITY(1,1) NOT NULL,
	cTitulo varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	horaDia varchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	bGeneral bit DEFAULT 0 NOT NULL,
	bExtendido bit DEFAULT 0 NOT NULL,
	bRotativo bit DEFAULT 0 NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	idTemporada int NULL,
	bRegular bit NULL,
	CONSTRAINT PK_Horario PRIMARY KEY (id),
	CONSTRAINT FK_Horario_Sync_Temporada FOREIGN KEY (idTemporada) REFERENCES Sync_Temporada(idTemporada)
);


-- SCAP_DB.dbo.HorarioDias definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.HorarioDias;

CREATE TABLE HorarioDias
(
	id int IDENTITY(1,1) NOT NULL,
	horarioId_fk int NOT NULL,
	diaId_fk int NOT NULL,
	bLibre bit DEFAULT 0 NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	CONSTRAINT PK_HorarioDias PRIMARY KEY (id),
	CONSTRAINT FK_Dia_horarioDias FOREIGN KEY (diaId_fk) REFERENCES Dia(id),
	CONSTRAINT FK_horario_horarioDias FOREIGN KEY (horarioId_fk) REFERENCES Horario(id)
);


-- SCAP_DB.dbo.TurnoExtendido definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.TurnoExtendido;

CREATE TABLE TurnoExtendido
(
	id int IDENTITY(1,1) NOT NULL,
	horarioDiasId_fk int NOT NULL,
	horaInicio time NOT NULL,
	horaFin time NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_TurnoExtendido PRIMARY KEY (id),
	CONSTRAINT FK_TurnoeExtendido_HorarioDias FOREIGN KEY (horarioDiasId_fk) REFERENCES HorarioDias(id)
);


-- SCAP_DB.dbo.TurnoRegular definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.TurnoRegular;

CREATE TABLE TurnoRegular
(
	id int IDENTITY(1,1) NOT NULL,
	horarioDiasId_fk int NOT NULL,
	orden int NOT NULL,
	horaInicio time NOT NULL,
	bTipo bit DEFAULT 0 NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_TurnoRegular PRIMARY KEY (id),
	CONSTRAINT FK_HorarioDias_TurnoRegular FOREIGN KEY (horarioDiasId_fk) REFERENCES HorarioDias(id)
);


-- SCAP_DB.dbo.Unidad definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Unidad;

CREATE TABLE Unidad
(
	id int IDENTITY(1,1) NOT NULL,
	unidadOrgId_fk char(3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	horaEstandar int NOT NULL,
	horaTotal int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Unidad PRIMARY KEY (id),
	CONSTRAINT FK_Unidad_Unidad FOREIGN KEY (unidadOrgId_fk) REFERENCES Sync_Unidad(id)
);


-- SCAP_DB.dbo.UnidadFeriado definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.UnidadFeriado;

CREATE TABLE UnidadFeriado
(
	unidadId_pk int NOT NULL,
	fechaFeriadoId_pk int NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	CONSTRAINT PK_UnidadFeriado PRIMARY KEY (unidadId_pk,fechaFeriadoId_pk),
	CONSTRAINT FK_UnidadFeriado_FechaFeriado FOREIGN KEY (fechaFeriadoId_pk) REFERENCES FechaFeriado(id),
	CONSTRAINT FK_UnidadFeriado_Unidad FOREIGN KEY (unidadId_pk) REFERENCES Unidad(id)
);


-- SCAP_DB.dbo.Vigencia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Vigencia;

CREATE TABLE Vigencia
(
	id int IDENTITY(1,1) NOT NULL,
	horarioDiasId_fk int NOT NULL,
	tFechaInicio date NOT NULL,
	tFechaFin date NOT NULL,
	bActivo bit DEFAULT 1 NOT NULL,
	bTipo bit NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT Vigencia_HorarioDias FOREIGN KEY (horarioDiasId_fk) REFERENCES HorarioDias(id)
);


-- SCAP_DB.dbo.ConectadoDias definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.ConectadoDias;

CREATE TABLE ConectadoDias
(
	turnoExtendidoId_pk int NOT NULL,
	diasId_pk int NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date NOT NULL,
	CONSTRAINT PK_ConectadoDias PRIMARY KEY (turnoExtendidoId_pk,diasId_pk),
	CONSTRAINT FK_ConectadoDias_TurnoExtendido FOREIGN KEY (turnoExtendidoId_pk) REFERENCES TurnoExtendido(id),
	CONSTRAINT FK_ConectadoDiasa_dia FOREIGN KEY (diasId_pk) REFERENCES Dia(id)
);


-- SCAP_DB.dbo.ControlUnidad definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.ControlUnidad;

CREATE TABLE ControlUnidad
(
	id int IDENTITY(1,1) NOT NULL,
	controlId_fk int NOT NULL,
	unidadId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	CONSTRAINT PK_ControlUnidad PRIMARY KEY (id),
	CONSTRAINT FK_ControlUnidad_Controles FOREIGN KEY (controlId_fk) REFERENCES Controles(Id),
	CONSTRAINT FK_ControlUnidad_Unidad FOREIGN KEY (unidadId_fk) REFERENCES Unidad(id)
);

CREATE TABLE Rol
(
	id int IDENTITY(1,1) NOT NULL,
	unidadId_fk int NOT NULL,
	cTitulo varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cDescripcion varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	bSupervision bit DEFAULT 0 NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Rol PRIMARY KEY (id),
	CONSTRAINT FK_Rol_Unidad FOREIGN KEY (unidadId_fk) REFERENCES Unidad(id)
);


CREATE TABLE RolUsuario
(
	id int IDENTITY(1,1) NOT NULL,
	usuarioId_fk int NOT NULL,
	rolId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_RolUsuario PRIMARY KEY (id),
	CONSTRAINT FK_RolUsuario_Rol FOREIGN KEY (rolId_fk) REFERENCES Rol(id),
	CONSTRAINT FK_RolUsuario_Usuario FOREIGN KEY (usuarioId_fk) REFERENCES Sync_Usuario(id)
);

CREATE TABLE CursoSeccionBasica_TurnoRegular
(
	id int IDENTITY(1,1) NOT NULL,
	syncCursoSeccionId int NOT NULL,
	turnoRegularEntradaId int NOT NULL,
	turnoRegularSalidaId int NOT NULL,
 rolUsuarioId int NULL,
	bEliminado bit DEFAULT 0 NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt datetime DEFAULT getdate() NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	CONSTRAINT PK_CursoSeccionBasica_TurnoRegular PRIMARY KEY (id),
	CONSTRAINT FK_SyncCursoSeccionBasica_TurnoRegular FOREIGN KEY (syncCursoSeccionId) REFERENCES Sync_CursoSeccionBasica(id),
	CONSTRAINT FK_TurnoRegularEntrada_CursoSeccionBasica FOREIGN KEY (turnoRegularEntradaId) REFERENCES TurnoRegular(id),
	CONSTRAINT FK_TurnoRegularSalida_CursoSeccionBasica FOREIGN KEY (turnoRegularSalidaId) REFERENCES TurnoRegular(id),
 CONSTRAINT FK_RolUsuario_CursoSeccionBasica FOREIGN KEY (rolUsuarioId) REFERENCES RolUsuario(id),
);


-- SCAP_DB.dbo.CursoSeccionPreUniversitaria_TurnoRegular definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.CursoSeccionPreUniversitaria_TurnoRegular;



-- SCAP_DB.dbo.Rol definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Rol;







-- SCAP_DB.dbo.RolControl definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.RolControl;

CREATE TABLE RolControl
(
	Id int IDENTITY(1,1) NOT NULL,
	rolId_fk int NOT NULL,
	controlId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedby int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	CONSTRAINT PK_RolControl PRIMARY KEY (Id),
	CONSTRAINT FK_RolControl_Controles FOREIGN KEY (controlId_fk) REFERENCES Controles(Id),
	CONSTRAINT FK_RolControl_Rol FOREIGN KEY (rolId_fk) REFERENCES Rol(id)
);

CREATE TABLE CursoSeccionPreUniversitaria_TurnoRegular
(
	id int IDENTITY(1,1) NOT NULL,
	syncCursoSeccionPreUniversitariaId int NOT NULL,
	turnoRegularEntradaId int NOT NULL,
	turnoRegularSalidaId int NOT NULL,
 rolUsuarioId int NULL,
	bEliminado bit DEFAULT 0 NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt datetime DEFAULT getdate() NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	CONSTRAINT PK_CursoSeccionPreUniversitaria_TurnoRegular PRIMARY KEY (id),
	CONSTRAINT FK_SyncCursoSeccionPreUniversitaria_TurnoRegular FOREIGN KEY (syncCursoSeccionPreUniversitariaId) REFERENCES Sync_CursoSeccionPreUniversitaria(id),
	CONSTRAINT FK_TurnoRegularEntrada_CursoSeccionPreUniversitaria FOREIGN KEY (turnoRegularEntradaId) REFERENCES TurnoRegular(id),
	CONSTRAINT FK_TurnoRegularSalida_CursoSeccionPreUniversitaria FOREIGN KEY (turnoRegularSalidaId) REFERENCES TurnoRegular(id),
 CONSTRAINT FK_RolUsuario_CursoSeccionPreUniversitaria_TurnoRegular FOREIGN KEY (rolUsuarioId) REFERENCES RolUsuario(id)
);



-- SCAP_DB.dbo.Supervisor definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Supervisor;
CREATE TABLE Supervisor
(
	usuarioId_pk int NOT NULL,
	unidadId_pk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Supervisor PRIMARY KEY (unidadId_pk,usuarioId_pk),
	CONSTRAINT FK_Supervisor_Unidad FOREIGN KEY (unidadId_pk) REFERENCES Unidad(id),
	CONSTRAINT FK_Supervisor_Usuario FOREIGN KEY (usuarioId_pk) REFERENCES Sync_Usuario(id)
);


-- SCAP_DB.dbo.TurnoModificado definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.TurnoModificado;
CREATE TABLE TurnoModificado
(
	id int IDENTITY(1,1) NOT NULL,
	rolUsuarioId_fk int NULL,
	turnoRegularId_fk int NOT NULL,
	tHora time NOT NULL,
	btipo bit NOT NULL,
	fechaInicio date NOT NULL,
	fechaFin date NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_TurnoModificado PRIMARY KEY (id),
	CONSTRAINT FK_TurnoModificado_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id),
	CONSTRAINT FK_TurnoModificado_turnoRegular FOREIGN KEY (turnoRegularId_fk) REFERENCES TurnoRegular(id)
);


-- SCAP_DB.dbo.Asistencia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Asistencia;
CREATE TABLE Asistencia
(
	id int IDENTITY(1,1) NOT NULL,
	tFecha datetime NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	horaEntrada datetime NOT NULL,
	horaSalida datetime NOT NULL,
	rolUsuarioid_fk int NULL,
	vigenciaInicio date NULL,
	vigenciaFin date NULL,
	tipoAsistencia varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	turnoEntradaid int NULL,
	turnoSalidaid int NULL,
	esRegular bit DEFAULT 1 NOT NULL,
	CONSTRAINT PK_Asistencia PRIMARY KEY (id),
	CONSTRAINT FK_Asistencia_RolUsuario FOREIGN KEY (rolUsuarioid_fk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.AsistenciaExtendida definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.AsistenciaExtendida;
CREATE TABLE AsistenciaExtendida
(
	id int IDENTITY(1,1) NOT NULL,
	turnoExtendidoId_fk int NOT NULL,
	asistenciaId_fk int NOT NULL,
	detalleBiometricoId_fk int NOT NULL,
	marcacionId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdateAt datetime NULL,
	CONSTRAINT PK_AsistenciaExtendida PRIMARY KEY (id),
	CONSTRAINT FK_AsistenciaExtendida_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id),
	CONSTRAINT FK_AsistenciaExtendida_DetalleBiometrico FOREIGN KEY (detalleBiometricoId_fk) REFERENCES DetalleBiometrico(id),
	CONSTRAINT FK_AsistenciaExtendida_Marcacion FOREIGN KEY (marcacionId_fk) REFERENCES Marcacion(id),
	CONSTRAINT FK_AsistenciaExtendida_TurnoExtendido FOREIGN KEY (turnoExtendidoId_fk) REFERENCES TurnoExtendido(id)
);


-- SCAP_DB.dbo.AsistenciaModificada definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.AsistenciaModificada;

CREATE TABLE AsistenciaModificada
(
	id int IDENTITY(1,1) NOT NULL,
	detalleBiometricoId_fk int NOT NULL,
	turnoModificadoId_fk int NOT NULL,
	asistenciaId_fk int NOT NULL,
	marcacionId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_AsistenciaModificada PRIMARY KEY (id),
	CONSTRAINT FK_AsistenciaModificada_asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id),
	CONSTRAINT FK_AsistenciaModificada_detalleBiometrico FOREIGN KEY (detalleBiometricoId_fk) REFERENCES DetalleBiometrico(id),
	CONSTRAINT FK_marcacion_AsistenciaModificada FOREIGN KEY (marcacionId_fk) REFERENCES Marcacion(id)
);


-- SCAP_DB.dbo.AsistenciaRegular definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.AsistenciaRegular;

CREATE TABLE AsistenciaRegular
(
	id int IDENTITY(1,1) NOT NULL,
	turnoRegularId_fk int NOT NULL,
	asistenciaId_fk int NOT NULL,
	marcacionId_fk int NOT NULL,
	detalleBiometricoId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdateAt datetime NULL,
	CONSTRAINT PK_AsistenciaRegular PRIMARY KEY (id),
	CONSTRAINT FK_AsistenciaRegular_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id),
	CONSTRAINT FK_AsistenciaRegular_DetalleBiometrico FOREIGN KEY (detalleBiometricoId_fk) REFERENCES DetalleBiometrico(id),
	CONSTRAINT FK_AsistenciaRegular_Marcacion FOREIGN KEY (marcacionId_fk) REFERENCES Marcacion(id),
	CONSTRAINT FK_AsistenciaRegular_TurnoRegular FOREIGN KEY (turnoRegularId_fk) REFERENCES TurnoRegular(id)
);


-- SCAP_DB.dbo.ControlRolUsuario definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.ControlRolUsuario;

CREATE TABLE ControlRolUsuario
(
	id int IDENTITY(1,1) NOT NULL,
	controlId_fk int NOT NULL,
	rolUsuarioId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	CONSTRAINT PK_ControlRolUsuario PRIMARY KEY (id),
	CONSTRAINT FK_ControlRolUsuario_Controles FOREIGN KEY (controlId_fk) REFERENCES Controles(Id),
	CONSTRAINT FK_ControlRolUsuario_RolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.ControlRolUsuarioAsistencia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.ControlRolUsuarioAsistencia;

CREATE TABLE ControlRolUsuarioAsistencia
(
	id int IDENTITY(1,1) NOT NULL,
	controlRolUsuarioId_fk int NOT NULL,
	asistenciaId_fk int NOT NULL,
	estadoAsistenciaId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt datetime DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	marcacionEntrada datetime NULL,
	marcacionSalida datetime NULL,
	estadoEntrada varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	estadoSalida varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	nMinutosTarde int DEFAULT 0 NULL,
	CONSTRAINT PK_ControlRolUsuarioAsistencia PRIMARY KEY (id),
	CONSTRAINT FK_ControlRolUsuarioAsistencia_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id),
	CONSTRAINT FK_ControlRolUsuarioAsistencia_ControlRolUsuario FOREIGN KEY (controlRolUsuarioId_fk) REFERENCES ControlRolUsuario(id),
	CONSTRAINT FK_ControlRolUsuarioAsistencia_EstadoAsistencia FOREIGN KEY (estadoAsistenciaId_fk) REFERENCES EstadoAsistencia(id)
);


-- SCAP_DB.dbo.ControlUnidadAsistencia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.ControlUnidadAsistencia;

CREATE TABLE ControlUnidadAsistencia
(
	id int IDENTITY(1,1) NOT NULL,
	controlUnidadId_fk int NOT NULL,
	asistenciaId_fk int NOT NULL,
	estadoAsistenciaId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt datetime DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	marcacionEntrada datetime NULL,
	marcacionSalida datetime NULL,
	estadoEntrada varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	estadoSalida varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	nMinutosTarde int DEFAULT 0 NULL,
	CONSTRAINT PK_ControlUnidadAsistencia PRIMARY KEY (id),
	CONSTRAINT FK_ControlUnidadAsistencia_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id),
	CONSTRAINT FK_ControlUnidadAsistencia_ControlUnidad FOREIGN KEY (controlUnidadId_fk) REFERENCES ControlUnidad(id),
	CONSTRAINT FK_ControlUnidadAsistencia_EstadoAsistencia FOREIGN KEY (estadoAsistenciaId_fk) REFERENCES EstadoAsistencia(id)
);


-- SCAP_DB.dbo.ControlVacaciones definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.ControlVacaciones;

CREATE TABLE ControlVacaciones
(
	id int IDENTITY(1,1) NOT NULL,
	rolUsuarioId_fk int NOT NULL,
	nDiasDisponibles int NOT NULL,
	nDiasTomados int NOT NULL,
	bAprobado bit DEFAULT 0 NOT NULL,
	nAprobadoBy int NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt datetime DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdateAt datetime NULL,
	bActivo bit DEFAULT 1 NOT NULL,
	CONSTRAINT PK_ControlVacaciones PRIMARY KEY (id),
	CONSTRAINT FK_ControlVacaciones_RolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.GradoSupervisado definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.GradoSupervisado;

CREATE TABLE GradoSupervisado
(
	idGrado_pk char(3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	rolUsuarioId_pk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	CONSTRAINT PK_GradoSupervisado PRIMARY KEY (idGrado_pk,rolUsuarioId_pk),
	CONSTRAINT FK_GradoSupervisado_SyncGradoNivel FOREIGN KEY (idGrado_pk) REFERENCES Sync_GradoNivel(idGrado),
	CONSTRAINT FK_GradoSupervisado_rolUsuario FOREIGN KEY (rolUsuarioId_pk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.HorarioUsuario definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.HorarioUsuario;

CREATE TABLE HorarioUsuario
(
	id int IDENTITY(1,1) NOT NULL,
	horarioId_fk int NOT NULL,
	rolUsuarioId_fk int NOT NULL,
	tfechaInicio date NOT NULL,
	tFechaFin date NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_HorarioUsuario PRIMARY KEY (id),
	CONSTRAINT FK_horarioUsuario_Horario FOREIGN KEY (horarioId_fk) REFERENCES Horario(id),
	CONSTRAINT FK_horarioUsuario_RolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.Justificacion definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Justificacion;

CREATE TABLE Justificacion
(
	id int IDENTITY(1,1) NOT NULL,
	fecha date NOT NULL,
	motivoId_fk int NOT NULL,
	rolUsuarioId_fk int NOT NULL,
	cDetalle varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Justificacion PRIMARY KEY (id),
	CONSTRAINT FK_Justificacion_motivo FOREIGN KEY (motivoId_fk) REFERENCES Motivo(id),
	CONSTRAINT FK_Justificacion_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.JustificacionTurnoExtendido definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.JustificacionTurnoExtendido;

CREATE TABLE JustificacionTurnoExtendido
(
	id int IDENTITY(1,1) NOT NULL,
	justificacionId_fk int NOT NULL,
	turnoExtendidoId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_JustificacionTurnoExtendido PRIMARY KEY (id),
	CONSTRAINT FK_JustificacionTurnoExtendido_Justificacion FOREIGN KEY (justificacionId_fk) REFERENCES Justificacion(id),
	CONSTRAINT FK_JustificacionTurnoExtendido_turnoExtendidoId FOREIGN KEY (turnoExtendidoId_fk) REFERENCES TurnoExtendido(id)
);


-- SCAP_DB.dbo.JustificacionTurnoRegular definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.JustificacionTurnoRegular;

CREATE TABLE JustificacionTurnoRegular
(
	id int IDENTITY(1,1) NOT NULL,
	justificacionId_fk int NOT NULL,
	turnoRegularId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_JustificacionTurnoRegular PRIMARY KEY (id),
	CONSTRAINT FK_JustificacionTurnoRegular_justificacion FOREIGN KEY (justificacionId_fk) REFERENCES Justificacion(id),
	CONSTRAINT FK_JustificacionTurnoRegular_turnoRegular FOREIGN KEY (turnoRegularId_fk) REFERENCES TurnoRegular(id)
);


-- SCAP_DB.dbo.Licencia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Licencia;

CREATE TABLE Licencia
(
	id int IDENTITY(1,1) NOT NULL,
	rolUsuarioId_fk int NOT NULL,
	motivoId_fk int NOT NULL,
	titulo varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	detalle varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	tFechaInicio date NOT NULL,
	tFechaFin date NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Licencia PRIMARY KEY (id),
	CONSTRAINT FK_Licencia_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id),
	CONSTRAINT FK_Motivo_Licencia FOREIGN KEY (motivoId_fk) REFERENCES Motivo(id)
);


-- SCAP_DB.dbo.PeriodoVacacional definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.PeriodoVacacional;

CREATE TABLE PeriodoVacacional
(
	id int IDENTITY(1,1) NOT NULL,
	controlVacacionalId_fk int NOT NULL,
	fechaInicio date NOT NULL,
	fechaFin date NOT NULL,
	nDiasConsumidos int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdateAt datetime NULL,
	CONSTRAINT PK_PeriodoVacacional PRIMARY KEY (id),
	CONSTRAINT FK_PeriodoVacacional_ControlVacaciones FOREIGN KEY (controlVacacionalId_fk) REFERENCES ControlVacaciones(id)
);


-- SCAP_DB.dbo.Permiso definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Permiso;

CREATE TABLE Permiso
(
	id int IDENTITY(1,1) NOT NULL,
	rolUsuarioId_fk int NOT NULL,
	motivoId_fk int NOT NULL,
	tfecha date NOT NULL,
	tHoraSalida time NOT NULL,
	tHoraRetornoEstimado time NOT NULL,
	tHoraRetornoReal time NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Permiso PRIMARY KEY (id),
	CONSTRAINT FK_Motivo_Permiso FOREIGN KEY (motivoId_fk) REFERENCES Motivo(id),
	CONSTRAINT FK_Permiso_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.PermisoTurnoExtendido definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.PermisoTurnoExtendido;

CREATE TABLE PermisoTurnoExtendido
(
	permisoId_pk int NOT NULL,
	turnoExtendidoId_pk int NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	CONSTRAINT PK_PermisoTurnoExtendido PRIMARY KEY (turnoExtendidoId_pk,permisoId_pk),
	CONSTRAINT FK_Permiso_PermistoTExtendido FOREIGN KEY (permisoId_pk) REFERENCES Permiso(id),
	CONSTRAINT FK_turnoExtendido_PermisoTExtendido FOREIGN KEY (turnoExtendidoId_pk) REFERENCES TurnoExtendido(id)
);


-- SCAP_DB.dbo.PermisoTurnoRegular definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.PermisoTurnoRegular;

CREATE TABLE PermisoTurnoRegular
(
	permisoId_pk int NOT NULL,
	turnoRegularId_pk int NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	CONSTRAINT PK_PermisoTurnoRegular PRIMARY KEY (turnoRegularId_pk,permisoId_pk),
	CONSTRAINT FK_Permiso_PermistoTRegular FOREIGN KEY (permisoId_pk) REFERENCES Permiso(id),
	CONSTRAINT FK_turnoRegular_PermisoTRegular FOREIGN KEY (turnoRegularId_pk) REFERENCES TurnoRegular(id)
);


-- SCAP_DB.dbo.Retirado definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Retirado;

CREATE TABLE Retirado
(
	id int IDENTITY(1,1) NOT NULL,
	rolUsuarioid_fk int NOT NULL,
	motivo varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	CONSTRAINT PK_Retirado PRIMARY KEY (id),
	CONSTRAINT FK_Retirado_RolUsuario FOREIGN KEY (rolUsuarioid_fk) REFERENCES RolUsuario(id)
);


-- SCAP_DB.dbo.RolControlAsistencia definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.RolControlAsistencia;

CREATE TABLE RolControlAsistencia
(
	id int IDENTITY(1,1) NOT NULL,
	rolControlId_fk int NOT NULL,
	asistenciaId_fk int NOT NULL,
	estadoAsistenciaId_fk int NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt datetime DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt datetime NULL,
	marcacionEntrada datetime NULL,
	marcacionSalida datetime NULL,
	estadoEntrada varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	estadoSalida varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	nMinutosTarde int DEFAULT 0 NULL,
	CONSTRAINT PK_RolControlAsistencia PRIMARY KEY (id),
	CONSTRAINT FK_RolControlAsistencia_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id),
	CONSTRAINT FK_RolControlAsistencia_EstadoAsistencia FOREIGN KEY (estadoAsistenciaId_fk) REFERENCES EstadoAsistencia(id),
	CONSTRAINT FK_RolControlAsistencia_RolControl FOREIGN KEY (rolControlId_fk) REFERENCES RolControl(Id)
);


-- SCAP_DB.dbo.Cita definition
-- Drop table
-- DROP TABLE SCAP_DB.dbo.Cita;

CREATE TABLE Cita
(
	id int IDENTITY(1,1) NOT NULL,
	horarioUsuarioId_fk int NOT NULL,
	nombre varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cDescripcion varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	fecha date NOT NULL,
	hora time NOT NULL,
	bCancelado bit DEFAULT 0 NOT NULL,
	bEliminado bit DEFAULT 0 NOT NULL,
	nCreatedBy int NOT NULL,
	tCreatedAt date DEFAULT getdate() NOT NULL,
	nUpdatedBy int NULL,
	tUpdatedAt date NULL,
	marcacion datetime NULL,
	horaMarcacion time NULL,
	CONSTRAINT PK_Cita PRIMARY KEY (id),
	CONSTRAINT FK_Cita_horarioUsuarioId FOREIGN KEY (horarioUsuarioId_fk) REFERENCES HorarioUsuario(id)
);

CREATE TYPE HorarioUsuarioTableType AS TABLE
(
  HorarioId INT,
  RolUsuarioId INT
);
