import { Hono } from "hono";
import { Firebase } from "../repositories/firebase";
import { generateVoteId } from "../utils";
import Admin from "firebase-admin";
import { getNotificationTokens } from "../repositories/notifications";
import type { ICheckin, IHabit } from "../db/types";
import { getAllCandidates } from "../service/tempCandidateMatcher";

const VotesRoute = new Hono();






VotesRoute.get("/candidates", async (c) => {

    console.log('candidate')
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });



    let candidates = await getAllCandidates();

    candidates.sort(() => Math.random() - 0.5); // Shuffle candidates
    candidates = candidates.slice(0, 10); // Limit to 5 candidates

    // fetch habits

    const promises = candidates.map(async (candidate) => {
        const habitsPromise = Firebase.firestore().collection("users").doc(candidate.candidateId).collection("habits").get();
        const checkinsPromise = Firebase.firestore().collection("users").doc(candidate.candidateId).collection("checkin").get();

        const [habits, checkins] = await Promise.all([habitsPromise, checkinsPromise]);

        const data = habits.docs.map((doc) => ({ id: doc.id, ...doc.data() })) as IHabit[];

        let checkinData = checkins.docs.map((doc) => {
            const data = doc.data();
            return {
                id: doc.id,
                ...data,
                date: data.date.toDate(),
                createdAt: data.createdAt.toDate(),
            };
        }) as ICheckin[];
        // filter by habitId
        checkinData = checkinData.filter((checkin) => checkin.habitId === candidate.habitId);


        return {
            id: candidate.candidateId,
            habitId: candidate.habitId,
            habitName: data.find(h => h.id === candidate.habitId)?.name || "Unknown Habit",
            checkins: [...checkinData.map(c => c.date)],
        }

    });

    const available = await Promise.all(promises);

    return c.json({ available });
});






const getTodayVoteId = (habitId: string) => {
    const today = new Date().toISOString().split("T")[0];
    return today + "-" + habitId;
}


VotesRoute.get("/:habitId", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    const uid = c.var.jwtPayload.uid;

    const habitId = c.req.param("habitId");
    if (!habitId) return c.json({ error: "Habit ID is required" });



    const ref = Firebase.firestore().collection("users").doc(uid).collection("votes");
    const voteId = getTodayVoteId(habitId);
    const vote = await ref.doc(voteId).get();

    if (!vote.exists) {
        return c.json({ error: "No votes found for today" }, { status: 404 });
    }

    const data = vote.data();
    if (!data) {
        return c.json({ error: "No data found" }, { status: 404 });
    }

    data.id = vote.id; // Add the document ID to the response
    data.createdAt = data.createdAt.toDate();
    data.lastUpdate = data.lastUpdate.toDate();



    return c.json(data);
});








async function VoteOn(parmas: {
    userId: string;
    habitId: string;
    decision: "up" | "down";
}) {


    const voteId = getTodayVoteId(parmas.habitId);


    console.log(parmas);


    const vote = {
        id: voteId,
        lastUpdate: new Date(),
        createdAt: new Date(),
        habitId: parmas.habitId,
    } as any;

    const mergeFields = ["lastUpdate"];
    if (parmas.decision === "down") {
        vote.down = Admin.firestore.FieldValue.increment(1);
        mergeFields.push("down");
    } else {
        vote.up = Admin.firestore.FieldValue.increment(1);
        mergeFields.push("up");
    }

    console.log(vote);

    const ref = Firebase.firestore().collection("users").doc(parmas.userId).collection("votes").doc(voteId);

    try { await ref.create(vote); }
    catch (e) { await ref.set(vote, { mergeFields }); }

    // const tokens = await getNotificationTokens();
    // const notificationToken = tokens[parmas.userId];
    // if (!notificationToken) return;


    // await Firebase.messaging().send({
    //     token: notificationToken,

    //     data: {
    //         habitId: parmas.habitId,
    //         voteId: voteId,
    //         decision: parmas.decision
    //     },
    //     android: {
    //         priority: "high",
    //         notification: {
    //             channelId: "vote_channel",
    //             priority: "high",
    //             title: "Habit Vote",
    //             body: `You have a new vote on your habit!`,
    //             clickAction: "FLUTTER_NOTIFICATION_CLICK",
    //         },
    //     },

    // }).catch((e) => {
    //     console.error("Error sending notification:", e);
    // });
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

    const available = await getAllCandidates();

    const ratio = 1//0.3;


    for (const { candidateId, habitId } of available) {
        if (Math.random() > ratio) continue;

        console.log("Bot voting on", candidateId, habitId);


        const decision = Math.random() > 0.5 ? "up" : "down";
        await VoteOn({
            userId: candidateId,
            habitId: habitId,
            decision: decision
        });
    }

    return c.json({ success: true });
});













export default VotesRoute;