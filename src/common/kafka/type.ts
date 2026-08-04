import { kafkaRoutes } from './routes.js';

export const routes = kafkaRoutes;

export type KafkaRoutesMap = typeof kafkaRoutes;

export type KafkaGroupId = keyof KafkaRoutesMap;

export type KafkaTopicsOf<G extends KafkaGroupId> = keyof KafkaRoutesMap[G];

export type KafkaRoute<
  G extends KafkaGroupId,
  T extends KafkaTopicsOf<G>,
> = KafkaRoutesMap[G][T] & { error: string };

export type KafkaPayload<
  G extends KafkaGroupId,
  T extends KafkaTopicsOf<G>,
> = KafkaRoutesMap[G][T]['schema'] extends {
  safeParse(raw: unknown): { success: true; data: infer P };
}
  ? P
  : never;
