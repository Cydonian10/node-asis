import z from 'zod';

export const NumberSchema = z.coerce
  .number({ message: 'Invalid number' })
  .min(0, { message: 'Number must be at least 0' });
