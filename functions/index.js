const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

const fcm = admin.messaging();

exports.senddevices = functions.firestore
  .document("notification/{id}")
  .onCreate(async (snapshot) => {
    const name = snapshot.get("username");
    const uid = snapshot.get("uid");
    const token = snapshot.get("token");

    const payload = {
      notification: {
        title: "NOTIFICATION ",
        body: name + " add a new post ",
        sound: "default",
      },
    };
    try{
        const response = await admin.messaging().sendToDevice(token, payload);
    }catch (error){

    }
    return admin.messaging().sendToDevice(token, payload);;
  }); 
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
