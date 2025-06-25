const { app } = require('@azure/functions');
const { db } = require('../firebase');

app.http('update-notification', {
    methods: ['PUT'],
    authLevel: 'anonymous',
    route: 'update-notification/{id}',
    handler: async (request, context) => {
        try {
            const id = request.params.id;
            
            if (!id) {
                return {
                    status: 400,
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        error: 'ID is required',
                    }),
                };
            }

            console.log('Updating notification with ID:', id);

            const docRef = db.collection('notifications').doc(id);
            await docRef.update({ sent: true });

            console.log('Notification updated successfully');

            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: 'Notification updated successfully',
                    id: id
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
