import './pre-start';
import logger from '@src/common/logger.js';

import EnvVars from '@src/constants/EnvVars.js';
import server from './server.js';
//import { bootstrapKafka } from './common/kafka/bootstrapKafka.js';

/*async*/ (() => {
  // **** Run **** //
  const port = EnvVars.Port;
  const SERVER_START_MSG = 'Express server started on port: ' + port.toString();

  server.listen(port, () => {
    logger.info(SERVER_START_MSG);
  });

  /* try {
    await bootstrapKafka();
  } catch (error) {
    const text =
      error instanceof Error
        ? `[Error arrancando la app] ${error.message}\n${error.stack}`
        : `[Error arrancando la app] ${JSON.stringify(error)}`;
    logger.err(text);
    process.exit(1);
  }*/
})();
