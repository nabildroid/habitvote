import axios from 'axios';

const client = axios.create({
    baseURL: process.env.UPSTASH_REDIS_URL,
    headers: {
        Authorization: `Bearer ${process.env.UPSTASH_REDIS_TOKEN}`,
    },
});


export async function redis(path: string) {
    const data = await client.get(path);

    if (data.status !== 200) {
        throw new Error(`Error fetching data from Upstash: ${data.statusText}`);
    }
    return data.data.result;
}