const db = require('../models/db');
const userController = require('./userController'); 

exports.insertQuestion = async (req, res) => {
  const { sessionId, userId, question } = req.body;

  console.log('Received request to insert question:', { sessionId, userId, question });

  try {
    console.log('Attempting to find user with ID:', userId);
    const user = await userController.findUserById(userId);
    
    if (!user) {
      console.log('User not found for ID:', userId);
      return res.status(404).json({ message: 'User not found' });
    }
    
    console.log('User found:', user);
    const userName = user.name || '';
    const userSurname = user.surname || '';

    console.log('Inserting question into database');
    await db.query(
      `INSERT INTO questions (session_id, user_id, user_name, user_surname, question, timestamp) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [sessionId, userId, userName, userSurname, question, new Date().toISOString()]
    );

    console.log('Question inserted successfully');
    res.status(201).json({ message: 'Question inserted successfully' });
  } catch (error) {
    console.error('Error in insertQuestion:', error);
    res.status(500).json({ message: 'Error inserting question', error: error.message });
  }
};

exports.getQuestionsForSession = async (req, res) => {
  const { sessionId } = req.params;

  try {
    const [rows] = await db.query('SELECT * FROM questions WHERE session_id = ?', [sessionId]);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving questions', error: error.message });
  }
};
