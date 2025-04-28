import { Hono } from "hono";
import { eq, ilike } from "drizzle-orm";
import { NewHabitSchema } from "../db/types";
import { Firebase } from "../repositories/firebase";

const HabitRoute = new Hono();

HabitRoute.use(async (c, next) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    return next();
});


HabitRoute.post("/", async (c) => {
    const uid = c.var.jwtPayload.uid;

    const data = await c.req.json();
    const habit = NewHabitSchema.parse(data);
    await Firebase.firestore().collection("users").doc(uid).collection("habits").doc(habit.id).set(habit);

    return c.json({ success: true });
});


HabitRoute.get("/", async (c) => {
    const uid = c.var.jwtPayload.uid;
    const habits = await Firebase.firestore().collection("users").doc(uid).collection("habits").get();
    const data = habits.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    return c.json(data);
});


HabitRoute.get("/candidate/:candidateId", async (c) => {

    const candidateId = c.req.param("candidateId");

    if (!candidateId) {
        return c.json({ error: "Candidate ID is required" }, { status: 400 });
    }
    const habits = await Firebase.firestore().collection("users").doc(candidateId).collection("habits").get();
    const data = habits.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    return c.json(data);
});







export default HabitRoute;