import { Hono } from "hono";
import { redis } from "../repositories/upstash";

const VotesRoute = new Hono();

async function getAviailable() {
    // SCAN 0 MATCH available:*
    const data = await redis(`SCAN/0/MATCH/available:*`);

    if (data.length === 0) return [];

    const available = data[1].map((item: string) => {
        const parts = item.split(":");
        return parts[1];
    });

    return available;
}



VotesRoute.get("attend", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });
    const uid = c.var.jwtPayload.uid;

    const now = Date.now();
    const expires = 3600 * 24 * 7;

    await redis(`SET/available:${uid}/${now}/EX/${expires}`);
    return c.json({ success: true });
});



VotesRoute.get("available", async (c) => {
    if (!c.var.jwtPayload.uid) return c.json({ error: "Unauthorized" }, { status: 401 });

    const available = await getAviailable();
    available.sort(() => Math.random() - 0.5);
    return c.json({ available: available.slice(0, 3) });
});


VotesRoute.post("bot", async (c) => {
    if (!c.var.jwtPayload.admin) return c.json({ error: "Unauthorized" }, { status: 401 });

    const available = await getAviailable();

    const ratio = 0.3;

    for (const uid of available) {
        if(Math.random() > ratio) continue;

        console.log("voting for", uid);
    }

    return c.json({ success: true });
});







export default VotesRoute;