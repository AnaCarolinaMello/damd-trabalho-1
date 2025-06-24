const { app } = require('@azure/functions');

const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const serviceAccount = require('../../../damd-17984-firebase-adminsdk-fbsvc-defc6c26b2.json')
initializeApp(
    {
        credential: cert(serviceAccount),
        databaseURL: 'https://damd-serverless-main.firebaseio.com'
    }
);

const db = getFirestore();


app.http('notifications-api', {
    methods: ['POST'],
    authLevel: 'anonymous',
    route: 'create-notification',
    handler: async (request, context) => {
        try {
            const body = await request.json();

            const docRef = db.collection('notifications').doc();

            const notification = {
                clientId: body.clientId,
                message: body.message,
                orderId: body.orderId,
                sent: false,
                title: body.title,
            };

            const result = await docRef.set(notification);

            console.log("result", result);
            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    notification,
                }),
            };
        } catch (error) {
            console.error('Function error:', error);
            return {
                status: 500,
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    error: error.message,
                }),
            };
        }
    },
});
