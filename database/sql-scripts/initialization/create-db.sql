USE master;
go

IF NOT EXISTS (SELECT *
FROM sys.databases
WHERE name = 'API_SCAP_DB')
BEGIN
    CREATE DATABASE API_SCAP_DB;
    PRINT 'Base de datos API_SCAP_DB creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos API_SCAP_DB ya existe.';
END
GO

USE API_SCAP_DB


GO

-- Biometrico definition
-- Drop table
-- DROP TABLE Biometrico;
CREATE TABLE Biometrico
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    marca VARCHAR(100) NOT NULL
    ,
    tipoBD VARCHAR(50) NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Biometrico PRIMARY KEY (id)
);

-- CONTROL definition
-- Drop table
-- DROP TABLE CONTROL;
CREATE TABLE Controles
(
    Id INT IDENTITY(1, 1) NOT NULL
    ,
    nTolerancia INT NOT NULL
    ,
    nLimiteFalta INT NOT NULL
    ,
    nLimiteMarcacion INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Controles PRIMARY KEY (Id)
);

-- DenominacionFeriado definition
-- Drop table
-- DROP TABLE DenominacionFeriado;
CREATE TABLE DenominacionFeriado
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    codigo CHAR(1) NOT NULL
    ,
    cDenominacion VARCHAR(250) NOT NULL
    ,
    cDescripcion VARCHAR(250) NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_DenominacionFeriado PRIMARY KEY (id)
);

-- Dia definition
-- Drop table
-- DROP TABLE Dia;
CREATE TABLE Dia
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    cTitulo VARCHAR(50) NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    orden INT NULL
    ,
    cAbreviatura VARCHAR(20) NULL
    ,
    CONSTRAINT PK_Dia PRIMARY KEY (id)
);

-- EstadoAsistencia definition
-- Drop table
-- DROP TABLE EstadoAsistencia;
CREATE TABLE EstadoAsistencia
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    cNombre VARCHAR(40) NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdateAt DATETIME NULL
    ,
    CONSTRAINT PK_EstadoAsistencia PRIMARY KEY (id)
);

-- FechaLimite definition
-- Drop table
-- DROP TABLE FechaLimite;
CREATE TABLE FechaLimite
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    tfechaInicio DATE NOT NULL
    ,
    tfechaFin DATE NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_FechaLimite PRIMARY KEY (id)
);

-- Horario definition
-- Drop table
-- DROP TABLE Horario;
CREATE TABLE Horario
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    cTitulo VARCHAR(50) NOT NULL
    ,
    horaDia VARCHAR(2) NOT NULL
    ,
    bGeneral BIT DEFAULT 0 NOT NULL
    ,
    bExtendido BIT DEFAULT 0 NOT NULL
    ,
    bRotativo BIT DEFAULT 0 NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Horario PRIMARY KEY (id)
);

-- Marcacion definition
-- Drop table
-- DROP TABLE Marcacion;
CREATE TABLE Marcacion
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    emp_code VARCHAR(20) NOT NULL
    ,
    punch_time DATETIME NOT NULL
    ,
    punch_state VARCHAR(5) NOT NULL
    ,
    terminal_sn VARCHAR(20) NULL
    ,
    terminal_alias VARCHAR(20) NULL
    ,
    emp_id INT NULL
    ,
    terminal_id INT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdateAt DATETIME NULL
    ,
    CONSTRAINT PK_Marcacion PRIMARY KEY (id)
);

-- Motivo definition
-- Drop table
-- DROP TABLE Motivo;
CREATE TABLE Motivo
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    nombre VARCHAR(250) NOT NULL
    ,
    detalle VARCHAR(250) NOT NULL
    ,
    bDocumento BIT DEFAULT 0 NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Motivo PRIMARY KEY (id)
);

-- Sync_Anio definition
-- Drop table
-- DROP TABLE Sync_Anio;
CREATE TABLE Sync_Anio
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    cDenominacion INT NOT NULL
    ,
    cDescripcion VARCHAR(250) NOT NULL
    ,
    CONSTRAINT PK_Sync_Anio PRIMARY KEY (id)
);

-- Sync_CursoSeccionBasica definition
-- Drop table
-- DROP TABLE Sync_CursoSeccionBasica;


CREATE TABLE Sync_CursoSeccionBasica
(
    id INT PRIMARY KEY IDENTITY(1, 1)
    ,
    cCursoEducacionBasica VARCHAR(255) NOT NULL
    ,
    cAreaCurricular VARCHAR(255) NOT NULL
    ,
    cEtapaEducativa VARCHAR(255) NOT NULL
    ,
    cNivelEducativo VARCHAR(255) NOT NULL
    ,
    idPeriodoLectivo INT NOT NULL
)

CREATE TABLE Sync_ConfiguracionEtapa
(
    id INT PRIMARY KEY IDENTITY(1, 1)
    ,
    cEtapaEducativa VARCHAR(255) NOT NULL
    ,
    cNivelEducativo VARCHAR(255) NOT NULL
    ,
    idPeriodoLectivo INT NOT NULL
    ,
    cPeriodoLectivo VARCHAR(255) NOT NULL
)



-- Sync_CursoSeccionPreUniversitaria definition
-- Drop table
-- DROP TABLE Sync_CursoSeccionPreUniversitaria;
CREATE TABLE Sync_CursoSeccionPreUniversitaria
(
    id INT IDENTITY(1, 1) NOT NULL,
    idPeriodoLectivo INT NOT NULL,
    periodoLectivo VARCHAR(100) NOT NULL,
    idTemporada INT NOT NULL,
    temporada VARCHAR(100) NOT NULL,
    nivel VARCHAR(100) NOT NULL,
    idNivel INT NOT NULL,
    idCentroEstudios INT NOT NULL,
    centroEstudios VARCHAR(100) NOT NULL,
    idAreaAcademica INT NOT NULL,
    areaAcademica VARCHAR(100) NOT NULL,
    idAreaCurricular INT NOT NULL,
    areaCurricular VARCHAR(100) NOT NULL,
    idCursoPreUniversitario INT NOT NULL,
    cursoPreUniversitario VARCHAR(255) NOT NULL,
    CONSTRAINT UK_Sync_CursoSeccionPreUniversitaria UNIQUE (id)
);

-- Sync_GradoNivel definition
-- Drop table
-- DROP TABLE Sync_GradoNivel;
CREATE TABLE Sync_GradoNivel
(
    idGrado CHAR(3) NOT NULL    
    ,
    cGrado VARCHAR(15) NOT NULL
    ,
    IdNivel CHAR(4) NOT NULL
    ,
    cNivel VARCHAR(20) NOT NULL
    ,
    CONSTRAINT PK_Sync_GradoNivel PRIMARY KEY (idGrado)
);

-- Sync_Unidad definition
-- Drop table
-- DROP TABLE Sync_Unidad;
CREATE TABLE Sync_Unidad
(
    id CHAR(3) NOT NULL
    ,
    cTitulo VARCHAR(255) NOT NULL
    ,
    CONSTRAINT PK_Sync_Unidad PRIMARY KEY (id)
);

-- Sync_Usuario definition
-- Drop table
-- DROP TABLE Sync_Usuario;
CREATE TABLE Sync_Usuario
(
    id INT NOT NULL
    ,
    cUsuario VARCHAR(255) NOT NULL
    ,
    cNombre VARCHAR(50) NOT NULL
    ,
    cApellido VARCHAR(50) NOT NULL
    ,
    cTipo CHAR(2) NOT NULL
    ,
    CONSTRAINT PK_Sync_Usuario PRIMARY KEY (id)
);

-- DetalleBiometrico definition
-- Drop table
-- DROP TABLE DetalleBiometrico;
CREATE TABLE DetalleBiometrico
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    biometricoId_fk INT NOT NULL
    ,
    cNombre VARCHAR(50) NOT NULL
    ,
    ip CHAR(50) NOT NULL
    ,
    serie VARCHAR(50) NOT NULL
    ,
    ubicacion VARCHAR(100) NOT NULL
    ,
    bTarjeta BIT DEFAULT 0 NOT NULL
    ,
    bHuella BIT DEFAULT 0 NOT NULL
    ,
    bRostro BIT DEFAULT 0 NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_DetalleBiometrico PRIMARY KEY (id)
    ,
    CONSTRAINT Fk_Biometrico_detalleBiometrico FOREIGN KEY (biometricoId_fk) REFERENCES Biometrico(id)
);

-- FechaFeriado definition
-- Drop table
-- DROP TABLE FechaFeriado;
CREATE TABLE FechaFeriado
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    denominacionFeriadoId_fk INT NOT NULL
    ,
    anioId_fk INT NOT NULL
    ,
    fecha DATE NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    CONSTRAINT PK_fechaFeriado PRIMARY KEY (id)
    ,
    CONSTRAINT FK_FechaFeriado_anio FOREIGN KEY (anioId_fk) REFERENCES Sync_Anio(id)
    ,
    CONSTRAINT FK_FechaFeriado_denominacionFeriado FOREIGN KEY (denominacionFeriadoId_fk) REFERENCES DenominacionFeriado(id)
);

-- HorarioDias definition
-- Drop table
-- DROP TABLE HorarioDias;
CREATE TABLE HorarioDias
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    horarioId_fk INT NOT NULL
    ,
    diaId_fk INT NOT NULL
    ,
    bLibre BIT DEFAULT 0 NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    CONSTRAINT PK_HorarioDias PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Dia_horarioDias FOREIGN KEY (diaId_fk) REFERENCES Dia(id)
    ,
    CONSTRAINT FK_horario_horarioDias FOREIGN KEY (horarioId_fk) REFERENCES Horario(id)
);

CREATE TABLE Sync_Temporada
(
    idTemporada INT NOT NULL
    ,
    cTemporada VARCHAR(100) NOT NULL
    ,
    idPeriodoLectivo INT NOT NULL
    ,
    cPeriodoLectivo VARCHAR(100) NOT NULL
    ,
    CONSTRAINT PK_Sync_Temporada PRIMARY KEY (idTemporada)
)

ALTER TABLE Horario
    ADD idTemporada INT NULL;

ALTER TABLE Horario
    ADD CONSTRAINT FK_Horario_Sync_Temporada FOREIGN KEY (idTemporada) REFERENCES Sync_Temporada(idTemporada);



-- TurnoExtendido definition
-- Drop table
-- DROP TABLE TurnoExtendido;
CREATE TABLE TurnoExtendido
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    horarioDiasId_fk INT NOT NULL
    ,
    horaInicio TIME NOT NULL
    ,
    horaFin TIME NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_TurnoExtendido PRIMARY KEY (id)
    ,
    CONSTRAINT FK_TurnoeExtendido_HorarioDias FOREIGN KEY (horarioDiasId_fk) REFERENCES HorarioDias(id)
);

-- TurnoRegular definition
-- Drop table
-- DROP TABLE TurnoRegular;
CREATE TABLE TurnoRegular
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    horarioDiasId_fk INT NOT NULL
    ,
    orden INT NOT NULL
    ,
    horaInicio TIME NOT NULL
    ,
    bTipo BIT DEFAULT 0 NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_TurnoRegular PRIMARY KEY (id)
    ,
    CONSTRAINT FK_HorarioDias_TurnoRegular FOREIGN KEY (horarioDiasId_fk) REFERENCES HorarioDias(id)
);

-- Unidad definition
-- Drop table
-- DROP TABLE Unidad;
CREATE TABLE Unidad
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    unidadOrgId_fk CHAR(3) NOT NULL
    ,
    horaEstandar INT NOT NULL
    ,
    horaTotal INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Unidad PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Unidad_Unidad FOREIGN KEY (unidadOrgId_fk) REFERENCES Sync_Unidad(id)
);

-- UnidadFeriado definition
-- Drop table
-- DROP TABLE UnidadFeriado;
CREATE TABLE UnidadFeriado
(
    unidadId_pk INT NOT NULL
    ,
    fechaFeriadoId_pk INT NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    CONSTRAINT PK_UnidadFeriado PRIMARY KEY (
        unidadId_pk
        , fechaFeriadoId_pk
        )
    ,
    CONSTRAINT FK_UnidadFeriado_FechaFeriado FOREIGN KEY (fechaFeriadoId_pk) REFERENCES FechaFeriado(id)
    ,
    CONSTRAINT FK_UnidadFeriado_Unidad FOREIGN KEY (unidadId_pk) REFERENCES Unidad(id)
);

-- Vigencia definition
-- Drop table
-- DROP TABLE Vigencia;
CREATE TABLE Vigencia
(
    id INT IDENTITY(1,1) NOT NULL,
    horarioDiasId_fk INT NOT NULL,
    tFechaInicio DATE NOT NULL,
    tFechaFin DATE NOT NULL,
    bActivo BIT DEFAULT 1 NOT NULL,
    bTipo BIT NOT NULL,
    bEliminado BIT DEFAULT 0 NOT NULL,
    nCreatedBy INT NOT NULL,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL,
    nUpdatedBy INT NULL,
    tUpdatedAt DATE NULL,
);

ALTER TABLE Vigencia
    ADD CONSTRAINT Vigencia_HorarioDias FOREIGN KEY (horarioDiasId_fk) REFERENCES HorarioDias(id);


-- ConectadoDias definition
-- Drop table
-- DROP TABLE ConectadoDias;
CREATE TABLE ConectadoDias
(
    turnoExtendidoId_pk INT NOT NULL
    ,
    diasId_pk INT NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE NOT NULL
    ,
    CONSTRAINT PK_ConectadoDias PRIMARY KEY (
        turnoExtendidoId_pk
        , diasId_pk
        )
    ,
    CONSTRAINT FK_ConectadoDias_TurnoExtendido FOREIGN KEY (turnoExtendidoId_pk) REFERENCES TurnoExtendido(id)
    ,
    CONSTRAINT FK_ConectadoDiasa_dia FOREIGN KEY (diasId_pk) REFERENCES Dia(id)
);

-- ControlUnidad definition
-- Drop table
-- DROP TABLE ControlUnidad;
CREATE TABLE ControlUnidad
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    controlId_fk INT NOT NULL
    ,
    unidadId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_ControlUnidad PRIMARY KEY (id)
    ,
    CONSTRAINT FK_ControlUnidad_Controles FOREIGN KEY (controlId_fk) REFERENCES Controles(Id)
    ,
    CONSTRAINT FK_ControlUnidad_Unidad FOREIGN KEY (unidadId_fk) REFERENCES Unidad(id)
);

CREATE TABLE CursoSeccionBasica_TurnoRegular
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    syncCursoSeccionId INT NOT NULL
    ,
    turnoRegularEntradaId INT NOT NULL
    ,
    turnoRegularSalidaId INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_CursoSeccionBasica_TurnoRegular PRIMARY KEY (id)
    ,
    CONSTRAINT FK_SyncCursoSeccionBasica_TurnoRegular FOREIGN KEY (syncCursoSeccionId) REFERENCES Sync_CursoSeccionBasica(id)
    ,
    CONSTRAINT FK_TurnoRegularEntrada_CursoSeccionBasica FOREIGN KEY (turnoRegularEntradaId) REFERENCES TurnoRegular(id)
    ,
    CONSTRAINT FK_TurnoRegularSalida_CursoSeccionBasica FOREIGN KEY (turnoRegularSalidaId) REFERENCES TurnoRegular(id)
);

-- CursoSeccionPreUniversitaria_TurnoRegular definition
-- Drop table
-- DROP TABLE CursoSeccionPreUniversitaria_TurnoRegular;
CREATE TABLE CursoSeccionPreUniversitaria_TurnoRegular
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    syncCursoSeccionPreUniversitariaId INT NOT NULL
    ,
    turnoRegularEntradaId INT NOT NULL
    ,
    turnoRegularSalidaId INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_CursoSeccionPreUniversitaria_TurnoRegular PRIMARY KEY (id)
    ,
    CONSTRAINT FK_SyncCursoSeccionPreUniversitaria_TurnoRegular FOREIGN KEY (syncCursoSeccionPreUniversitariaId) REFERENCES Sync_CursoSeccionPreUniversitaria(id)
    ,
    CONSTRAINT FK_TurnoRegularEntrada_CursoSeccionPreUniversitaria FOREIGN KEY (turnoRegularEntradaId) REFERENCES TurnoRegular(id)
    ,
    CONSTRAINT FK_TurnoRegularSalida_CursoSeccionPreUniversitaria FOREIGN KEY (turnoRegularSalidaId) REFERENCES TurnoRegular(id)
);

-- Rol definition
-- Drop table
-- DROP TABLE Rol;
CREATE TABLE Rol
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    unidadId_fk INT NOT NULL
    ,
    cTitulo VARCHAR(50) NOT NULL
    ,
    cDescripcion VARCHAR(50) NOT NULL
    ,
    bSupervision BIT DEFAULT 0 NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Rol PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Rol_Unidad FOREIGN KEY (unidadId_fk) REFERENCES Unidad(id)
);

-- RolControl definition
-- Drop table
-- DROP TABLE RolControl;
CREATE TABLE RolControl
(
    Id INT IDENTITY(1, 1) NOT NULL
    ,
    rolId_fk INT NOT NULL
    ,
    controlId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedby INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_RolControl PRIMARY KEY (Id)
    ,
    CONSTRAINT FK_RolControl_Controles FOREIGN KEY (controlId_fk) REFERENCES Controles(Id)
    ,
    CONSTRAINT FK_RolControl_Rol FOREIGN KEY (rolId_fk) REFERENCES Rol(id)
);

-- RolUsuario definition
-- Drop table
-- DROP TABLE RolUsuario;
CREATE TABLE RolUsuario
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    usuarioId_fk INT NOT NULL
    ,
    rolId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_RolUsuario PRIMARY KEY (id)
    ,
    CONSTRAINT FK_RolUsuario_Rol FOREIGN KEY (rolId_fk) REFERENCES Rol(id)
    ,
    CONSTRAINT FK_RolUsuario_Usuario FOREIGN KEY (usuarioId_fk) REFERENCES Sync_Usuario(id)
);

-- Supervisor definition
-- Drop table
-- DROP TABLE Supervisor;
CREATE TABLE Supervisor
(
    usuarioId_pk INT NOT NULL
    ,
    unidadId_pk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Supervisor PRIMARY KEY (
        unidadId_pk
        , usuarioId_pk
        )
    ,
    CONSTRAINT FK_Supervisor_Unidad FOREIGN KEY (unidadId_pk) REFERENCES Unidad(id)
    ,
    CONSTRAINT FK_Supervisor_Usuario FOREIGN KEY (usuarioId_pk) REFERENCES Sync_Usuario(id)
);

-- TurnoModificado definition
-- Drop table
-- DROP TABLE TurnoModificado;
CREATE TABLE TurnoModificado
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    rolUsuarioId_fk INT NULL
    ,
    turnoRegularId_fk INT NOT NULL
    ,
    tHora TIME NOT NULL
    ,
    btipo BIT NOT NULL
    ,
    fechaInicio DATE NOT NULL
    ,
    fechaFin DATE NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_TurnoModificado PRIMARY KEY (id)
    ,
    CONSTRAINT FK_TurnoModificado_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
    ,
    CONSTRAINT FK_TurnoModificado_turnoRegular FOREIGN KEY (turnoRegularId_fk) REFERENCES TurnoRegular(id)
);

-- Asistencia definition
-- Drop table
-- DROP TABLE Asistencia;
CREATE TABLE Asistencia
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    tFecha DATETIME NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    horaEntrada DATETIME NOT NULL
    ,
    horaSalida DATETIME NOT NULL
    ,
    rolUsuarioid_fk INT NULL
    ,
    CONSTRAINT PK_Asistencia PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Asistencia_RolUsuario FOREIGN KEY (rolUsuarioid_fk) REFERENCES RolUsuario(id)
);

-- AsistenciaExtendida definition
-- Drop table
-- DROP TABLE AsistenciaExtendida;
CREATE TABLE AsistenciaExtendida
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    turnoExtendidoId_fk INT NOT NULL
    ,
    asistenciaId_fk INT NOT NULL
    ,
    detalleBiometricoId_fk INT NOT NULL
    ,
    marcacionId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdateAt DATETIME NULL
    ,
    CONSTRAINT PK_AsistenciaExtendida PRIMARY KEY (id)
    ,
    CONSTRAINT FK_AsistenciaExtendida_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id)
    ,
    CONSTRAINT FK_AsistenciaExtendida_DetalleBiometrico FOREIGN KEY (detalleBiometricoId_fk) REFERENCES DetalleBiometrico(id)
    ,
    CONSTRAINT FK_AsistenciaExtendida_Marcacion FOREIGN KEY (marcacionId_fk) REFERENCES Marcacion(id)
    ,
    CONSTRAINT FK_AsistenciaExtendida_TurnoExtendido FOREIGN KEY (turnoExtendidoId_fk) REFERENCES TurnoExtendido(id)
);

-- AsistenciaModificada definition
-- Drop table
-- DROP TABLE AsistenciaModificada;
CREATE TABLE AsistenciaModificada
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    detalleBiometricoId_fk INT NOT NULL
    ,
    turnoModificadoId_fk INT NOT NULL
    ,
    asistenciaId_fk INT NOT NULL
    ,
    marcacionId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_AsistenciaModificada PRIMARY KEY (id)
    ,
    CONSTRAINT FK_marcacion_AsistenciaModificada FOREIGN KEY (marcacionId_fk) REFERENCES Marcacion(id)
    ,
    CONSTRAINT FK_AsistenciaModificada_asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id)
    ,
    CONSTRAINT FK_AsistenciaModificada_detalleBiometrico FOREIGN KEY (detalleBiometricoId_fk) REFERENCES DetalleBiometrico(id)
);

-- AsistenciaRegular definition
-- Drop table
-- DROP TABLE AsistenciaRegular;
CREATE TABLE AsistenciaRegular
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    turnoRegularId_fk INT NOT NULL
    ,
    asistenciaId_fk INT NOT NULL
    ,
    marcacionId_fk INT NOT NULL
    ,
    detalleBiometricoId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdateAt DATETIME NULL
    ,
    CONSTRAINT PK_AsistenciaRegular PRIMARY KEY (id)
    ,
    CONSTRAINT FK_AsistenciaRegular_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id)
    ,
    CONSTRAINT FK_AsistenciaRegular_DetalleBiometrico FOREIGN KEY (detalleBiometricoId_fk) REFERENCES DetalleBiometrico(id)
    ,
    CONSTRAINT FK_AsistenciaRegular_Marcacion FOREIGN KEY (marcacionId_fk) REFERENCES Marcacion(id)
    ,
    CONSTRAINT FK_AsistenciaRegular_TurnoRegular FOREIGN KEY (turnoRegularId_fk) REFERENCES TurnoRegular(id)
);

-- ControlRolUsuario definition
-- Drop table
-- DROP TABLE ControlRolUsuario;
CREATE TABLE ControlRolUsuario
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    controlId_fk INT NOT NULL
    ,
    rolUsuarioId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_ControlRolUsuario PRIMARY KEY (id)
    ,
    CONSTRAINT FK_ControlRolUsuario_Controles FOREIGN KEY (controlId_fk) REFERENCES Controles(Id)
    ,
    CONSTRAINT FK_ControlRolUsuario_RolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);



-- ControlRolUsuarioAsistencia definition
-- Drop table
-- DROP TABLE ControlRolUsuarioAsistencia;
CREATE TABLE ControlRolUsuarioAsistencia
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    controlRolUsuarioId_fk INT NOT NULL
    ,
    asistenciaId_fk INT NOT NULL
    ,
    estadoAsistenciaId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_ControlRolUsuarioAsistencia PRIMARY KEY (id)
    ,
    CONSTRAINT FK_ControlRolUsuarioAsistencia_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id)
    ,
    CONSTRAINT FK_ControlRolUsuarioAsistencia_ControlRolUsuario FOREIGN KEY (controlRolUsuarioId_fk) REFERENCES ControlRolUsuario(id)
    ,
    CONSTRAINT FK_ControlRolUsuarioAsistencia_EstadoAsistencia FOREIGN KEY (estadoAsistenciaId_fk) REFERENCES EstadoAsistencia(id)
);

ALTER TABLE ControlRolUsuarioAsistencia
    ADD marcacionEntrada DATETIME NULL,
        marcacionSalida DATETIME NULL,
        estadoEntrada VARCHAR(20) NULL,
        estadoSalida VARCHAR(20) NULL;

-- ControlUnidadAsistencia definition
-- Drop table
-- DROP TABLE ControlUnidadAsistencia;
CREATE TABLE ControlUnidadAsistencia
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    controlUnidadId_fk INT NOT NULL
    ,
    asistenciaId_fk INT NOT NULL
    ,
    estadoAsistenciaId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_ControlUnidadAsistencia PRIMARY KEY (id)
    ,
    CONSTRAINT FK_ControlUnidadAsistencia_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id)
    ,
    CONSTRAINT FK_ControlUnidadAsistencia_ControlUnidad FOREIGN KEY (controlUnidadId_fk) REFERENCES ControlUnidad(id)
    ,
    CONSTRAINT FK_ControlUnidadAsistencia_EstadoAsistencia FOREIGN KEY (estadoAsistenciaId_fk) REFERENCES EstadoAsistencia(id)
);

ALTER TABLE ControlUnidadAsistencia
    ADD marcacionEntrada DATETIME NULL,
        marcacionSalida DATETIME NULL,
        estadoEntrada VARCHAR(20) NULL,
        estadoSalida VARCHAR(20) NULL;


-- ControlVacaciones definition
-- Drop table
-- DROP TABLE ControlVacaciones;
CREATE TABLE ControlVacaciones
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    rolUsuarioId_fk INT NOT NULL
    ,
    nDiasDisponibles INT NOT NULL
    ,
    nDiasTomados INT NOT NULL
    ,
    bAprobado BIT DEFAULT 0 NOT NULL
    ,
    nAprobadoBy INT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdateAt DATETIME NULL
    ,
    CONSTRAINT PK_ControlVacaciones PRIMARY KEY (id)
    ,
    CONSTRAINT FK_ControlVacaciones_RolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);

-- GradoSupervisado definition
-- Drop table
-- DROP TABLE GradoSupervisado;
CREATE TABLE GradoSupervisado
(
    idGrado_pk CHAR(3) NOT NULL
    ,
    rolUsuarioId_pk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    CONSTRAINT PK_GradoSupervisado PRIMARY KEY (
        idGrado_pk
        , rolUsuarioId_pk
        )
    ,
    CONSTRAINT FK_GradoSupervisado_SyncGradoNivel FOREIGN KEY (idGrado_pk) REFERENCES Sync_GradoNivel(idGrado)
    ,
    CONSTRAINT FK_GradoSupervisado_rolUsuario FOREIGN KEY (rolUsuarioId_pk) REFERENCES RolUsuario(id)
);

-- HorarioUsuario definition
-- Drop table
-- DROP TABLE HorarioUsuario;
CREATE TABLE HorarioUsuario
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    horarioId_fk INT NOT NULL
    ,
    rolUsuarioId_fk INT NOT NULL
    ,
    tfechaInicio DATE NOT NULL
    ,
    tFechaFin DATE NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_HorarioUsuario PRIMARY KEY (id)
    ,
    CONSTRAINT FK_horarioUsuario_Horario FOREIGN KEY (horarioId_fk) REFERENCES Horario(id)
    ,
    CONSTRAINT FK_horarioUsuario_RolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);

-- Justificacion definition
-- Drop table
-- DROP TABLE Justificacion;
CREATE TABLE Justificacion
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    fecha DATE NOT NULL
    ,
    motivoId_fk INT NOT NULL
    ,
    rolUsuarioId_fk INT NOT NULL
    ,
    cDetalle VARCHAR(250) NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Justificacion PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Justificacion_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
    ,
    CONSTRAINT FK_Justificacion_motivo FOREIGN KEY (motivoId_fk) REFERENCES Motivo(id)
);

-- JustificacionTurnoExtendido definition
-- Drop table
-- DROP TABLE JustificacionTurnoExtendido;
CREATE TABLE JustificacionTurnoExtendido
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    justificacionId_fk INT NOT NULL
    ,
    turnoExtendidoId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_JustificacionTurnoExtendido PRIMARY KEY (id)
    ,
    CONSTRAINT FK_JustificacionTurnoExtendido_Justificacion FOREIGN KEY (justificacionId_fk) REFERENCES Justificacion(id)
    ,
    CONSTRAINT FK_JustificacionTurnoExtendido_turnoExtendidoId FOREIGN KEY (turnoExtendidoId_fk) REFERENCES TurnoExtendido(id)
);

-- JustificacionTurnoRegular definition
-- Drop table
-- DROP TABLE JustificacionTurnoRegular;
CREATE TABLE JustificacionTurnoRegular
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    justificacionId_fk INT NOT NULL
    ,
    turnoRegularId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_JustificacionTurnoRegular PRIMARY KEY (id)
    ,
    CONSTRAINT FK_JustificacionTurnoRegular_justificacion FOREIGN KEY (justificacionId_fk) REFERENCES Justificacion(id)
    ,
    CONSTRAINT FK_JustificacionTurnoRegular_turnoRegular FOREIGN KEY (turnoRegularId_fk) REFERENCES TurnoRegular(id)
);

-- Licencia definition
-- Drop table
-- DROP TABLE Licencia;
CREATE TABLE Licencia
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    rolUsuarioId_fk INT NOT NULL
    ,
    motivoId_fk INT NOT NULL
    ,
    titulo VARCHAR(250) NOT NULL
    ,
    detalle VARCHAR(250) NOT NULL
    ,
    tFechaInicio DATE NOT NULL
    ,
    tFechaFin DATE NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Licencia PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Licencia_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
    ,
    CONSTRAINT FK_Motivo_Licencia FOREIGN KEY (motivoId_fk) REFERENCES Motivo(id)
);

-- PeriodoVacacional definition
-- Drop table
-- DROP TABLE PeriodoVacacional;
CREATE TABLE PeriodoVacacional
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    controlVacacionalId_fk INT NOT NULL
    ,
    fechaInicio DATE NOT NULL
    ,
    fechaFin DATE NOT NULL
    ,
    nDiasConsumidos INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdateAt DATETIME NULL
    ,
    CONSTRAINT PK_PeriodoVacacional PRIMARY KEY (id)
    ,
    CONSTRAINT FK_PeriodoVacacional_ControlVacaciones FOREIGN KEY (controlVacacionalId_fk) REFERENCES ControlVacaciones(id)
);

-- Permiso definition
-- Drop table
-- DROP TABLE Permiso;
CREATE TABLE Permiso
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    rolUsuarioId_fk INT NOT NULL
    ,
    motivoId_fk INT NOT NULL
    ,
    tfecha DATE NOT NULL
    ,
    tHoraSalida TIME NOT NULL
    ,
    tHoraRetornoEstimado TIME NOT NULL
    ,
    tHoraRetornoReal TIME NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Permiso PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Motivo_Permiso FOREIGN KEY (motivoId_fk) REFERENCES Motivo(id)
    ,
    CONSTRAINT FK_Permiso_rolUsuario FOREIGN KEY (rolUsuarioId_fk) REFERENCES RolUsuario(id)
);

-- PermisoTurnoExtendido definition
-- Drop table
-- DROP TABLE PermisoTurnoExtendido;
CREATE TABLE PermisoTurnoExtendido
(
    permisoId_pk INT NOT NULL
    ,
    turnoExtendidoId_pk INT NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    CONSTRAINT PK_PermisoTurnoExtendido PRIMARY KEY (
        turnoExtendidoId_pk
        , permisoId_pk
        )
    ,
    CONSTRAINT FK_Permiso_PermistoTExtendido FOREIGN KEY (permisoId_pk) REFERENCES Permiso(id)
    ,
    CONSTRAINT FK_turnoExtendido_PermisoTExtendido FOREIGN KEY (turnoExtendidoId_pk) REFERENCES TurnoExtendido(id)
);

-- PermisoTurnoRegular definition
-- Drop table
-- DROP TABLE PermisoTurnoRegular;
CREATE TABLE PermisoTurnoRegular
(
    permisoId_pk INT NOT NULL
    ,
    turnoRegularId_pk INT NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    CONSTRAINT PK_PermisoTurnoRegular PRIMARY KEY (
        turnoRegularId_pk
        , permisoId_pk
        )
    ,
    CONSTRAINT FK_Permiso_PermistoTRegular FOREIGN KEY (permisoId_pk) REFERENCES Permiso(id)
    ,
    CONSTRAINT FK_turnoRegular_PermisoTRegular FOREIGN KEY (turnoRegularId_pk) REFERENCES TurnoRegular(id)
);

-- Retirado definition
-- Drop table
-- DROP TABLE Retirado;
CREATE TABLE Retirado
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    rolUsuarioid_fk INT NOT NULL
    ,
    motivo VARCHAR(20) NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Retirado PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Retirado_RolUsuario FOREIGN KEY (rolUsuarioid_fk) REFERENCES RolUsuario(id)
);

-- RolControlAsistencia definition
-- Drop table
-- DROP TABLE RolControlAsistencia;
CREATE TABLE RolControlAsistencia
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    rolControlId_fk INT NOT NULL
    ,
    asistenciaId_fk INT NOT NULL
    ,
    estadoAsistenciaId_fk INT NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATETIME DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATETIME NULL
    ,
    CONSTRAINT PK_RolControlAsistencia PRIMARY KEY (id)
    ,
    CONSTRAINT FK_RolControlAsistencia_Asistencia FOREIGN KEY (asistenciaId_fk) REFERENCES Asistencia(id)
    ,
    CONSTRAINT FK_RolControlAsistencia_EstadoAsistencia FOREIGN KEY (estadoAsistenciaId_fk) REFERENCES EstadoAsistencia(id)
    ,
    CONSTRAINT FK_RolControlAsistencia_RolControl FOREIGN KEY (rolControlId_fk) REFERENCES RolControl(Id)
);

ALTER TABLE RolControlAsistencia
    ADD marcacionEntrada DATETIME NULL,
        marcacionSalida DATETIME NULL,
        estadoEntrada VARCHAR(20) NULL,
        estadoSalida VARCHAR(20) NULL;


-- Cita definition
-- Drop table
-- DROP TABLE Cita;
CREATE TABLE Cita
(
    id INT IDENTITY(1, 1) NOT NULL
    ,
    horarioUsuarioId_fk INT NOT NULL
    ,
    nombre VARCHAR(250) NOT NULL
    ,
    cDescripcion VARCHAR(250) NOT NULL
    ,
    fecha DATE NOT NULL
    ,
    hora TIME NOT NULL
    ,
    bCancelado BIT DEFAULT 0 NOT NULL
    ,
    bEliminado BIT DEFAULT 0 NOT NULL
    ,
    nCreatedBy INT NOT NULL
    ,
    tCreatedAt DATE DEFAULT GETDATE() NOT NULL
    ,
    nUpdatedBy INT NULL
    ,
    tUpdatedAt DATE NULL
    ,
    CONSTRAINT PK_Cita PRIMARY KEY (id)
    ,
    CONSTRAINT FK_Cita_horarioUsuarioId FOREIGN KEY (horarioUsuarioId_fk) REFERENCES HorarioUsuario(id)
);



/*
  Nombre: Eliminar tabla Horario
  Fecha: 2025-01-12
  Autor: Gabriel
  Objetivo: Eliminar la tabla Horario de la base de datos
  Modificaciones: N/A
*/

BEGIN TRY
    -- Verifica si la tabla existe antes de eliminarla
    IF OBJECT_ID('dbo.FechaLimite', 'U') IS NOT NULL
    BEGIN
    DROP TABLE dbo.FechaLimite;
    PRINT 'Tabla FechaLimite eliminada correctamente.';
END
    ELSE
    BEGIN
    PRINT 'La tabla FechaLimite no existe.';
END
END TRY
BEGIN CATCH
    PRINT 'Error al eliminar la tabla FechaLimite: ' + ERROR_MESSAGE();
END CATCH


/*
    Nombre: Añadir campos tFechaInicio y tFechaFin a la tabla Vigencia
    Fecha: 2025-01-12
    Autor: Gabriel
    Objetivo: Agregar columnas para almacenar la fecha de inicio y fin de vigencia
    Modificaciones: N/A
*/
-- BEGIN TRY
--         ALTER TABLE Vigencia
--                 ADD tFechaInicio DATE NULL,
--                     tFechaFin DATE NULL,
--                     bActivo BIT DEFAULT 1 NOT NULL;
--         PRINT 'Campos tFechaInicio y tFechaFin añadidos correctamente a Vigencia.';
-- END TRY
-- BEGIN CATCH
--         PRINT 'Error al añadir campos a Vigencia: ' + ERROR_MESSAGE();
-- END CATCH


/*
    Nombre: Añadir campos vigenciaInicio y vigenciaFin a la tabla Asistencia
    Fecha: 2025-01-12
    Autor: Gabriel
    Objetivo: Agregar columnas para almacenar la vigencia de la asistencia
    Modificaciones: N/A
*/
BEGIN TRY
    ALTER TABLE Asistencia
        ADD vigenciaInicio DATE NULL,
            vigenciaFin DATE NULL;
    PRINT 'Campos vigenciaInicio y vigenciaFin añadidos correctamente a Asistencia.';
END TRY
BEGIN CATCH
    PRINT 'Error al añadir campos a Asistencia: ' + ERROR_MESSAGE();
END CATCH
GO

-- falta todo esto que pasaaa
ALTER TABLE Asistencia
    ADD tipoAsistencia VARCHAR(20) NULL;

/*
    Nombre: Modificar longitud de estadoEntrada en ControlUnidadAsistencia
    Fecha: 2025-01-12
    Autor: Gabriel
    Objetivo: Aumentar el tamaño de la columna estadoEntrada a VARCHAR(30)
    Modificaciones: N/A
*/
BEGIN TRY
    ALTER TABLE ControlUnidadAsistencia
        ALTER COLUMN estadoEntrada VARCHAR(30) NULL;
    PRINT 'Columna estadoEntrada modificada a VARCHAR(30) en ControlUnidadAsistencia.';
END TRY
BEGIN CATCH
    PRINT 'Error al modificar estadoEntrada en ControlUnidadAsistencia: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    ALTER TABLE RolControlAsistencia
        ALTER COLUMN estadoEntrada VARCHAR(30) NULL;
    PRINT 'Columna estadoEntrada modificada a VARCHAR(30) en ControlUnidadAsistencia.';
END TRY
BEGIN CATCH
    PRINT 'Error al modificar estadoEntrada en ControlUnidadAsistencia: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    ALTER TABLE ControlRolUsuarioAsistencia
        ALTER COLUMN estadoEntrada VARCHAR(30) NULL;
    PRINT 'Columna estadoEntrada modificada a VARCHAR(30) en ControlUnidadAsistencia.';
END TRY
BEGIN CATCH
    PRINT 'Error al modificar estadoEntrada en ControlUnidadAsistencia: ' + ERROR_MESSAGE();
END CATCH

/**
    Nombre: Añadir campo cDni a la tabla Sync_Usuario
    Fecha: 2026-01-16
    Autor: Gabriel
    Objetivo: Agregar columna para almacenar el DNI del usuario
    Modificaciones: N/A

*/
ALTER TABLE Sync_Usuario
    ADD cDni VARCHAR(8) NULL;


ALTER TABLE Asistencia
    ADD turnoEntradaid INT NULL,
        turnoSalidaid INT NULL;

ALTER TABLE Asistencia
    ADD esRegular BIT DEFAULT 1 NOT NULL;

ALTER TABLE Cita
    ADD marcacion DATETIME NULL;


ALTER TABLE Permiso ALTER COLUMN tHoraRetornoReal time NULL;
