const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');

// Rotte per gestire le notifiche
router.get('/user/:userId', notificationController.getNotificationsForUser); // Ottieni notifiche per utente
router.post('/', notificationController.createNotification); // Crea una nuova notifica
router.delete('/:id', notificationController.deleteNotification); // Elimina una notifica

module.exports = router;
