import { Hono } from 'hono'
import PublicAPI from './routes/public';
import ServiceAPI from './routes/service';
import { generateID } from './utils';
import PaymentAPI from './routes/payment';


type Bindings = {
    DB: D1Database;
    RATELIMIT_NEW_ACCOUNT: RateLimit;
    JWT_ISS: string;
    JWT_SECRET: string;
    GOOGLE_CLIENT_EMAIL: string;
    GOOGLE_PRIVATE_KEY: string;
    STRIPE_KEY: string;
    ANDROID_PACKAGE_NAME: string;
    SERVICE_KEY: string;
}


export function CreateHono() {
    return new Hono<{ Bindings: Bindings }>()
}

const app = CreateHono()



app.get('/', async (c) => {
    const ipAddress = c.req.header()["cf-connecting-ip"] || ""
    const { success } = await c.env.RATELIMIT_NEW_ACCOUNT.limit({ key: ipAddress })

    return c.json({ e: generateID(), success });
})

app.route("/", PublicAPI)
app.route("/service", ServiceAPI)
app.route("/payment", PaymentAPI);

export default app
