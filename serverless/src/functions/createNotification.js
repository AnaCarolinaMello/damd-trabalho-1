const { app } = require('@azure/functions');
const { db } = require('../firebase');


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
