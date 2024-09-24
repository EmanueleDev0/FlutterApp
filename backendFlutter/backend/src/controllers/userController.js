const db = require('../models/db');
const bcrypt = require('bcrypt');

exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length > 0) {
      const user = rows[0];
      const match = await bcrypt.compare(password, user.password);
      if (match) {
        res.json({ id: user.id, name: user.name, surname: user.surname, email: user.email, organization: user.organization });
      } else {
        res.status(401).json({ message: 'Invalid credentials' });
      }
    } else {
      res.status(401).json({ message: 'Invalid credentials' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error during login', error: error.message });
  }
};

exports.createUser = async (req, res) => {
  const { name, surname, email, password, organization } = req.body;
  try {
    const [result] = await db.query(
      'INSERT INTO users (name, surname, email, password, organization) VALUES (?, ?, ?, ?, ?)',
      [name, surname, email, password, organization]
    );
    res.status(201).json({ id: result.insertId, name, surname, email, organization });
  } catch (error) {
    console.error('Error in createUser:', error);
    res.status(500).json({ message: 'Error creating user', error: error.message });
  }
};

exports.getUser = async (req, res) => {
  const { email } = req.params;
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length > 0) {
      const user = rows[0];
      res.json({ id: user.id, name: user.name, surname: user.surname, email: user.email, organization: user.organization });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving user', error: error.message });
  }
};

exports.deleteUser = async (req, res) => {
  const { userId } = req.params;
  console.log(`Attempting to delete user with ID: ${userId}`);
  
  let connection;
  try {
    connection = await db.getConnection();
    console.log('Database connection established');
    
    // Inizia una transazione
    await connection.beginTransaction();
    console.log('Transaction begun');

    // Funzione di utilità per eseguire e loggare le query
    const executeQuery = async (query, params) => {
      console.log(`Executing query: ${query}`);
      const [result] = await connection.query(query, params);
      console.log(`Query completed. Affected rows: ${result.affectedRows}`);
      return result;
    };

    // 1. Elimina le domande (questions) associate alle sessioni degli eventi dell'utente
    await executeQuery(`
      DELETE q FROM questions q
      INNER JOIN event_sessions es ON q.session_id = es.id
      INNER JOIN posts p ON es.post_id = p.id
      WHERE p.author_id = ?
    `, [userId]);

    // 2. Elimina le sessioni degli eventi (event_sessions) associate ai post dell'utente
    await executeQuery(`
      DELETE es FROM event_sessions es
      INNER JOIN posts p ON es.post_id = p.id
      WHERE p.author_id = ?
    `, [userId]);

    // 3. Elimina i commenti dell'utente
    await executeQuery('DELETE FROM comments WHERE user_id = ?', [userId]);

    // 4. Elimina le domande create dall'utente (se ce ne sono)
    await executeQuery('DELETE FROM questions WHERE user_id = ?', [userId]);

    // 5. Elimina le notifiche dell'utente
    await executeQuery('DELETE FROM notifications WHERE userId = ?', [userId]);

    // 6. Elimina le partecipazioni agli eventi dell'utente
    await executeQuery('DELETE FROM event_participations WHERE user_id = ?', [userId]);

    // 7. Elimina le partecipazioni agli eventi associati ai post dell'utente
    await executeQuery(`
      DELETE ep FROM event_participations ep
      INNER JOIN posts p ON ep.post_id = p.id
      WHERE p.author_id = ?
    `, [userId]);

    // 8. Elimina i post dell'utente
    await executeQuery('DELETE FROM posts WHERE author_id = ?', [userId]);

    // 9. Infine, elimina l'utente
    const result = await executeQuery('DELETE FROM users WHERE id = ?', [userId]);

    // Conferma la transazione
    await connection.commit();
    console.log('Transaction committed');

    if (result.affectedRows > 0) {
      console.log(`User ${userId} and all related data deleted successfully`);
      res.json({ message: 'User and all related data deleted successfully' });
    } else {
      console.log(`No user found with ID ${userId}`);
      await connection.rollback();
      console.log('Transaction rolled back due to user not found');
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error in deleteUser:', error);
    if (connection) {
      await connection.rollback();
      console.log('Transaction rolled back due to error');
    }
    res.status(500).json({ 
      message: 'Error deleting user', 
      error: error.message,
      stack: error.stack
    });
  } finally {
    if (connection) {
      connection.release();
      console.log('Database connection released');
    }
  }
};

exports.getUserById = async (req, res) => {
  const { userId } = req.params;
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    if (rows.length > 0) {
      const user = rows[0];
      res.json({ id: user.id, name: user.name, surname: user.surname, email: user.email, organization: user.organization });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving user', error: error.message });
  }
};

exports.findUserById = async (userId) => {
  console.log('Attempting to find user with ID:', userId);
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    console.log('Query result:', rows);
    if (rows.length > 0) {
      console.log('User found:', rows[0]);
      return rows[0];
    } else {
      console.log('No user found with ID:', userId);
      return null;
    }
  } catch (error) {
    console.error('Error retrieving user:', error);
    throw error;
  }
};

exports.changePassword = async (req, res) => {
  const { userId } = req.params;
  const { currentPassword, newPassword } = req.body;
  try {
    // Recupera l'utente dal database
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    if (rows.length > 0) {
      const user = rows[0];
      
      // Verifica la password corrente
      const isMatch = await bcrypt.compare(currentPassword, user.password);
      
      if (isMatch) {
        // Hash della nuova password
        const hashedNewPassword = await bcrypt.hash(newPassword, 10);
        
        // Aggiorna la password nel database
        await db.query('UPDATE users SET password = ? WHERE id = ?', [hashedNewPassword, userId]);
        res.json({ message: 'Password changed successfully' });
      } else {
        res.status(400).json({ message: 'Current password is incorrect' });
      }
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error changing password', error: error.message });
  }
};