const express = require('express');
const router = express.Router();
const eventSessionController = require('../controllers/eventSessionController');

// Rotte per gestire le sessioni di eventi

router.post('/', eventSessionController.createEventSession); // Crea una nuova sessione di evento
router.get('/post/:postId', eventSessionController.getEventSessions); // Ottieni le sessioni di eventi per un post specifico
router.put('/:id', eventSessionController.updateEventSession); // Aggiorna una sessione di evento
router.get('/user/:userId', eventSessionController.getUserConferences); 

module.exports = router;
