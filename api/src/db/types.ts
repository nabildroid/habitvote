import { z } from "zod";



export const HabitSchema = z.object({
    id: z.string().uuid(),

    name: z.string().min(1),
    publicName: z.string().min(1),
    description: z.string().min(5),

    isNegative: z.boolean().default(false),
    isActive: z.boolean().default(true),
    upadatedAt: z.coerce.date().default(new Date()),

    isDeleted: z.boolean().optional(),
})

export const NewHabitSchema = HabitSchema.omit({
    isDeleted: true
});


export const CheckinSchema = z.object({
    id: z.string(),
    habitId: z.string().uuid(),
    date: z.coerce.date(),
    isMissed: z.boolean(), // when user forgets to checkin
    isDone: z.boolean(),
    notes: z.string().nullable(),
    createdAt: z.coerce.date(),
});

export type ICheckin = z.infer<typeof CheckinSchema>;

export const NewCheckinSchema = CheckinSchema.extend({
    isMissed: z.literal(false),
});

