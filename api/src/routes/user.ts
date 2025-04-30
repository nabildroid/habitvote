import { Hono } from "hono";
import { eq, ilike } from "drizzle-orm";
import { NewHabitSchema } from "../db/types";
import { Firebase } from "../repositories/firebase";

const UserRoute = new Hono();

UserRoute.use(async (c, next) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    return next();
});



UserRoute.post("/notifications/register", async (c) => {
    const { token } = await c.req.json();
    if (!token) return c.json({ error: "Token is required" }, { status: 400 });
    const uid = c.var.jwtPayload.uid;

    await Firebase.firestore().collection("config").doc("notifications").set({
        [uid]: token,
    }, { merge: true });

    return c.json({ message: "Token saved" });
});


export default UserRoute;