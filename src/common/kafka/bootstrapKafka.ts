import { bootstrapTopicsSafe } from './admin.js';
import { ensureProducerConnected } from './producer.js';
import { startAllConsumers } from './consumer.js';

export async function bootstrapKafka(): Promise<void> {
  await bootstrapTopicsSafe();
  await ensureProducerConnected();
  await startAllConsumers();
}
