const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Rotte per gestire gli utenti
router.post('/', userController.createUser); // Crea un nuovo utente
router.post('/login', userController.login);
router.get('/email/:email', userController.getUser); // Ottieni utente per email
router.get('/:userId', userController.getUserById); // Ottieni utente per ID
router.delete('/:userId', userController.deleteUser); // Elimina un utente per ID
router.put('/:userId/change-password', userController.changePassword); // Cambia la password di un utente

module.exports = router;