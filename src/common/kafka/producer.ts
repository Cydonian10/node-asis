import { Kafka } from 'kafkajs';
import logger from '@src/common/logger.js';

import type { Producer, KafkaConfig, ProducerConfig } from 'kafkajs';
import EnvVars from '@src/constants/EnvVars.js';

const kafkaConfig: KafkaConfig = {
  clientId: `${EnvVars.Kafka.Id}-producer`,
  brokers: EnvVars.Kafka.Brokers,
  retry: {
    initialRetryTime: 300,
  },
};

const producerConfig: ProducerConfig = {
  allowAutoTopicCreation: false,
  idempotent: true,
  maxInFlightRequests: 1,
};

const kafka: Kafka = new Kafka(kafkaConfig);

export const producer: Producer = kafka.producer(producerConfig);

export async function ensureProducerConnected() {
  let delay = 1000;

  let isConnected = false;
  while (!isConnected) {
    try {
      await producer.connect();
      logger.info('Kafka producer conectado');
      isConnected = false;
      return;
    } catch (error) {
      logger.err(`[Producer connect failed] ${error}`);
      await new Promise((r) => setTimeout(r, delay));
      delay = Math.min(delay * 2, 30_000);
    }
  }
}

producer.on(producer.events.DISCONNECT, () => {
  logger.warn('Producer desconectado, reintentando conexión');
  ensureProducerConnected().catch((err) =>
    logger.err(`[Producer reconnection error] ${err}`),
  );
});
