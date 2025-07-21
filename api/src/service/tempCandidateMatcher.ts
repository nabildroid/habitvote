
/// this will be used to match candidates for a habit
// will be removed later

import { redis } from "../repositories/upstash";



export function addCandidate(data: {
    habitId: string;
    candidateId: string;
}) {
    // add the candidate to the habit
    return redis(`sadd/candidats/${data.candidateId + ":" + data.habitId}`);
}


export async function getAllCandidates() {
    // get all candidates for a habit
    const data = (await redis(`smembers/candidats`)) as string[];

    return data.map((item) => {
        const [candidateId, habitId] = item.split(":");
        return {
            candidateId,
            habitId,
        };
    });
}


