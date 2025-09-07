// web/firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/10.8.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAz9Vzmz-K5Emjld8TP-5Y3_dLLL-E2ovM",
  authDomain: "nubmed-1ab30.firebaseapp.com",
  projectId: "nubmed-1ab30",
  storageBucket: "nubmed-1ab30.firebasestorage.app",
  messagingSenderId: "268901918998",
  appId: "1:268901918998:web:29dd6489687ebc38098837",
  measurementId: "G-MTX9N5XJDT"
});

const messaging = firebase.messaging();
