importScripts("https://www.gstatic.com/firebasejs/9.6.11/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.11/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyDSdJrQSIm29ZCd62AwGRR6HXmtrFBDx7k",
  authDomain: "healme-820ba.firebaseapp.com",
  projectId: "healme-820ba",
  storageBucket: "healme-820ba.firebasestorage.app",
  messagingSenderId: "349525324088",
  appId: "1:349525324088:web:8773e49681696213db11cd"
};

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  });
});
