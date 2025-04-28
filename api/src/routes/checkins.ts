import { Hono } from "hono";
import { NewCheckinSchema, type ICheckin } from "../db/types";
import { Firebase } from "../repositories/firebase";

const CheckinRoute = new Hono();

CheckinRoute.use(async (c, next) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    return next();
});



CheckinRoute.delete("/:id", async (c) => {
    const uid = c.var.jwtPayload.uid;
    const id = c.req.param("id");

    if (!id) {
        return c.json({ error: "Checkin ID is required" }, { status: 400 });
    }

    try {
        await Firebase.firestore()
            .collection("users")
            .doc(uid)
            .collection("checkin")
            .doc(id)
            .delete();

        return c.json({ success: true });
    } catch (error) {
        console.error("Error deleting checkin:", error);
        return c.json({ error: "Failed to delete checkin" }, { status: 500 });
    }
});

CheckinRoute.post("/", async (c) => {
    const uid = c.var.jwtPayload.uid;

    const data = await c.req.json();
    const newCheckin = NewCheckinSchema.parse(data);

    await Firebase.firestore().collection("users").doc(uid).collection("checkin").doc(newCheckin.id).set({
        ...newCheckin,
        createdAt: new Date(),
    }, { merge: true });

    return c.json({ success: true, data: newCheckin });
});


CheckinRoute.get("/", async (c) => {
    const uid = c.var.jwtPayload.uid;
    const checkins = await Firebase.firestore().collection("users").doc(uid).collection("checkin").get();

    const data = checkins.docs.map((doc) => {
        const checkin = doc.data();
        return {
            id: doc.id,
            ...checkin,
            date: checkin.date.toDate(),
            createdAt: checkin.createdAt.toDate(),
        };

    }) as ICheckin[];

    return c.json(data);
});

CheckinRoute.get("/candidate/:candidateId/:habitId", async (c) => {
    const habitId = c.req.param("habitId");
    const candidateId = c.req.param("candidateId");

    if (!candidateId) {
        return c.json({ error: "Candidate ID is required" }, { status: 400 });
    }

    const checkins = await Firebase.firestore().collection("users").doc(candidateId).collection("checkin").where("habitId", "==", habitId).get();
    let data = checkins.docs.map((doc) => {
        const checkin = doc.data();
        return {
            id: doc.id,
            ...checkin,
            date: checkin.date.toDate(),
            createdAt: checkin.createdAt.toDate(),
        };

    }) as ICheckin[];

    // Sort by date (newest first)
    data = data.sort((a, b) => b.date.getTime() - a.date.getTime());

    // Limit to the last 10 checkins
    data = data.slice(0, 10);



    return c.json(data);
});



export default CheckinRoute;