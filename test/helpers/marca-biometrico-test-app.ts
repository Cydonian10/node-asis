import express from 'express';
import MarcaBiometricoRouter from '@src/modules/marca-biometrico/router.js';
import MarcaBiometricoPath from '@src/modules/marca-biometrico/paths.js';

const app = express();
app.use(express.json());
app.use(MarcaBiometricoPath.Base, MarcaBiometricoRouter);

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  return res.status(500).json({ error: err.message });
});

export default app;
