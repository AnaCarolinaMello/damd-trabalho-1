const { app } = require('@azure/functions');
const { db } = require('../firebase');

app.http('update-notification', {
    methods: ['PUT'],
    authLevel: 'anonymous',
    route: 'update-notification/{id}', // ID
    handler: async (request, context) => {
        const id = context.request.params.id;

        if (!id) {
            return {
                status: 400,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ error: 'ID da notificação não fornecido.' }),
            };
        }

        try {
            const docRef = db.collection('notifications').doc(id);

            // Check if document exists
            const doc = await docRef.get();
            if (!doc.exists) {
                return {
                    status: 404,
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ error: 'Notificação não encontrada.' }),
                };
            }

            await docRef.update({ sent: true });

            return {
                status: 200,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message: 'Notificação atualizada com sucesso.',
                    id,
                }),
            };
        } catch (error) {
            console.error('Erro ao atualizar notificação:', error);
            return {
                status: 500,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    error: 'Erro interno ao atualizar notificação.',
                }),
            };
        }
    },
});
