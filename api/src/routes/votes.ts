import { Hono } from "hono";
import { redis } from "../repositories/upstash";
import { Firebase } from "../repositories/firebase";
import type { IHabit } from "../db/types";
import { generateVoteId } from "../utils";
import Admin from "firebase-admin";
import { getNotificationTokens } from "../repositories/notifications";

const VotesRoute = new Hono();

async function getCandidates() {
    // SCAN 0 MATCH available:*
    const data = await redis(`SCAN/0/MATCH/available:*`);

    if (data.length === 0) return [];

    const available = data[1].map((item: string) => {
        const parts = item.split(":");
        return parts[1];
    });

    return available;
}



VotesRoute.post("attend", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    const uid = c.var.jwtPayload.uid;

    const now = Date.now();
    const expires = 3600 * 24 * 7;

    await redis(`SET/available:${uid}/${now}/EX/${expires}`);
    return c.json({ success: true });
});


VotesRoute.post("/:voteId/activate", async (c) => {

    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    const uid = c.var.jwtPayload.uid;
    const voteId = c.req.param("voteId");

    if (!voteId) return c.json({ error: "Vote ID is required" }, { status: 400 });

    const voteRef = Firebase.firestore().collection("users").doc(uid).collection("votes").doc(voteId);

    try {
        await voteRef.update({
            isActivated: true,
            lastUpdate: new Date()
        });

        return c.json({ success: true });
    } catch (error) {
        console.error("Error activating vote:", error);
        return c.json({ error: "Failed to activate vote" }, { status: 500 });
    }

});




VotesRoute.get("/", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    const uid = c.var.jwtPayload.uid;

    const votes = await Firebase.firestore().collection("users").doc(uid).collection("votes").get();
    const data = votes.docs.map((doc) => {
        const vote = doc.data();
        return {
            ...vote,
            id: doc.id,
            openDate: vote.openDate.toDate(),
            endDate: vote.endDate.toDate(),
            lastUpdate: vote.lastUpdate.toDate(),
        };
    });

    return c.json(data);
});




VotesRoute.get("candidates", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });

    const available = await getCandidates();
    available.sort(() => Math.random() - 0.5);
    return c.json({ available: available.slice(0, 3) });
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

VotesRoute.get("/on/bot", async (c) => {
    // if (!c.var.jwtPayload.admin) return c.json({ error: "Unauthorized" }, { status: 401 });

    const available = await getCandidates();

    const ratio = 1//0.3;


    for (const uid of available) {
        if (Math.random() > ratio) continue;
        const habits = await Firebase.firestore().collection("users").doc(uid).collection("habits").get();
        const data = habits.docs.map((doc) => ({ id: doc.id, ...doc.data() })) as IHabit[];

        const habit = data.find(e => e.isActive);
        if (!habit) continue;

        const decision = Math.random() > 0.5 ? "up" : "down";
        await VoteOn({
            userId: uid,
            habitId: habit.id,
            decision: decision
        });
    }

    return c.json({ success: true });
});







export default VotesRoute;