import { Firebase } from "./firebase";


// Cache for notification tokens
let tokenCache: { [key: string]: string } | null = null;
let tokenCacheTimestamp: number = 0;
const CACHE_DURATION_MS = 5 * 60 * 1000; // 5 minutes in milliseconds

export async function getNotificationTokens(): Promise<{ [key: string]: string }> {
    const currentTime = Date.now();
    
    // Check if cache is still valid and not empty
    if (
        tokenCache && 
        Object.keys(tokenCache).length > 0 && 
        (currentTime - tokenCacheTimestamp) < CACHE_DURATION_MS
    ) {
        return tokenCache;
    }
    
    // Cache is invalid, empty, or doesn't exist, query Firestore
    const query = await Firebase.firestore().collection("config").doc("notifications").get();
    const data = query.data();

    if (!data) {
        tokenCache = {};
    } else {
        tokenCache = data as { [key: string]: string };
    }
    
    // Update cache timestamp
    tokenCacheTimestamp = currentTime;
    
    return tokenCache;
}