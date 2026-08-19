# SPEC 02 — Registrar Controles y Asignarlos a Entidades

> **Status:** Implementado
> **Depends on:** Ninguno
> **Date:** 2026-08-19
> **Objective:** Crear el módulo `controles` para administrar valores de asistencia y asignar como máximo un control activo a cada área, unidad y usuario.

---

## Scope

**In:**

- Reutilizar las tablas existentes `[Control]`, `ControlArea`, `ControlUnidad` y `ControlUsuario`.
- Administrar controles con `Tolerancia`, `LimiteTardanza` y `LimiteFalta` como enteros obligatorios mayores o iguales a cero al crear.
- Exponer `GET /controles/` para listar los controles completos con sus asignaciones.
- Exponer `POST /controles/` para crear un control con los tres valores numéricos.
- Exponer `PUT /controles/:id` para actualizar parcialmente uno o más valores del control.
- Exponer `DELETE /controles/:id` para eliminar lógicamente un control cuando no tenga asignaciones activas.
- Exponer `POST /controles/:id/area`, `POST /controles/:id/unidad` y `POST /controles/:id/usuario` para crear asignaciones usando el ID de la entidad en el body.
- Exponer `DELETE /controles/:id/area`, `DELETE /controles/:id/unidad` y `DELETE /controles/:id/usuario` para eliminar lógicamente las asignaciones correspondientes usando el ID de la entidad en el body.
- Impedir que un área, unidad o usuario tenga más de una asignación activa de control.
- Permitir una nueva asignación después de eliminar lógicamente la asignación anterior.
- Crear el módulo `src/modules/control/` siguiendo el patrón `controller.ts` → `service.ts` → `repository.ts` → `repository.sql.ts`.
- Crear DTOs de respuesta y DTOs de operación derivados de validaciones Zod estrictas.
- Documentar todos los endpoints y schemas con JSDoc `@swagger`.
- Crear procedimientos almacenados para listar, crear, actualizar, eliminar controles, asignar y desasignar controles.
- Corregir las restricciones de las tablas de relación para que la unicidad se aplique al objetivo mientras la asignación esté activa.
- Agregar pruebas unitarias para validaciones y reglas del servicio.

**Out of scope (for future specs):**

- Paginación, filtros avanzados u ordenamiento del listado.
- Pruebas E2E.
- Configuración de horarios, días laborables o reglas adicionales de asistencia.
- Aplicación automática de la tolerancia o de los límites durante el cálculo de asistencias.
- Asignación masiva de controles.
- Eliminación física de controles o relaciones.
- Integración con Kafka u otros sistemas externos.

---

## Data model

Las tablas base ya existen en `database/tables/tablas.sql`.

```sql
CREATE TABLE [Control]
(
    ControlId INT IDENTITY(1,1) PRIMARY KEY,
    Tolerancia INT NOT NULL DEFAULT 0,
    LimiteFalta INT NOT NULL DEFAULT 0,
    LimiteTardanza INT NOT NULL DEFAULT 0,
    Eliminado BIT DEFAULT 0,
    CreatedBy INT NOT NULL,
    UpdatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);
```

Significado de los campos:

- `Tolerancia`: cantidad de minutos de retraso que todavía cuenta como asistencia.
- `LimiteTardanza`: cantidad de minutos de retraso que todavía cuenta como tardanza y no como falta.
- `LimiteFalta`: cantidad máxima de faltas permitidas durante el mes.

Las relaciones mantienen sus claves foráneas actuales hacia `Area`, `Unidad`, `Usuario` y `[Control]`. Deben conservar eliminación lógica y agregar o corregir índices únicos filtrados para garantizar una sola relación activa por objetivo:

```sql
CREATE UNIQUE INDEX UX_ControlArea_Active_Area
    ON ControlArea (AreaId)
    WHERE Eliminado = 0;

CREATE UNIQUE INDEX UX_ControlUnidad_Active_Unidad
    ON ControlUnidad (UnidadId)
    WHERE Eliminado = 0;

CREATE UNIQUE INDEX UX_ControlUsuario_Active_Usuario
    ON ControlUsuario (UsuarioId)
    WHERE Eliminado = 0;
```

El listado devuelve cada control no eliminado con sus asignaciones activas de área, unidad y usuario. Las asignaciones se representan con sus identificadores de relación y de entidad.

---

## Implementation plan

1. Actualizar `database/tables/tablas.sql` para que los valores del control sean `NOT NULL` y para reemplazar las restricciones de unicidad de relación por índices únicos filtrados sobre `AreaId`, `UnidadId` y `UsuarioId` con `Eliminado = 0`.
2. Crear los procedimientos de control en `database/sql-scripts/procedures/CONTROL/`: `usp_GetControles`, `usp_CreateControl`, `usp_UpdateControl` y `usp_DeleteControl`.
3. Crear procedimientos de relación en la misma carpeta: `usp_AssignControlArea`, `usp_AssignControlUnidad`, `usp_AssignControlUsuario`, `usp_UnassignControlArea`, `usp_UnassignControlUnidad` y `usp_UnassignControlUsuario`.
4. Implementar en los procedimientos la validación de existencia de las entidades relacionadas, la exclusión de controles eliminados y la regla de una asignación activa por objetivo con errores claros.
5. Implementar `src/modules/control/dto/` con tipos de respuesta para control completo y asignaciones, además de DTOs derivados de cada schema de entrada.
6. Implementar `src/modules/control/validations/` con schemas Zod estrictos para crear, actualizar, asignar y desasignar cada relación; `POST` exigirá los tres campos y `PUT` aceptará actualización parcial con al menos un campo.
7. Implementar `paths.ts` con documentación Swagger y rutas ASCII singulares: `/area`, `/unidad` y `/usuario`.
8. Implementar `router.ts`, `controller.ts`, `service.ts`, `repository.ts` y `repository.sql.ts`, incluyendo la propagación del usuario autenticado para auditoría.
9. Registrar automáticamente el módulo mediante su `paths.ts` y verificar que el listado retorne el control completo con sus relaciones activas.
10. Agregar pruebas unitarias para límites numéricos, payload parcial de actualización, payloads de asignación/desasignación, rechazo de duplicados y rechazo de eliminación con asignaciones activas.

---

## Acceptance criteria

- [x] `GET /controles/` devuelve todos los controles no eliminados con sus asignaciones activas de área, unidad y usuario.
- [x] `POST /controles/` exige `tolerancia`, `limiteTardanza` y `limiteFalta` como enteros mayores o iguales a cero.
- [x] `PUT /controles/:id` permite actualizar uno o más de los tres campos y rechaza un body vacío.
- [x] `DELETE /controles/:id` marca el control como eliminado cuando no tiene asignaciones activas.
- [x] `DELETE /controles/:id` rechaza la operación cuando existe al menos una asignación activa.
- [x] `POST /controles/:id/area` asigna el control al `areaId` recibido en el body.
- [x] `POST /controles/:id/unidad` asigna el control al `unidadId` recibido en el body.
- [x] `POST /controles/:id/usuario` asigna el control al `usuarioId` recibido en el body.
- [x] Cada área puede tener como máximo una asignación activa.
- [x] Cada unidad puede tener como máximo una asignación activa.
- [x] Cada usuario puede tener como máximo una asignación activa.
- [x] Las tres rutas `DELETE /:id/area`, `DELETE /:id/unidad` y `DELETE /:id/usuario` eliminan lógicamente sus asignaciones.
- [x] Después de desasignar un control, el mismo objetivo puede recibir otra asignación.
- [x] Las rutas y los schemas tienen documentación `@swagger` válida.
- [x] Los procedimientos se invocan desde `repository.sql.ts` mediante `request.execute(...)`.
- [x] Las pruebas unitarias cubren validaciones y reglas de servicio indicadas.
- [x] `npm run build` pasa sin errores.

---

## Decisions

- **Yes:** Reutilizar las tablas de control existentes. Evita duplicar el modelo ya presente en la base de datos.
- **Yes:** Usar `Tolerancia`, `LimiteTardanza` y `LimiteFalta` como enteros no negativos. Corresponde a minutos y cantidad mensual según la definición funcional.
- **Yes:** Aplicar unicidad filtrada por objetivo y por asignación activa. La unicidad actual `(ControlId, objetivo)` no impide asignar controles distintos al mismo objetivo.
- **Yes:** Usar eliminación lógica. Mantiene auditoría y permite liberar el objetivo al eliminar una relación.
- **Yes:** Rechazar la eliminación del control principal si conserva asignaciones activas. Evita dejar relaciones activas apuntando a un control eliminado.
- **Yes:** Incluir las tres operaciones de desasignación. Son necesarias para que área, unidad y usuario puedan recibir posteriormente otro control.
- **Yes:** Usar `/area`, `/unidad` y `/usuario` en singular y sin acentos. Evita problemas de codificación en las URLs y mantiene un contrato uniforme.
- **Yes:** Permitir actualización parcial en `PUT`. Reduce payloads innecesarios sin permitir cuerpos vacíos.
- **No:** Agregar GET por ID. El contrato solicitado solo define el listado y las operaciones indicadas.
- **No:** Agregar pruebas E2E en esta especificación. Se limitará a pruebas unitarias.
- **No:** Calcular asistencias o faltas desde este módulo. El control solo administra configuración y asignaciones.

---

## Risks

| Risk | Mitigation |
| --- | --- |
| Las restricciones únicas actuales permiten duplicados activos por objetivo. | Reemplazarlas por índices únicos filtrados sobre el objetivo. |
| Condiciones de carrera al asignar dos controles al mismo objetivo. | Mantener el índice único en base de datos y traducir el error de constraint a una respuesta controlada. |
| Un control eliminado podría conservar relaciones activas. | Rechazar `DELETE /:id` mientras existan asignaciones activas y excluir controles eliminados de nuevas asignaciones. |
| Una actualización parcial podría dejar valores inválidos. | Validar cada campo como entero mayor o igual a cero y rechazar body vacío. |

---

## What is **not** in this spec

- Paginación, filtros avanzados u ordenamiento.
- Pruebas E2E.
- Cálculo de asistencias, tardanzas o faltas.
- Asignación masiva.
- Eliminación física.
- Integración con Kafka u otros sistemas externos.

Cada elemento podrá definirse en su propio spec si se requiere.
