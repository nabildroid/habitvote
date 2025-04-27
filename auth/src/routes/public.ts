import { Hono } from 'hono'
import { CreateHono } from '..'
import { drizzle } from 'drizzle-orm/d1';
import { usersTable } from '../db/schema';
import { NowInSecond, generateID, isDumbOtp, tokenToOTP } from '../utils';
import { sign, verify } from 'hono/jwt'
import { eq } from 'drizzle-orm';
import { cors } from 'hono/cors';
import * as z from "zod"

import GoogleProvider from "../repositories/googleProvider"
import GooglePlayProvider from '../repositories/googlePlayProvider';
import TokenJWT from '../services/tokenjwt';
const PublicAPI = CreateHono();

// todo remove this
PublicAPI.use('*', cors())




const LoginWithGoogleSchmema = z.object({
    accessToken: z.string(),
});


PublicAPI.post("/loginWithGoogle", async (c) => {
    const ipAddress = c.req.header()["cf-connecting-ip"] || ""
    const { success } = await c.env.RATELIMIT_NEW_ACCOUNT.limit({ key: ipAddress })
    if (!success && process.env.NODE_ENV !== "development") {
        return c.json({ success: false, error: "Rate limit exceeded" }, { status: 429 })
    }

    const { accessToken } = LoginWithGoogleSchmema.parse(await c.req.json());
    if (!accessToken) {
        return c.json({ success: false, error: "Missing AccessToken" }, { status: 401 })
    }

    const google = new GoogleProvider(c.env);
    const googleUser = await google.getUser(accessToken);


    let user: any;

    try {
        const query = await drizzle(c.env.DB).insert(usersTable).values({
            uid: generateID(),
            email: googleUser.email,
            displayName: googleUser.name,
            photoUrl: googleUser.picture,
        }).returning()

        user = query[0];


    } catch (e) {
        console.log(e)
        const query = await drizzle(c.env.DB).select().from(usersTable).where(eq(usersTable.email, googleUser.email))
        if (!query.length) {
            return c.json({ success: false, error: "User not found" }, { status: 404 })
        }
        user = query[0]

    }
    console.log(user);

    const session = new TokenJWT(c.env);
    const { token, expires } = await session.signShort(user);
    const { token: refreshToken } = await session.signLong({ uid: user.uid });

    return c.json({ success, uid: user.uid, token, refreshToken, expires })
});




PublicAPI.post("/refresh", async (c) => {
    const { token } = await c.req.json()
    const { payload, session } = await TokenJWT.fromRefreshToken(token, c.env);


    const uid = payload.uid as string;
    const query = await drizzle(c.env.DB).select().from(usersTable).where(eq(usersTable.uid, uid));
    if (!query.length) {
        return c.notFound()
    }
    const user = query[0];

    // user.claims = {
    //     premiumExpires: Date.now() + 1000 * 60 * 60 * 24 * 30,
    // }



    const { token: newToken, expires } = await session.signLong(user);
    return c.json({ newToken, user, expires })
})


export default PublicAPI