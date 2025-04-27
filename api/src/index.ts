import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { verify } from 'hono/jwt';
import { poweredBy } from 'hono/powered-by';
import HabitRoute from './routes/habits';
import CheckinRoute from './routes/checkins';
import VotesRoute from './routes/votes';

const app = new Hono()
app.use(poweredBy({ serverName: "Laknabil.me" }))
app.use(cors({ origin: '*' }))


app.use(async (c, next) => {
    console.log(c.req.path);
    if (process.env.NODE_ENV === "development") {
    }

    const adminToken = process.env.ADMIN_TOKEN ?? Math.random();
    if (adminToken && c.req.header().authorization === "Bearer " + adminToken) {
        c.set("jwtPayload", { admin: true });
        return await next()
    }

    if (c.req.header("x-auth")) {
        try {
            const payload = await verify(c.req.header("x-auth")!, process.env.JWT_SECRET!);
            if (!payload.exp || payload.iss != "habitvote-auth-cloudflare") return c.notFound()
            c.set("jwtPayload", payload)

        } catch (e) {
            console.error("could not verify jwt")
            return c.notFound()
        }
    }

    return await next()
});



app.route("/habits", HabitRoute);
app.route("/checkin", CheckinRoute);
app.route("/votes", VotesRoute);



app.get('/ping', async (c) => {
    const timer = Date.now();
    const delay = Date.now() - timer;
    return c.text('Hello Bun! ' + delay + "ms");
})

export default app