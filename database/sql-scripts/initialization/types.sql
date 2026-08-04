USE API_SUMMIT_DB
GO

CREATE TYPE CreateGradoTVP AS TABLE (id_grado INT)

CREATE TYPE UpdateGradoTVP AS TABLE (
    id_grado INT
    , asignado BIT
    );

CREATE TYPE AlumnoTVP AS TABLE (
    ALUMNO_ID INT
);

CREATE TYPE CursoExonear_TVP AS TABLE (
  cursoId INT
);