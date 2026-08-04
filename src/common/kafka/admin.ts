import EnvVars from '@src/constants/EnvVars.js';
import { Kafka, type Admin, type KafkaConfig } from 'kafkajs';
import logger from '../logger.js';

const adminConfig: KafkaConfig = {
  clientId: `${EnvVars.Kafka.Id}-admin`,
  brokers: EnvVars.Kafka.Brokers,
};

const kafka = new Kafka(adminConfig);
export const admin: Admin = kafka.admin();

export async function ensureAdminConnected(): Promise<void> {
  let delay = 1000;

  let isConnected = false;
  while (!isConnected) {
    try {
      await admin.connect();
      logger.info('Kafka Admin conectado');
      isConnected = true;
      return;
    } catch (error) {
      logger.err(`[Admin connect failed] ${error}`);
      await new Promise((r) => setTimeout(r, delay));
      delay = Math.min(delay * 2, 30_000);
    }
  }
}

admin.on(admin.events.DISCONNECT, () => {
  logger.warn('Admin desconectado, reintentando conexión');
  ensureAdminConnected().catch((error) => {
    logger.err(`[Admin reconnection error] ${error}`);
  });
});

export async function ensureAptitudTopic(): Promise<void> {
  const topic = EnvVars.Kafka.topic.aptitud;

  const existing = await admin.listTopics();
  if (!existing.includes(topic)) {
    await admin.createTopics({
      topics: [
        {
          topic,
          numPartitions: 3,
          replicationFactor: 3,
        },
      ],
    });
    logger.info(`Tópico "${topic}" creado (3 particiones, RF=3)`);
  }
}

export async function ensureUsuarioTopics(): Promise<void> {
  const groupTopics = EnvVars.Kafka.group_usuario;
  const topics = [
    groupTopics.creado,
    groupTopics.actualizado,
    groupTopics.removido,
    groupTopics.error,
  ];

  const existing = await admin.listTopics();
  const toCreate = topics.filter((t) => !existing.includes(t));
  if (toCreate.length) {
    await admin.createTopics({
      topics: toCreate.map((topic) => ({
        topic,
        numPartitions: 3,
        replicationFactor: 3,
      })),
    });
    logger.info(`Tópicos creados: ${toCreate.join(', ')}`);
  }
}

export async function bootstrapTopicsSafe(): Promise<void> {
  if (EnvVars.Kafka.auto !== 'true') {
    logger.info('Auto-create topics deshabilitado.');
    return;
  }

  await ensureAdminConnected();

  await ensureAptitudTopic();
  await ensureUsuarioTopics();
  logger.info('Topics garantizados');
}
