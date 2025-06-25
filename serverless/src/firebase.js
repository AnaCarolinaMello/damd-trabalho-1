const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../../damd-17984-firebase-adminsdk-fbsvc-defc6c26b2.json');

// Initialize Firebase only if no apps exist
if (getApps().length === 0) {
    initializeApp({
        credential: cert(serviceAccount),
        databaseURL: 'https://damd-serverless-main.firebaseio.com'
    });
}

const db = getFirestore();

module.exports = { db }; 