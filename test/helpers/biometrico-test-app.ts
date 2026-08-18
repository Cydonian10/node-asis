import express from 'express';
import BiometricoRouter from '@src/modules/biometrico/router.js';
import BiometricoPath from '@src/modules/biometrico/paths.js';

const app = express();
app.use(express.json());
app.use(BiometricoPath.Base, BiometricoRouter);

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  return res.status(500).json({ error: err.message });
});

export default app;
