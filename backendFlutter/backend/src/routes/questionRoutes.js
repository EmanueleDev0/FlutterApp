const express = require('express');
const router = express.Router();
const questionController = require('../controllers/questionController');

// Rotte per gestire le domande
router.post('/', questionController.insertQuestion); // Inserisci una nuova domanda
router.get('/session/:sessionId', questionController.getQuestionsForSession); // Ottieni domande per sessione

module.exports = router;