-- Tablas del sistema SCAP
-- Convencion: MSSQL Server (PascalCase, tablas con prefijo, ID IDENTITY)
-- Tablas sync: ID no autoincremental (vienen del origen externo)
-- Resto de tablas: ID IDENTITY(1,1)

use API_SCAP_DB

GO

CREATE TABLE SyncUnidad
(
    SyncUnidadId INT NOT NULL PRIMARY KEY,
    Codigo VARCHAR(50),
    Nombre VARCHAR(200),
    Activo BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Unidad
(
    UnidadId INT IDENTITY(1,1) PRIMARY KEY,
    SyncUnidadId INT NOT NULL,
    HorasLaborales INT DEFAULT 8,
    HorasLaboralesTotales INT DEFAULT 40,
    Eliminado BIT DEFAULT 0,
    FOREIGN KEY (SyncUnidadId) REFERENCES SyncUnidad(SyncUnidadId)
);

CREATE TABLE SyncUsuarios
(
    SyncUsuarioId INT NOT NULL PRIMARY KEY,
    Usuario VARCHAR(200),
    Nombres VARCHAR(200),
    Apellidos VARCHAR(200),
    Tipo VARCHAR(50),
    Dni VARCHAR(20),
);

CREATE TABLE Usuario
(
    UsuarioId INT IDENTITY(1,1) PRIMARY KEY,
    SyncUsuarioId INT NOT NULL UNIQUE,
    Active BIT DEFAULT 1,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SyncUsuarioId) REFERENCES SyncUsuarios(SyncUsuarioId)
);

CREATE TABLE UsuarioUnidad
(
    UsuarioUnidadId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT NOT NULL,
    UnidadId INT NOT NULL,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (UnidadId) REFERENCES Unidad(UnidadId),

);

CREATE TABLE Rol
(
    RolId INT IDENTITY(1,1) PRIMARY KEY,
    UnidadId INT NOT NULL,
    Nombre VARCHAR(100),
    Descripcion VARCHAR(255),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (UnidadId) REFERENCES Unidad(UnidadId)
);

CREATE TABLE UsuarioRol
(
    UsuarioRolId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT NOT NULL,
    RolId INT NOT NULL,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (RolId) REFERENCES Rol(RolId)
);

CREATE TABLE Area
(
    AreaId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(200),
    Descripcion VARCHAR(255),
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
);


CREATE TABLE Horario
(
    HorarioId INT IDENTITY(1,1) PRIMARY KEY,
    UnidadId INT NOT NULL,
    Nombre VARCHAR(200),
    Extendido BIT DEFAULT 0,
    Rotativo BIT DEFAULT 0,
    Regular BIT DEFAULT 1,
    AreaId INT,
    Eliminado BIT DEFAULT 0,
    HorasLaborales INT DEFAULT 8,
    FOREIGN KEY (UnidadId) REFERENCES Unidad(UnidadId),
    FOREIGN KEY (AreaId) REFERENCES Area(AreaId),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200)
);

CREATE TABLE HorarioAsignacion
(
    HorarioAsignacionId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT NOT NULL,
    HorarioId INT NOT NULL,
    FechaInicio DATE,
    FechaFin DATE,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (HorarioId) REFERENCES Horario(HorarioId)
)


CREATE TABLE Dia
(
    DiaId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Abreviatura VARCHAR(10),
    Orden INT DEFAULT 0,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200)
);

CREATE TABLE HorarioDia
(
    HorarioDiaId INT IDENTITY(1,1) PRIMARY KEY,
    HorarioId INT NOT NULL,
    DiaId INT NOT NULL,
    Orden INT DEFAULT 0,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (HorarioId) REFERENCES Horario(HorarioId),
    FOREIGN KEY (DiaId) REFERENCES Dia(DiaId)
);

CREATE TABLE Turno
(
    TurnoId INT IDENTITY(1,1) PRIMARY KEY,
    HorarioDiaId INT,
    HoraInicio TIME,
    HoraFin TIME,
    Extendido BIT DEFAULT 0,
    -- si es 1 entonces tiene que tener dia conectado y hora fin sera hasta le diaSalida
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (HorarioDiaId) REFERENCES HorarioDia(HorarioDiaId)
);


CREATE TABLE Vigencia
(
    VigenciaId INT IDENTITY(1,1) PRIMARY KEY,
    HorarioDiaId INT NOT NULL,
    FechaInicio DATE,
    FechaFin DATE,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (HorarioDiaId) REFERENCES HorarioDia(HorarioDiaId)
);

CREATE TABLE TurnoModificado
(
    TurnoModificadoId INT IDENTITY(1,1) PRIMARY KEY,
    TurnoId INT,
    UsuarioId INT,
    Fecha DATE,
    HoraInicio TIME,
    HoraFin TIME,
    Motivo VARCHAR(255),
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (TurnoId) REFERENCES Turno(TurnoId)
);

CREATE TABLE SalidaTurnoDia
(
    SalidaTurnoDiaId INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    TurnoId INT,
    DiaId INT,
    Eliminado BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedBy VARCHAR(200),
    CreatedBy VARCHAR(200),
    FOREIGN KEY (DiaId) REFERENCES Dia(DiaId),
    FOREIGN KEY (TurnoId) REFERENCES Turno(TurnoId)
);



CREATE TABLE EstadoAsistencia
(
    EstadoAsistenciaId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100),
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE [Control]
(
    ControlId INT IDENTITY(1,1) PRIMARY KEY,
    Tolerancia INT DEFAULT 0,
    LimiteFalta INT DEFAULT 0,
    LimiteTardanza INT DEFAULT 0,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE ControlUnidad
(
    ControlUnidadId INT IDENTITY(1,1) PRIMARY KEY,
    ControlId INT NOT NULL,
    UnidadId INT NOT NULL,
    Eliminado BIT DEFAULT 0,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UNIQUE (ControlId, UnidadId),
    FOREIGN KEY (ControlId) REFERENCES [Control](ControlId),
    FOREIGN KEY (UnidadId) REFERENCES Unidad(UnidadId)
);

CREATE TABLE ControlUsuario
(
    ControlUsuarioId INT IDENTITY(1,1) PRIMARY KEY,
    ControlId INT NOT NULL,
    UsuarioId INT NOT NULL,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    UNIQUE (ControlId, UsuarioId),
    FOREIGN KEY (ControlId) REFERENCES [Control](ControlId),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE ControlArea
(
    ControlAreaId INT IDENTITY(1,1) PRIMARY KEY,
    ControlId INT NOT NULL,
    AreaId INT NOT NULL,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ControlId) REFERENCES [Control](ControlId),
    FOREIGN KEY (AreaId) REFERENCES Area(AreaId)
);

CREATE TABLE Vacaciones
(
    VacacionId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT,
    FechaSolicitud DATETIME2,
    DiasDisponibles INT,
    DiasTomados INT,
    Aprobado BIT DEFAULT 0,
    AprobadoPor INT NULL,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE DetalleVacaciones
(
    DetalleVacacionId INT IDENTITY(1,1) PRIMARY KEY,
    VacacionId INT,
    FechaInicio DATE,
    FechaFin DATE,
    Dias INT,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VacacionId) REFERENCES Vacaciones(VacacionId)
);

----------

CREATE TABLE Motivo
(
    MotivoId INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100),
    Descripcion VARCHAR(255),
    DocumentoRequerido BIT DEFAULT 0,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);


-- falta crear tabla de vacaciones por usuario y detalle de vacaciones por usuario
CREATE TABLE Permisos
(
    PermisoId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT,
    FechaSolicitud DATETIME2,
    HoraSalida TIME,
    HoraRetorno TIME,
    Motivo TEXT,
    HoraDeRetornoEstimada TIME,
    Tipo VARCHAR(50),
    Estado VARCHAR(50),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Justificaciones
(
    JustificacionId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT,
    Fecha DATE,
    Motivo TEXT,
    Archivo VARCHAR(255),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Licencia
(
    LicenciaId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT,
    FechaSolicitud DATETIME2,
    FechaInicio DATE,
    FechaFin DATE,
    Tipo VARCHAR(50),
    Estado VARCHAR(50),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Asistencia
(
    AsistenciaId INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId INT,
    Fecha DATE,
    EstadoAsistenciaId INT,
    ControlId INT,
    HoraEntrada DATETIME2, --
    HoraSalida DATETIME2, --
    vigenciaInicio DATE, --
    vigenciaFin DATE, --
    TipoAsistencia VARCHAR(50), -- 'Extendido' y 'Regular'
    turnoEntrada TIME, --
    turnoId INT, --
    turnoSalida TIME, --
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (EstadoAsistenciaId) REFERENCES EstadoAsistencia(EstadoAsistenciaId),
    FOREIGN KEY (ControlId) REFERENCES [Control](ControlId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);



CREATE TABLE MarcaBiometrico
(
    MarcaBiometricoId INT IDENTITY(1,1) PRIMARY KEY,
    FechaHora DATETIME2,
    Tipo VARCHAR(20),
    Origen VARCHAR(50),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Biometrico
(
    BiometricoId INT IDENTITY(1,1) PRIMARY KEY,
    MarcaBiometricoId INT,
    Tipo VARCHAR(50),
    Valor VARBINARY(MAX),
    FOREIGN KEY (MarcaBiometricoId) REFERENCES MarcaBiometrico(MarcaBiometricoId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);



CREATE TABLE Cita
(
    CitaId INT IDENTITY PRIMARY KEY,
    UsuarioId INT NOT NULL,

    Fecha DATE NOT NULL,
    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL,

    NombreCliente VARCHAR(200),
    Motivo VARCHAR(500),

    Estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',

    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Feriado
(
    FeriadoId INT IDENTITY PRIMARY KEY,
    Nombre VARCHAR(200) NOT NULL,
    Fecha DATE NOT NULL,
    TodoElDia BIT DEFAULT 1,
    Estado BIT DEFAULT 1,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE FeriadoUnidad
(
    FeriadoUnidadId INT IDENTITY PRIMARY KEY,
    FeriadoId INT NOT NULL,
    UnidadId INT NOT NULL,

    FOREIGN KEY (FeriadoId) REFERENCES Feriado(FeriadoId),
    FOREIGN KEY (UnidadId) REFERENCES Unidad(UnidadId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);


CREATE TABLE Marcacion
(
    MarcacionId INT IDENTITY(1,1) PRIMARY KEY,
    EmpCode VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    PunchTime DATETIME NOT NULL,
    PunchState VARCHAR(5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    TerminalSN VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    TerminalAlias VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    EmpId INT NULL,
    TerminalId INT NULL,
    Eliminado BIT DEFAULT 0 NOT NULL,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);


CREATE TABLE AsistenciaMarcacion
(
    AsistenciaMarcacionId INT IDENTITY(1,1) PRIMARY KEY,
    AsistenciaId INT NOT NULL,
    MarcacionId INT NOT NULL,
    BiometricoId INT NULL,
    TipoMarcacion VARCHAR(50) NOT NULL, -- 'entrada' o 'salida'
    FOREIGN KEY (AsistenciaId) REFERENCES Asistencia(AsistenciaId),
    FOREIGN KEY (MarcacionId) REFERENCES Marcacion(MarcacionId),
    FOREIGN KEY (BiometricoId) REFERENCES Biometrico(BiometricoId),
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);
