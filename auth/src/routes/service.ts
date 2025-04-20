import { Hono } from 'hono'
import { CreateHono } from '..';
import { drizzle } from 'drizzle-orm/d1';
import { usersTable } from '../db/schema';
import { eq } from 'drizzle-orm';
import { sign } from 'hono/jwt';
import { NowInSecond, generateID } from '../utils';
import { HTTPException } from 'hono/http-exception';
import TokenJWT from '../services/tokenjwt';


const ServiceAPI = CreateHono();


ServiceAPI.use(async (c, next) => {
    console.log(c.env)
    if (c.req.header()["key"] != c.env.SERVICE_KEY)
        return c.redirect("https://etre.pro")

    return await next()
})


/// create a user
ServiceAPI.post("/create", (c) => {
    return c.json({})
})


// get a jwt
ServiceAPI.get("/jwt/:uid", async (c) => {
    const { uid } = c.req.param()

    const user = await drizzle(c.env.DB).select().from(usersTable).where(eq(usersTable.uid, uid)).get()

    if (!user)
        return c.notFound()




    const session = new TokenJWT(c.env);
    const { token, expires } = await session.signShort(user);
    const { token: refreshToken } = await session.signLong({ uid: user.uid });

    return c.json({
        token,
        refreshToken,
        expires
    })
})

// Manipulation
ServiceAPI.post("claim/:uid", async (c) => {
    const { uid } = c.req.param()
    const claims = await c.req.json()


    if (!Object.keys(claims).length) {
        throw new HTTPException(401, { message: 'please provide the key and the value for the claim' })
    }

    const user = await drizzle(c.env.DB).select().from(usersTable).where(eq(usersTable.uid, uid)).get()
    if (!user)
        return c.notFound();




    await drizzle(c.env.DB).update(usersTable).set({
        claims: {
            ...(user.claims ?? {}),
            ...claims
        }
    })

    return c.json({})
})




ServiceAPI.post("claims/:uid", async (c) => {
    const { uid } = c.req.param()
    const claims = await c.req.json()

    if (!Object.keys(claims).length) {
        throw new HTTPException(401, { message: 'please provide the claims' })
    }

    const user = await drizzle(c.env.DB).select().from(usersTable).where(eq(usersTable.uid, uid)).get()
    if (!user)
        return c.notFound();


    if (!user.claims)
        user.claims = {} as any;
    (user.claims as any) = claims


    await drizzle(c.env.DB).update(usersTable).set({
        claims: user.claims
    })

    return c.json({})
})

ServiceAPI.get("claims/:uid", async (c) => {
    const { uid } = c.req.param()

    const user = await drizzle(c.env.DB).select().from(usersTable).where(eq(usersTable.uid, uid)).get()
    if (!user)
        return c.notFound();



    return c.json({
        ...(user.claims ?? {})
    })
})



ServiceAPI.post()

export default ServiceAPI;