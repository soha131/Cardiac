var admin = require("firebase-admin");

var serviceAccount = require("./assets/firebase-service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});