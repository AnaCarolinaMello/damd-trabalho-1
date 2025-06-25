const { app } = require('@azure/functions');
const { db } = require('../firebase');

app.http('get-notifications', {
    methods: ['GET'],
    authLevel: 'anonymous',
    route: 'notifications/{clientId}',
    handler: async (request, context) => {
        try {
            const clientId = request.params.clientId;

            if (!clientId) {
                return {
                    status: 400,
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        error: 'clientId is required',
                    }),
                };
            }

            console.log('Searching for clientId:', clientId, 'type:', typeof clientId);

            const notificationsRef = db.collection('notifications');

            // Try both string and number clientId
            const clientIdAsString = String(clientId);
            const clientIdAsNumber = Number(clientId);

            console.log('clientIdAsString:', clientIdAsString);
            console.log('clientIdAsNumber:', clientIdAsNumber);

            // First try with string
            let query = notificationsRef
                .where('clientId', '==', clientIdAsString)
                .where('sent', '==', false);

            let snapshot = await query.get();
            console.log('String query results:', snapshot.size);

            // If no results, try with number
            if (snapshot.empty) {
                query = notificationsRef
                    .where('clientId', '==', clientIdAsNumber)
                    .where('sent', '==', false);

                snapshot = await query.get();
                console.log('Number query results:', snapshot.size);
            }

            const notifications = [];
            snapshot.forEach(doc => {
                const data = doc.data();
                console.log('Document data:', data);
                notifications.push({
                    id: doc.id,
                    ...data
                });
            });

            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    notifications,
                    count: notifications.length,
                    debug: {
                        searchedClientId: clientId,
                        searchedAsString: clientIdAsString,
                        searchedAsNumber: clientIdAsNumber
                    }
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