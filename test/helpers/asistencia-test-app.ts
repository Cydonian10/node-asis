import express from 'express';
import AsistenciaRouter from '@src/modules/asistencia/router.js';
import AsistenciaPath from '@src/modules/asistencia/paths.js';
import SeedRouter from '@src/modules/seed/router.js';
import SeedPath from '@src/modules/seed/paths.js';

const app = express();
app.use(express.json());
app.use(AsistenciaPath.Base, AsistenciaRouter);
app.use(SeedPath.Base, SeedRouter);

app.use(
  (
    err: Error,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction,
  ) => res.status(500).json({ error: err.message }),
);

export default app;
