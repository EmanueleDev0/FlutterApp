const express = require('express');
const router = express.Router();
const postController = require('../controllers/postController');

// Rotte per gestire i post
router.post('/', postController.createPost); // Crea un nuovo post
router.put('/:id', postController.updatePost); // Aggiorna un post per ID
router.delete('/:postId', postController.deletePost); // Elimina un post per ID
router.get('/user/:userId', postController.getPostsByUser); // Ottieni post di un utente per ID
router.get('/', postController.getAllPosts); // Ottieni tutti i post
router.delete('/old', postController.deleteOldPosts); // Elimina i post vecchi
router.get('/:id', postController.getPostById); // Ottieni un post specifico per ID

module.exports = router;
