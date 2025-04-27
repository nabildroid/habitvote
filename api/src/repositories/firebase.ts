import Admin from 'firebase-admin';


export const Firebase =
    Admin.apps?.find((a: any) => a?.name == "main") ??
    Admin.initializeApp(
        {
            credential: process.env.FIREBASE_SERVICE_ACCOUNT
                ? Admin.credential.cert(
                    JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
                )
                : Admin.credential.applicationDefault(),
        },
        "main"
    );