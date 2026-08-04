import express from 'express';
import UsuarioRouter from '@src/modules/usuario/router.js';
import UsuarioPath from '@src/modules/usuario/paths.js';

const app = express();
app.use(express.json());
app.use(UsuarioPath.Base, UsuarioRouter);

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  return res.status(500).json({ error: err.message });
});

export default app;
