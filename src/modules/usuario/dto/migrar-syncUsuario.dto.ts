import z from "zod";
import { MigrarSyncUsuarioSchema } from "../validations/migrar-sync-usuario.validation.js";

export type MigrarSyncUsuarioDto = z.infer<typeof MigrarSyncUsuarioSchema>;
