
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyAWXFfbPWRlb2gwMtX-w6L9QhrKJZ-2uJg',
    appId: '1:1052735402009:web:0bcd12431640976f147a88',
    messagingSenderId: '1052735402009',
    projectId: 'escala-msg',
    authDomain: 'escala-msg.firebaseapp.com',
    storageBucket: 'escala-msg.firebasestorage.app',
    measurementId: 'G-EL1LDD5DZ6',
});

const messaging = firebase.messaging();
