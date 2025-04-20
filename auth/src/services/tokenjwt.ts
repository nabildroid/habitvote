import { sign, verify } from "hono/jwt";
import { generateID, NowInSecond } from "../utils";






type Props = {
    shortPeriodInSeconds?: number,
    longPeriodInSeconds?: number,
    JWT_SECRET: string,
    JWT_ISS: string,
}


export default class TokenJWT {
    private config: Props;

    public tokenID: string;

    constructor(config: Props) {
        this.config = config;
        if (this.config.shortPeriodInSeconds == null) {
            this.config.shortPeriodInSeconds = 60 * 15;
        }

        if (this.config.longPeriodInSeconds == null) {
            this.config.longPeriodInSeconds = 60 * 60 * 24 * 30;
        }

        this.tokenID = generateID();

    }


    static async fromRefreshToken(token: string, config: Props) {
        const payload = await verify(token, config.JWT_SECRET);

        if (!payload.exp || NowInSecond() > payload.exp || payload.iss != config.JWT_ISS) {
            throw new Error("Token expired");
        }

        const tokenID = payload.tokenID as string;

        const session = new TokenJWT(config);
        session.tokenID = tokenID;

        return { session, payload };
    }


    async signShort(payload: any,) {
        const expires = NowInSecond() + this.config.shortPeriodInSeconds!;
        const token = await sign({
            exp: expires,
            iat: NowInSecond(),
            iss: this.config.JWT_ISS,
            tokenID: this.tokenID,
            ...payload,
        }, this.config.JWT_SECRET);

        return { token, expires };
    }

    async signLong(payload: any,) {
        const expires = NowInSecond() + this.config.longPeriodInSeconds!;


        const token = await sign({
            exp: expires,
            iat: NowInSecond(),
            iss: this.config.JWT_ISS,
            tokenID: this.tokenID,
            ...payload,
        }, this.config.JWT_SECRET);
        return { token, expires };
    }
}