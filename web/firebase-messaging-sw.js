importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts(
  "https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js"
);

firebase.initializeApp({
    apiKey: "AIzaSyC2cn9k4bOJ5TGRNFlj-XSkKdDPrKC8gEY",
    authDomain: "insta-d9db8.firebaseapp.com",
    projectId: "insta-d9db8",
    storageBucket: "insta-d9db8.appspot.com",
    messagingSenderId: "944785097371",
    appId: "1:944785097371:web:864ed0e5ae67bbd1b43c3e",
    measurementId: "G-9WSD8HL1FQ",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
