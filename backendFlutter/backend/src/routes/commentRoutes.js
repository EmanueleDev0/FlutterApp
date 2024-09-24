const express = require('express');
const router = express.Router();
const commentController = require('../controllers/commentController');

// Rotte per gestire i commenti
router.post('/', commentController.createComment); // Crea un nuovo commento
router.get('/post/:postId', commentController.getCommentsForPost); // Ottieni i commenti per un post specifico

module.exports = router;