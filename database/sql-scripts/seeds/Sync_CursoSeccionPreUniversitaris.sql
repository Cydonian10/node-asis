USE API_SCAP_DB

GO
INSERT INTO Sync_CursoSeccionPreUniversitaria
  (
  idPeriodoLectivo, periodoLectivo, idTemporada, temporada, nivel, idNivel,
  idCentroEstudios, centroEstudios, idAreaAcademica, areaAcademica, idAreaCurricular, areaCurricular,
  idCursoPreUniversitario, cursoPreUniversitario
  )
VALUES
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 1, 'AREA I', 1, 'COMUNICACIÓN',
    1, 'CURSO A'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 1, 'AREA I', 2, 'INGLES',
    2, 'CURSO B'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 2, 'AREA II', 3, 'MATEMÁTICA',
    3, 'CURSO C'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 2, 'AREA II', 4, 'CIENCIA Y TECNOLOGÍA',
    4, 'CURSO D'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 3, 'AREA III', 5, 'PERSONAL SOCIAL',
    5, 'CURSO E'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 3, 'AREA III', 5, 'PERSONAL SOCIAL',
    6, 'CURSO F'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 1, 'AREA I', 1, 'COMUNICACIÓN',
    7, 'CURSO G'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 1, 'AREA I', 2, 'INGLES',
    8, 'CURSO H'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 2, 'AREA II', 3, 'MATEMÁTICA',
    9, 'CURSO I'
),
  (
    4, 'PERIODO LECTIVO 2025', 4, 'Temporada 2025-I', 'PREUNIVERSITARIO', 4,
    1, 'UNCP', 2, 'AREA II', 4, 'CIENCIA Y TECNOLOGÍA',
    10, 'CURSO J'
);