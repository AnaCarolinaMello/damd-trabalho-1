const { app } = require('@azure/functions');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../../../damd-17984-firebase-adminsdk-fbsvc-defc6c26b2.json');

// Inicializa o Firebase
initializeApp({
  credential: cert(serviceAccount),
  databaseURL: 'https://damd-serverless-main.firebaseio.com',
});

const db = getFirestore();

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
