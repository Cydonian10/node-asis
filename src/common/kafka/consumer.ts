import { Kafka, type Consumer, type KafkaConfig } from 'kafkajs';
import EnvVars from '@src/constants/EnvVars.js';
import logger from '../logger.js';
import {
  KafkaPayload,
  routes as kafkaRoutes,
  KafkaGroupId,
  KafkaTopicsOf,
  KafkaRoute,
} from './type.js';
import { producer } from './producer.js';

const kafkaConfig: KafkaConfig = {
  clientId: EnvVars.Kafka.Id + '-consumer',
  brokers: EnvVars.Kafka.Brokers,
};

const kafka = new Kafka(kafkaConfig);

function makeConsumer(groupId: string): Consumer {
  return kafka.consumer({ groupId });
}

async function toDlq<G extends KafkaGroupId, T extends KafkaTopicsOf<G>>(
  route: KafkaRoute<G, T>,
  key: string | undefined,
  body: Record<string, unknown>,
) {
  await producer.send({
    topic: route.error,
    messages: [
      {
        key,
        value: JSON.stringify({ ...body, timestamp: new Date().toISOString() }),
      },
    ],
  });
}

export async function startGroupConsumer(groupId: string): Promise<void> {
  const consumer = makeConsumer(groupId);

  consumer.on(consumer.events.DISCONNECT, () => {
    logger.warn('Consumer ${groupId} desconectado, reitentando conexión...');
    ensureConsumerConnected(groupId).catch((error) =>
      logger.err(`[Consumer reconnection error] ${error}`),
    );
  });

  consumer.on(consumer.events.CRASH, ({ payload: { error } }) => {
    logger.err(`[Consumer ${groupId} crash] ${String(error)}`);
    ensureConsumerConnected(groupId).catch((error) =>
      logger.err(`[Consumer reconnection error] ${error}`),
    );
  });

  await consumer.connect();

  const groupRoutes = kafkaRoutes[groupId as KafkaGroupId] ?? {};

  await Promise.all(
    Object.keys(groupRoutes).map((topic) =>
      consumer.subscribe({
        topic,
        fromBeginning: false,
      }),
    ),
  );

  await consumer.run({
    eachMessage: async ({ topic, message }) => {
      if (!message.value) return;
      const route = groupRoutes[topic as keyof typeof groupRoutes];
      if (!route) {
        return logger.warn(`No hay ruta definida para topic ${topic}`);
      }

      let raw: unknown;
      try {
        raw = JSON.parse(message.value.toString());
      } catch (__error) {
        const err = 'Mensaje no es JSON válido';
        logger.err(err);
        return await toDlq(route, message.key?.toString(), {
          originalTopic: topic,
          error: err,
          raw: message.value.toString(),
        });
      }

      const parsed = route.schema.safeParse(raw);
      if (!parsed.success) {
        const errList = parsed.error.errors.map((e: { path: (string | number)[]; message: string }) => ({
          path: e.path,
          message: e.message,
        }));
        logger.err(
          `Validación fallida en ${topic}: ${JSON.stringify(errList)}`,
        );
        return await toDlq(route, message.key?.toString(), {
          originalTopic: topic,
          error: errList,
          raw,
        });
      }

      try {
        await route.handler(
          parsed.data as KafkaPayload<string | number, string | number>,
        );
      } catch (error) {
        const errMsg = String(error);
        logger.err(`[Handler ${topic}] ${errMsg}`);
        return await toDlq(route, message.key?.toString(), {
          originalTopic: topic,
          error: errMsg,
          payload: parsed.data,
        });
      }
    },
  });
}

export async function ensureConsumerConnected(groupId: string): Promise<void> {
  let delay = 1000;
  let isConnected = false;
  while (!isConnected) {
    try {
      await startGroupConsumer(groupId);
      logger.info(`Kafka consumer [${groupId}] conectado`);
      isConnected = true;
      return;
    } catch (error) {
      logger.err(`[Consumer ${groupId} connect failed] ${error}`);
      await new Promise((r) => setTimeout(r, delay));
      delay = Math.min(delay * 2, 30_000);
    }
  }
}

export async function startAllConsumers(): Promise<void> {
  const groups: string[] = [EnvVars.Kafka.group_usuario.id].filter(
    (id): id is string => !!id && id.length > 0,
  );

  await Promise.all(groups.map((g) => ensureConsumerConnected(g)));
}
