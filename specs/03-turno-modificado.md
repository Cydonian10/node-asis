# SPEC 03 — Módulo Turno Modificado con CRUD anidado en turno

> **Status:** Implementado
> **Depends on:** Ninguno
> **Date:** 2026-08-19
> **Objective:** Crear el módulo `turno-modificado` para administrar modificaciones de turno por fecha, usuario y horario, anidado en `/turno/:turnoId/modificar`, con validación de asistencia y unicidad activa por turno, usuario y fecha.

---

## Scope

**In:**

- Reutilizar la tabla existente `TurnoModificado` en `database/tables/tablas.sql` sin alterar sus columnas.
- Agregar un índice único filtrado que impida más de una modificación activa por `TurnoId + UsuarioId + Fecha`.
- Crear el módulo `src/modules/turno-modificado/` siguiendo el patrón `controller.ts` → `service.ts` → `repository.ts` → `repository.sql.ts`.
- Exponer `GET /turno/:turnoId/modificar` para listar modificaciones con filtros opcionales `fechaDesde`, `fechaHasta` (ambos inclusivos) y `usuarioId`.
- Exponer `POST /turno/:turnoId/modificar` para crear una modificación de un solo día, tomando `turnoId` de la URL y exigiendo `usuarioId`, `fecha`, `horaInicio` y `horaFin` en el body; `motivo` es opcional.
- Exponer `GET /turno/:turnoId/modificar/:turnoModificadoId` para obtener una modificación específica.
- Exponer `PUT /turno/:turnoId/modificar/:turnoModificadoId` para actualizar parcialmente `fecha`, `horaInicio`, `horaFin` y `motivo`; no permite cambiar `turnoId` ni `usuarioId`.
- Exponer `DELETE /turno/:turnoId/modificar/:turnoModificadoId` para eliminar lógicamente la modificación.
- Rechazar `GET`, `PUT` y `DELETE` cuando `turnoModificadoId` no pertenezca al `turnoId` de la URL.
- Rechazar `PUT` y `DELETE` cuando el `turnoId` tenga una asistencia asociada.
- Validar formato ISO de fecha (`YYYY-MM-DD`) y horas (`HH:mm` o `HH:mm:ss`); no se compara `horaInicio` con `horaFin`.
- Crear validaciones Zod estrictas por operación en `validations/` y DTOs derivados en `dto/`.
- Documentar todos los endpoints y schemas con JSDoc `@swagger`.
- Crear procedimientos almacenados en `database/sql-scripts/procedures/TURNO_MODIFICADO/`.
- Agregar pruebas unitarias para validaciones y reglas del servicio.

**Out of scope (for future specs):**

- Manejo de rangos de fechas al crear (un registro por fecha, no por rango).
- Pruebas E2E.
- Paginación, ordenamiento u otros filtros avanzados en el listado.
- Modificación de `turnoId` o `usuarioId` ya creados.
- Validación de cruce de horarios con otros turnos o modificaciones.
- Integración con Kafka u otros sistemas externos.
- Eliminación física de modificaciones.

---

## Data model

La tabla ya existe en `database/tables/tablas.sql` y se reutiliza sin cambios de columnas:

```sql
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
```

Se agrega un índice único filtrado para garantizar una sola modificación activa por combinación:

```sql
CREATE UNIQUE INDEX UX_TurnoModificado_Active_TurnoUsuarioFecha
    ON TurnoModificado (TurnoId, UsuarioId, Fecha)
    WHERE Eliminado = 0;
```

**Conventions:**

- PK: `INT IDENTITY(1,1)` secuencial.
- Fecha: `DATE` exacto, una modificación por día.
- Horas: tipo `TIME`, formato `HH:mm` o `HH:mm:ss`.
- Soft-delete: `Eliminado BIT DEFAULT 0`.
- Auditoría: `CreatedBy` y `UpdatedBy` como `VARCHAR(200)` (usuario autenticado del request).
- Unicidad activa: índice filtrado sobre `TurnoId`, `UsuarioId` y `Fecha`.

---

## Implementation plan

1. Actualizar `database/tables/tablas.sql` para agregar el índice único filtrado `UX_TurnoModificado_Active_TurnoUsuarioFecha` sobre `TurnoModificado`.
2. Crear los procedimientos en `database/sql-scripts/procedures/TURNO_MODIFICADO/`: `usp_GetTurnoModificados`, `usp_CreateTurnoModificado`, `usp_GetTurnoModificadoById`, `usp_UpdateTurnoModificado` y `usp_DeleteTurnoModificado`.
3. Implementar en los procedimientos la validación de existencia de `Turno` y `Usuario`, la exclusión de registros eliminados, la unicidad activa por turno/usuario/fecha, y la prohibición de actualizar o eliminar cuando exista asistencia para el `turnoId`.
4. Crear `src/modules/turno-modificado/dto/` con tipos de respuesta y DTOs derivados de cada schema de entrada.
5. Crear `src/modules/turno-modificado/validations/` con schemas Zod estrictos: crear (exige `usuarioId`, `fecha`, `horaInicio`, `horaFin`; `motivo` opcional), actualizar (parcial de `fecha`, `horaInicio`, `horaFin`, `motivo`), y filtro de listado (`fechaDesde`, `fechaHasta`, `usuarioId` opcionales).
6. Implementar `paths.ts` con documentación Swagger y rutas anidadas bajo `Base: '/turno/:turnoId/modificar'`.
7. Implementar `router.ts`, `controller.ts`, `service.ts`, `repository.ts` y `repository.sql.ts`, propagando el usuario autenticado para auditoría y validando la pertenencia de `turnoModificadoId` al `turnoId` de la URL.
8. Registrar automáticamente el módulo mediante su `paths.ts` y verificar que el listado respete los filtros y la exclusión de eliminados.
9. Agregar pruebas unitarias para formatos de fecha/hora, payload parcial de actualización, rechazo de duplicados activos, rechazo por asistencia y rechazo por pertenencia incorrecta de `turnoId`.
10. Ejecutar `npm run build` para verificar que todo compila sin errores.

---

## Acceptance criteria

- [ ] `GET /turno/:turnoId/modificar` lista modificaciones no eliminadas del `turnoId`.
- [ ] `GET /turno/:turnoId/modificar` aplica `fechaDesde` y `fechaHasta` como filtro inclusivo y opcional.
- [ ] `GET /turno/:turnoId/modificar` aplica `usuarioId` como filtro opcional.
- [ ] `POST /turno/:turnoId/modificar` toma `turnoId` desde la URL.
- [ ] `POST /turno/:turnoId/modificar` exige `usuarioId`, `fecha`, `horaInicio` y `horaFin`.
- [ ] `POST /turno/:turnoId/modificar` acepta `motivo` opcional.
- [ ] `POST` rechaza fecha fuera de formato `YYYY-MM-DD`.
- [ ] `POST` rechaza horas fuera de formato `HH:mm` o `HH:mm:ss`.
- [ ] `POST` rechaza una segunda modificación activa para el mismo `TurnoId + UsuarioId + Fecha`.
- [ ] `GET /turno/:turnoId/modificar/:turnoModificadoId` devuelve una modificación específica.
- [ ] `GET`, `PUT` y `DELETE` rechazan un `turnoModificadoId` que no pertenece al `turnoId` de la URL.
- [ ] `PUT /turno/:turnoId/modificar/:turnoModificadoId` actualiza parcialmente `fecha`, `horaInicio`, `horaFin` y `motivo`.
- [ ] `PUT` impide cambiar `turnoId` y `usuarioId`.
- [ ] `PUT` rechaza la operación cuando el `turnoId` tiene una asistencia asociada.
- [ ] `DELETE /turno/:turnoId/modificar/:turnoModificadoId` elimina lógicamente la modificación.
- [ ] `DELETE` rechaza la operación cuando el `turnoId` tiene una asistencia asociada.
- [ ] Las rutas y los schemas tienen documentación `@swagger` válida.
- [ ] Los procedimientos se invocan desde `repository.sql.ts` mediante `request.execute(...)`.
- [ ] Las pruebas unitarias cubren validaciones y reglas de servicio indicadas.
- [ ] `npm run build` pasa sin errores.

---

## Decisions

- **Yes:** Reutilizar `TurnoModificado` sin cambiar columnas. La tabla ya existe y cubre los campos requeridos.
- **Yes:** Crear una modificación por fecha, sin rango al crear. La tabla solo modela `Fecha` y simplifica consultas y eliminación.
- **Yes:** Tomar `turnoId` de la URL en `POST`. Evita duplicar datos y mantiene coherencia con la ruta anidada.
- **Yes:** Exigir `usuarioId`, `fecha`, `horaInicio` y `horaFin` en la creación; `motivo` opcional. Representa un turno, usuario y horario concretos.
- **Yes:** Usar filtros `fechaDesde`, `fechaHasta` y `usuarioId` inclusivos y opcionales en el listado. Cubre consulta por fecha y por usuario sin rangos de creación.
- **Yes:** Aplicar unicidad activa con índice filtrado sobre `TurnoId + UsuarioId + Fecha`. Evita dos horarios distintos para la misma combinación.
- **Yes:** Validar pertenencia de `turnoModificadoId` al `turnoId` de la URL. Evita acceder a registros de otro turno.
- **Yes:** Bloquear `PUT` y `DELETE` cuando el `turnoId` tenga asistencia. Protege la integridad de asistencias ya generadas.
- **Yes:** Actualización parcial en `PUT`. Reduce payloads y mantiene el patrón existente del proyecto.
- **Yes:** No comparar `horaInicio` con `horaFin`. El turno extendido ya permite fin posterior a medianoche en `Turno`.
- **No:** Rangos de fechas al crear. Se filtra en consulta, no se crean múltiples registros.
- **No:** Pruebas E2E. La especificación se limita a pruebas unitarias.
- **No:** Paginación u ordenamiento. No solicitado en el contrato.
- **No:** Modificar `turnoId` o `usuarioId`. Son inmutables tras la creación.

---

## Risks

| Risk                                                       | Mitigation                                                                                          |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Duplicados activos por combinación turno/usuario/fecha     | Índice único filtrado en base de datos y traducción del error de constraint a respuesta controlada. |
| Condiciones de carrera al crear dos modificaciones iguales | Mantener el índice único y validar existencia previa en el procedimiento.                           |
| `PUT`/`DELETE` sobre modificación ya usada en asistencia   | Validar asistencia del `turnoId` antes de actualizar o eliminar.                                    |
| `turnoModificadoId` de otro turno en la URL                | Validar pertenencia al `turnoId` en service/repository antes de operar.                             |
| Formato de fecha u hora inválido                           | Schemas Zod estrictos con patrones ISO y rechazo de payloads malformados.                           |

---

## What is **not** in this spec

- Rangos de fechas al crear modificaciones.
- Pruebas E2E.
- Paginación, ordenamiento o filtros avanzados.
- Modificación de `turnoId` o `usuarioId`.
- Validación de cruce de horarios.
- Integración con Kafka u otros sistemas externos.
- Eliminación física.

Cada elemento podrá definirse en su propio spec si se requiere.
