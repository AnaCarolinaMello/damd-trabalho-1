const { app } = require('@azure/functions');
const { db } = require('../firebase');

app.http('mark-notification-sent-api', {
    methods: ['PUT'],
    authLevel: 'anonymous',
    route: 'notifications/{notificationId}/mark-sent',
    handler: async (request, context) => {
        try {
            const notificationId = request.params.notificationId;

            if (!notificationId) {
                return {
                    status: 400,
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        error: 'notificationId is required',
                    }),
                };
            }

            console.log('Marking notification as sent:', notificationId);

            const notificationRef = db.collection('notifications').doc(notificationId);

            // Check if document exists
            const doc = await notificationRef.get();
            if (!doc.exists) {
                return {
                    status: 404,
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        error: 'Notification not found',
                    }),
                };
            }

            // Update the sent field to true
            await notificationRef.update({
                sent: true
            });


            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: 'Notification marked as sent',
                    notificationId: notificationId
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