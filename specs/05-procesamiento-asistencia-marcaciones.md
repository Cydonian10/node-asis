# SPEC 05 — Procesamiento de marcaciones y evaluación de asistencia

> **Status:** Approved
> **Depends on:** SPEC 01, SPEC 02, SPEC 03, SPEC 04
> **Date:** 2026-08-21
> **Objective:** Procesar marcaciones biométricas para resolver usuario, turno y control, crear o actualizar asistencias y evaluar sus estados de entrada y salida.

---

## Scope

**In:**

- Agregar `Biometrico.TerminalId` para relacionar cada marcación con un biométrico activo.
- Agregar `Asistencia.MinutosTarde` con valor inicial `0`.
- Agregar el estado `Pendiente` al catálogo `EstadoAsistencia`.
- Validar el terminal de cada `Marcacion` usando `Marcacion.TerminalId` y `Biometrico.TerminalId`.
- Resolver el usuario mediante `Marcacion.EmpCode = SyncUsuarios.Dni`.
- Resolver asignaciones activas de horario respetando `FechaInicio`, `FechaFin`, `Culminacion` y `Eliminado`.
- Resolver `HorarioDia`, `VigenciaGrupo`, turnos múltiples, turnos extendidos y `TurnoModificado`.
- Seleccionar el turno cuya entrada o salida tenga mayor cercanía temporal con `PunchTime`.
- Crear o localizar `Asistencia` por `UsuarioId`, fecha de inicio del turno y `TurnoId`.
- Guardar snapshots de horas del turno y de vigencia en la asistencia.
- Asociar cada marcación con `AsistenciaMarcacion`, `BiometricoId` y `TipoMarcacion`.
- Resolver el control con prioridad `ControlUsuario > ControlArea > ControlUnidad`.
- Evaluar la entrada con `Tolerancia` y `LimiteTardanza`.
- Calcular `MinutosTarde` solo cuando la marcación supera la tolerancia.
- Evaluar la salida sin aplicar tolerancia de entrada.
- Mantener estados independientes para entrada y salida.
- Generar `ResultadoAsistencia` combinando ambos estados.
- Mantener como `Pendiente` la parte aún no marcada de una asistencia.
- Preservar estados `Vacaciones`, `Permiso`, `Licencia` y `Justificado` cuando ya existan.
- Ejecutar `procesar-marcaciones` como lote transaccional: cualquier error revierte todo el lote.
- Ejecutar `reprocesar-asistencias` tolerando errores individuales y continuando con las demás asistencias.
- Cerrar asistencias pendientes y crear faltas cuando corresponda.
- Verificar vacaciones, licencia, permiso, justificación y feriado aplicable antes de establecer `Falta`.
- Actualizar procedimientos, repositorio SQL, pruebas unitarias y pruebas E2E del módulo `asistencia`.

**Out of scope (for future specs):**

- Crear o administrar terminales desde un endpoint nuevo.
- Cambiar el origen o formato de las marcaciones recibidas desde el biométrico.
- Integrar Kafka u otros sistemas externos para publicar eventos de asistencia.
- Modificar reglas de asignación, creación o edición de horarios.
- Modificar CRUDs de controles, vacaciones, permisos, licencias o justificaciones.
- Crear un endpoint independiente para consultar el detalle de una asistencia.
- Reemplazar el proceso de sincronización de `SyncUsuarios`.
- Eliminar físicamente marcaciones, asistencias o asociaciones históricas.

---

## Data model

Se agregan los siguientes campos y estados en la base de datos:

```sql
ALTER TABLE Biometrico
ADD TerminalId INT NOT NULL;

CREATE UNIQUE INDEX UX_Biometrico_Active_TerminalId
    ON Biometrico (TerminalId)
    WHERE Eliminado = 0;

ALTER TABLE Asistencia
ADD MinutosTarde INT NOT NULL DEFAULT 0;
```

El valor de `Biometrico.TerminalId` debe ser único entre biométricos activos. Las marcaciones conservarán su `TerminalId` original y `AsistenciaMarcacion.BiometricoId` conservará el biométrico que las originó.

El catálogo `EstadoAsistencia` debe contener `Pendiente` además de los estados existentes:

```text
Asistio
Tarde
Falta
SalidaAnticipada
Pendiente
SinMarcacionEntrada
SinMarcacionSalida
Justificado
Vacaciones
Permiso
Licencia
VigenciaVencida
```

Una asistencia se identifica funcionalmente por:

```text
UsuarioId + Fecha de inicio del turno + TurnoId
```

Para turnos extendidos, `Fecha` es siempre la fecha de inicio, aunque `HoraSalida` ocurra al día siguiente.

Los snapshots de la asistencia son:

```text
turnoEntrada
turnoSalida
vigenciaInicio
vigenciaFin
ControlId
MinutosTarde
```

---

## Implementation plan

1. Crear una migración idempotente para agregar `Biometrico.TerminalId`, su unicidad entre registros activos, `Asistencia.MinutosTarde` y el estado `Pendiente`.
2. Actualizar `database/tables/tablas.sql` para que las instalaciones nuevas incluyan las columnas, índices y el estado requeridos.
3. Crear o actualizar los procedimientos de `database/sql-scripts/procedures/ASISTENCIA/` para devolver `TerminalId`, resolver el biométrico, excluir asignaciones culminadas y mantener las reglas de vigencia y turnos extendidos.
4. Agregar procedimientos para crear asistencias con estado inicial `Pendiente`, actualizar entrada con `MinutosTarde`, actualizar salida y asociar el `BiometricoId` de cada marcación.
5. Agregar la consulta de cierre para identificar asistencias pendientes y turnos finalizados, incluyendo controles, guards y feriados aplicables.
6. Actualizar los tipos internos de `src/modules/asistencia/repository.sql.ts` para representar terminal, biométrico, `Pendiente`, `MinutosTarde`, turnos modificados y fechas de entrada/salida.
7. Reestructurar `procesarMarcaciones` para validar todas las marcaciones dentro de una transacción y abortar el lote ante el primer error de terminal, usuario, horario, vigencia o turno.
8. Implementar la selección de entrada o salida por cercanía temporal, conservando la fecha de inicio para asistencias de turnos extendidos y evitando asignar una misma marcación a dos asistencias.
9. Implementar la creación y actualización de asistencia con snapshots, control aplicable, asociación biométrica y evaluación independiente de entrada y salida.
10. Implementar la regla de estados especiales: guardar horas y asociaciones, pero no recalcular estado ni resultado cuando la asistencia ya está en `Vacaciones`, `Permiso`, `Licencia` o `Justificado`.
11. Actualizar `reprocesarAsistencias` para usar los valores del control almacenado, cerrar pendientes, consultar guards y feriados, registrar errores individuales y continuar con el resto del lote.
12. Actualizar DTOs, Swagger y mensajes del módulo para documentar `Pendiente`, `MinutosTarde`, errores de terminal y el comportamiento transaccional.
13. Agregar pruebas unitarias para límites de tolerancia, límite de tardanza, minutos tarde, resultado combinado, turnos múltiples, turnos modificados, fechas extendidas, estados especiales y errores de reproceso.
14. Agregar pruebas E2E para terminal válido e inválido, rollback del lote, asociación del biométrico, entrada/salida, control por prioridad, guards, feriado y cierre de asistencias pendientes.
15. Ejecutar `npm run test`, `npm run test:e2e` y `npm run build` como verificación final.

---

## Acceptance criteria

- [ ] `Biometrico.TerminalId` existe, es obligatorio y es único entre biométricos activos.
- [ ] `Asistencia.MinutosTarde` existe, es obligatorio y tiene valor predeterminado `0`.
- [ ] `EstadoAsistencia` contiene `Pendiente` sin duplicarlo en ejecuciones repetidas de la migración.
- [ ] Una marcación con `TerminalId` inexistente aborta el procesamiento del lote completo.
- [ ] Una marcación cuyo biométrico está eliminado aborta el procesamiento del lote completo.
- [ ] Una marcación con usuario inexistente por DNI aborta el procesamiento del lote completo.
- [ ] Una marcación sin asignación de horario activa aborta el procesamiento del lote completo.
- [ ] Una asignación culminada no se considera activa.
- [ ] Una fecha fuera de `FechaInicio` y `FechaFin` no resuelve una asignación activa.
- [ ] Un horario rotativo exige una `VigenciaGrupo` que incluya la fecha de la marcación.
- [ ] Se consideran múltiples turnos del mismo día al seleccionar el turno más cercano.
- [ ] `TurnoModificado` reemplaza las horas originales cuando corresponde a usuario, turno y fecha.
- [ ] Una salida de turno extendido se asocia con la asistencia de la fecha en que inició el turno.
- [ ] Una asistencia nueva se crea con estados de entrada y salida `Pendiente` cuando aún no existen marcaciones para esas partes.
- [ ] `TurnoEntrada`, `TurnoSalida`, `VigenciaInicio` y `VigenciaFin` se guardan como snapshots al crear la asistencia.
- [ ] `AsistenciaMarcacion` guarda `AsistenciaId`, `MarcacionId`, `BiometricoId` y `TipoMarcacion`.
- [ ] El control se resuelve en orden `ControlUsuario`, `ControlArea` y `ControlUnidad`.
- [ ] Una entrada dentro de `Tolerancia` queda como `Asistio` y `MinutosTarde` queda en `0`.
- [ ] Una entrada posterior a `Tolerancia` y hasta `LimiteTardanza` queda como `Tarde`.
- [ ] Una entrada posterior a `LimiteTardanza` queda como `Falta`.
- [ ] Una entrada antes de la hora programada queda como `Asistio` y `MinutosTarde` queda en `0`.
- [ ] `MinutosTarde` representa la diferencia entre la hora programada y la hora real cuando corresponde.
- [ ] Una salida igual o posterior a `TurnoSalida` queda como `Asistio`.
- [ ] Una salida anterior a `TurnoSalida` queda como `SalidaAnticipada`.
- [ ] La evaluación de salida no usa `Tolerancia` ni `LimiteTardanza`.
- [ ] `EstadoAsistenciaEntradaId` y `EstadoAsistenciaSalidaId` se actualizan de forma independiente.
- [ ] `ResultadoAsistencia` combina los dos estados y conserva `Pendiente` para la parte faltante.
- [ ] Una asistencia con `Vacaciones`, `Permiso`, `Licencia` o `Justificado` conserva su estado y resultado al recibir una marcación.
- [ ] Una asistencia con estado especial sí guarda las horas y asociaciones biométricas recibidas.
- [ ] Un error durante `procesar-marcaciones` revierte las asistencias y asociaciones creadas en el lote.
- [ ] `reprocesar-asistencias` registra errores individuales y continúa procesando las demás asistencias.
- [ ] El cierre consulta vacaciones, licencia, permiso, justificación y feriado antes de establecer `Falta`.
- [ ] Las asistencias pendientes vencidas se convierten en estados de ausencia apropiados durante el cierre.
- [ ] Las pruebas unitarias cubren las reglas de evaluación y clasificación indicadas.
- [ ] Las pruebas E2E cubren rollback transaccional y persistencia de `BiometricoId`.
- [ ] `npm run test` pasa sin errores.
- [ ] `npm run test:e2e` pasa con la base de datos configurada.
- [ ] `npm run build` pasa sin errores.

---

## Decisions

- **Yes:** Agregar `Biometrico.TerminalId` y usarlo para validar `Marcacion.TerminalId`. Es la relación explícita entre el origen físico y la marcación.
- **Yes:** Hacer `Biometrico.TerminalId` obligatorio y único entre dispositivos activos. Evita ambigüedad al resolver el biométrico.
- **Yes:** Usar `LimiteTardanza` como límite absoluto para pasar de `Tarde` a `Falta`. La regla solicitada distingue tolerancia, tardanza y falta.
- **No:** Usar `LimiteFalta` en la evaluación de entrada. La regla funcional confirmada usa `LimiteTardanza`.
- **Yes:** Crear asistencias con estado inicial `Pendiente`. La ausencia de una entrada o salida no se cierra al recibir una sola marcación.
- **Yes:** Mantener estados de entrada y salida independientes. Permite resultados como `Tarde - Asistio` y `Asistio - SalidaAnticipada`.
- **Yes:** Preservar estados especiales y solo guardar horas y asociaciones. Vacaciones, permisos, licencias y justificaciones no deben ser sobrescritos por una marcación.
- **Yes:** Abortar todo `procesar-marcaciones` ante un error. La operación de recepción se comporta como un lote atómico.
- **Yes:** Continuar en `reprocesar-asistencias` después de un error y reportarlo. El reproceso debe poder avanzar con datos parcialmente problemáticos.
- **Yes:** Guardar `BiometricoId` en `AsistenciaMarcacion`. Permite auditar el dispositivo que originó la marcación.
- **Yes:** Mantener la fecha de inicio como `Asistencia.Fecha` para turnos extendidos. Evita crear asistencias separadas para una misma jornada.
- **Yes:** Verificar feriados antes de crear una falta. Un día no laborable no debe convertirse automáticamente en ausencia.
- **No:** Crear un endpoint nuevo para recibir una sola marcación. Se reutiliza el procesamiento por lote existente.
- **No:** Eliminar físicamente registros o asociaciones. El historial de asistencia y marcaciones debe conservarse.
- **No:** Modificar los CRUD de horarios, controles o guards. Este spec solo consume sus datos y reglas existentes.

---

## Risks

| Risk                                                                    | Mitigation                                                                                                                                |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Existen biométricos actuales sin `TerminalId` al ejecutar la migración. | La migración debe validar datos previos y documentar que los dispositivos deben recibir un valor antes de aplicar la columna obligatoria. |
| Dos procesos reciben la misma marcación simultáneamente.                | Usar transacciones, restricciones únicas y validación de enlaces existentes.                                                              |
| La cercanía temporal puede ser ambigua entre entrada y salida.          | Ordenar por distancia y por `TurnoId`, y cubrir empates con pruebas explícitas.                                                           |
| Un turno extendido cruza la medianoche.                                 | Calcular targets con la fecha de entrada y el día configurado de salida.                                                                  |
| Un cambio de control posterior altera la reevaluación histórica.        | Guardar `ControlId` y usar el control snapshot durante el reproceso.                                                                      |
| Una asistencia especial recibe varias marcaciones.                      | Preservar estados y resultado, impedir duplicar enlaces y guardar únicamente horas pendientes.                                            |
| Un error de reproceso deja asistencias sin cerrar.                      | Registrar el error por elemento y devolverlo en `errores` para una ejecución posterior.                                                   |

---

## What is **not** in this spec

- Administración de biométricos o terminales mediante nuevos endpoints.
- Cambio del formato de las marcaciones del sistema externo.
- Integración con Kafka u otros sistemas externos.
- Cambios en CRUDs de horarios, controles, vacaciones, permisos, licencias o justificaciones.
- Nuevo endpoint de detalle de asistencia.
- Eliminación física de datos históricos.

Cada elemento podrá definirse en su propio spec si se requiere.
