import { Hono } from "hono";
import { Firebase } from "../repositories/firebase";
import { generateVoteId } from "../utils";
import Admin from "firebase-admin";
import { getNotificationTokens } from "../repositories/notifications";

const VotesRoute = new Hono();







VotesRoute.get("/", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    const uid = c.var.jwtPayload.uid;

    const votes = await Firebase.firestore().collection("users").doc(uid).collection("votes").get();
    const data = votes.docs.map((doc) => {
        const vote = doc.data();
        return {
            ...vote,
            id: doc.id,
            createdAt: vote.createdAt.toDate(),
            lastUpdate: vote.lastUpdate.toDate(),
        };
    });

    return c.json(data);
});




VotesRoute.get("candidates", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });

    const dummyData = [
        {
            id: "user-alice-123",
            habitId: "habit-read-book-456",
            habitName: "Read 10 pages daily",
            checkins: Array.from({ length: 8 }).map((_, i) => {
                const date = new Date();
                date.setDate(date.getDate() - i);
                return Math.random() < 0.5 ? date : null;
            }).filter(d => d !== null) as Date[],
        },
        {
            id: "user-bob-789",
            habitId: "habit-morning-jog-012",
            habitName: "Morning jog for 15 minutes",
            checkins: Array.from({ length: 8 }).map((_, i) => {
                const date = new Date();
                date.setDate(date.getDate() - i);
                return Math.random() < 0.5 ? date : null;
            }).filter(d => d !== null) as Date[],
        },
        {
            id: "user-charlie-345",
            habitId: "habit-drink-water-678",
            habitName: "Drink 8 glasses of water",
            checkins: Array.from({ length: 8 }).map((_, i) => {
                const date = new Date();
                date.setDate(date.getDate() - i);
                return Math.random() < 0.5 ? date : null;
            }).filter(d => d !== null) as Date[],
        },
        {
            id: "user-diana-901",
            habitId: "habit-meditate-234",
            habitName: "Meditate for 5 minutes",
            checkins: Array.from({ length: 8 }).map((_, i) => {
                const date = new Date();
                date.setDate(date.getDate() - i);
                return Math.random() < 0.5 ? date : null;
            }).filter(d => d !== null) as Date[],
        },
        {
            id: "user-ethan-567",
            habitId: "habit-no-sugar-890",
            habitName: "No sugar after 8 PM",
            checkins: Array.from({ length: 8 }).map((_, i) => {
                const date = new Date();
                date.setDate(date.getDate() - i);
                return Math.random() < 0.5 ? date : null;
            }).filter(d => d !== null) as Date[],
        }
    ]



    return c.json({ available: dummyData });
});




async function VoteOn(parmas: {
    userId: string;
    habitId: string;
    decision: "up" | "down";
}) {

    const voteId = generateVoteId(new Date(), { startHour: 0, endHour: 24, habitId: parmas.habitId });
    const vote = {
        id: voteId,
        openDate: new Date(),
        endDate: new Date(Date.now() + 1000 * 60 * 60 * 24),
        lastUpdate: new Date(),
        habitId: parmas.habitId
    } as any;

    const mergeFields = ["lastUpdate"];
    if (parmas.decision === "down") {
        vote.down = Admin.firestore.FieldValue.increment(1);
        mergeFields.push("down");
    } else {
        vote.up = Admin.firestore.FieldValue.increment(1);
        mergeFields.push("up");
    }

    const ref = Firebase.firestore().collection("users").doc(parmas.userId).collection("votes").doc(voteId);

    try { await ref.create(vote); }
    catch (e) { await ref.set(vote, { mergeFields }); }

    const tokens = await getNotificationTokens();
    const notificationToken = tokens[parmas.userId];
    if (!notificationToken) return;


    await Firebase.messaging().send({
        token: notificationToken,

        data: {
            habitId: parmas.habitId,
            voteId: voteId,
            decision: parmas.decision
        },
        android: {
            priority: "high",
            notification: {
                channelId: "vote_channel",
                priority: "high",
                title: "Habit Vote",
                body: `You have a new vote on your habit!`,
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
        },

    }).catch((e) => {
        console.error("Error sending notification:", e);
    });
}


VotesRoute.post("/on/:candidatId/:habitId", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    const habitId = c.req.param("habitId");
    const candidatId = c.req.param("candidatId");

    const { decision } = await c.req.json();
    if (!decision) return c.json({ error: "Decision is required" }, { status: 400 });
    if (decision !== "up" && decision !== "down") {
        return c.json({ error: "Decision must be 'up' or 'down'" }, { status: 400 });
    }

    await VoteOn({
        userId: candidatId,
        habitId: habitId,
        decision: decision
    });


    return c.json({ success: true });
});











export default VotesRoute;