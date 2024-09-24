const express = require('express');
const router = express.Router();
const eventParticipationController = require('../controllers/eventParticipationController');

// Rotte per gestire le partecipazioni agli eventi
router.get('/:userId/:postId', eventParticipationController.isUserParticipating); // Controlla se l'utente partecipa
router.post('/', eventParticipationController.addParticipation); // Aggiungi una partecipazione
router.delete('/user/:userId/post/:postId', eventParticipationController.removeParticipation); // Rimuovi una partecipazione
router.post('/request', eventParticipationController.requestParticipation); // Richiedi una partecipazione
router.put('/:userId/:postId/status', eventParticipationController.updateParticipationStatus); // Aggiorna lo stato di partecipazione
router.get('/:userId/:postId/status', eventParticipationController.getParticipationStatus); // Ottieni stato di partecipazione
router.post('/speaker', eventParticipationController.addSpeakerParticipation); // Aggiungi partecipazione come relatore
router.put('/accept/:requesterId/:postId', eventParticipationController.acceptParticipation); // Accetta una partecipazione

module.exports = router;
