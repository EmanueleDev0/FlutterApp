const db = require('../models/db');

exports.createEventSession = async (req, res) => {
  const { postId, title, description, sessionDate, startTime, endTime, location } = req.body;

  console.log('DEBUG Server: Iniziando la creazione della sessione evento');
  console.log('DEBUG Server: Dati ricevuti:', { postId, title, description, sessionDate, startTime, endTime, location });

  try {
    const [result] = await db.query(
      `INSERT INTO event_sessions (post_id, title, description, session_date, start_time, end_time, location) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [postId, title, description, sessionDate, startTime, endTime, location]
    );
    console.log('DEBUG Server: Sessione creata con successo. ID:', result.insertId);
    res.status(201).json({ id: result.insertId });
  } catch (error) {
    console.error('DEBUG Server: Errore durante la creazione della sessione evento:', error);
    res.status(500).json({ message: 'Error creating event session', error: error.message });
  }
};

exports.getEventSessions = async (req, res) => {
  const { postId } = req.params;

  try {
    const [rows] = await db.query('SELECT * FROM event_sessions WHERE post_id = ?', [postId]);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving event sessions', error: error.message });
  }
};

exports.updateEventSession = async (req, res) => {
  const { id } = req.params;
  const { title, description, sessionDate, startTime, endTime, location } = req.body;

  try {
    const [result] = await db.query(
      `UPDATE event_sessions SET title = ?, description = ?, session_date = ?, 
        start_time = ?, end_time = ?, location = ? WHERE id = ?`,
      [title, description, sessionDate, startTime, endTime, location, id]
    );

    if (result.affectedRows > 0) {
      res.json({ message: 'Event session updated successfully' });
    } else {
      res.status(404).json({ message: 'Event session not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error updating event session', error: error.message });
  }
};

exports.getUserConferences = async (req, res) => {
  const { userId } = req.params;

  try {
    const [rows] = await db.query(`
      SELECT es.* 
      FROM event_sessions es
      LEFT JOIN event_participations ep ON es.post_id = ep.post_id AND ep.user_id = ?
      INNER JOIN posts p ON es.post_id = p.id
      WHERE (ep.status = 'accepted' OR p.author_id = ?)
      ORDER BY es.session_date ASC
    `, [userId, userId]);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving user conferences', error: error.message });
  }
};