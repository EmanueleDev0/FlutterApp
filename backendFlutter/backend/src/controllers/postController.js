const db = require('../models/db');

exports.createPost = async (req, res) => {
  console.log('Ricevuta richiesta di creazione post:', req.body);
  
  const {
    title, image, description, start_date, end_date, location, author_id,
    author_name, author_organization, commentsEnabled, moderationEnabled
  } = req.body;

  try {
    console.log('Dati estratti dalla richiesta:', {
      title, description, start_date, end_date, location, author_id,
      author_name, author_organization, commentsEnabled, moderationEnabled
    });
    console.log('Immagine ricevuta:', image ? 'Sì' : 'No');

    const query = `INSERT INTO posts (title, image, description, start_date, end_date, location, 
      author_id, author_name, author_organization, commentsEnabled, moderationEnabled) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
    
    const values = [title, image, description, start_date, end_date, location, author_id,
      author_name, author_organization, commentsEnabled ? 1 : 0, moderationEnabled ? 1 : 0];

    console.log('Query SQL:', query);
    console.log('Valori per la query:', values.map(v => v === image ? 'IMAGE_DATA' : v));

    const [result] = await db.query(query, values);
    
    console.log('Risultato inserimento:', result);
    
    res.status(201).json({ id: result.insertId });
  } catch (error) {
    console.error('Errore durante la creazione del post:', error);
    res.status(500).json({ message: 'Error creating post', error: error.message, stack: error.stack });
  }
};

exports.updatePost = async (req, res) => {
  const { id } = req.params;
  const {
    title, image, description, start_date, end_date, location, authorName,
    authorOrganization, commentsEnabled, moderationEnabled
  } = req.body;

  console.log('Dati ricevuti per l\'aggiornamento:');
  console.log('ID:', id);
  console.log('Titolo:', title);
  console.log('Data inizio:', start_date);
  console.log('Data fine:', end_date);
  console.log('Luogo:', location);

  try {
    const [result] = await db.query(
      `UPDATE posts SET title = ?, image = ?, description = ?, start_date = ?, 
        end_date = ?, location = ?, author_name = ?, author_organization = ?, 
        commentsEnabled = ?, moderationEnabled = ? WHERE id = ?`,
      [title, image, description, start_date, end_date, location, authorName, authorOrganization,
        commentsEnabled ? 1 : 0, moderationEnabled ? 1 : 0, id]
    );

    console.log('Risultato query:', result);

    if (result.affectedRows > 0) {
      res.json({ message: 'Post updated successfully' });
    } else {
      res.status(404).json({ message: 'Post not found' });
    }
  } catch (error) {
    console.error('Errore durante l\'aggiornamento:', error);
    res.status(500).json({ message: 'Error updating post', error: error.message });
  }
};

exports.deletePost = async (req, res) => {
  const { postId } = req.params;
  
  let connection;
  try {
    connection = await db.getConnection();
    
    // Inizia una transazione
    await connection.beginTransaction();

    // Elimina tutti i record correlati nelle tabelle dipendenti
    await connection.query('DELETE FROM comments WHERE post_id = ?', [postId]);
    await connection.query('DELETE q FROM questions q INNER JOIN event_sessions s ON q.session_id = s.id WHERE s.post_id = ?', [postId]);
    await connection.query('DELETE FROM event_sessions WHERE post_id = ?', [postId]);
    await connection.query('DELETE FROM event_participations WHERE post_id = ?', [postId]);
    await connection.query('DELETE FROM notifications WHERE postId = ?', [postId]);
    
    // Infine, elimina il post
    const [result] = await connection.query('DELETE FROM posts WHERE id = ?', [postId]);
    
    // Conferma la transazione
    await connection.commit();

    if (result.affectedRows > 0) {
      res.json({ message: 'Post and all related data deleted successfully' });
    } else {
      await connection.rollback();
      res.status(404).json({ message: 'Post not found' });
    }
  } catch (error) {
    if (connection) await connection.rollback();
    console.error('Error deleting post:', error);
    res.status(500).json({ message: 'Error deleting post', error: error.message });
  } finally {
    if (connection) connection.release();
  }
};

exports.getPostById = async (req, res) => {
  const { id } = req.params;

  try {
    const [rows] = await db.query('SELECT * FROM posts WHERE id = ?', [id]);
    
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ message: 'Post not found' });
    }
  } catch (error) {
    console.error('Error retrieving post:', error);
    res.status(500).json({ message: 'Error retrieving post', error: error.message });
  }
};

exports.getPostsByUser = async (req, res) => {
  const { userId } = req.params;

  try {
    const [rows] = await db.query('SELECT * FROM posts WHERE author_id = ?', [userId]);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving posts', error: error.message });
  }
};

exports.getAllPosts = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM posts ORDER BY start_date DESC');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving posts', error: error.message });
  }
};

exports.deleteOldPosts = async (req, res) => {
  try {
    const [result] = await db.query('DELETE FROM posts WHERE end_date < CURDATE()');
    console.log(`Deleted ${result.affectedRows} old posts`);
    
    if (res) {
      res.json({ message: 'Old posts deleted successfully', deletedCount: result.affectedRows });
    }
  } catch (error) {
    console.error('Error deleting old posts:', error);
    if (res) {
      res.status(500).json({ message: 'Error deleting old posts', error: error.message });
    }
  }
};
