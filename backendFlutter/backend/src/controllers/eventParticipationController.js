const db = require('../models/db');

exports.isUserParticipating = async (req, res) => {
  const { userId, postId } = req.params;

  try {
    const [rows] = await db.query(
      'SELECT * FROM event_participations WHERE user_id = ? AND post_id = ?',
      [userId, postId]
    );
    res.json({ participating: rows.length > 0 });
  } catch (error) {
    res.status(500).json({ message: 'Error checking participation', error: error.message });
  }
};

exports.addParticipation = async (req, res) => {
  const { userId, postId } = req.body;

  try {
    await db.query(
      'INSERT INTO event_participations (user_id, post_id) VALUES (?, ?)',
      [userId, postId]
    );
    res.status(201).json({ message: 'Participation added successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error adding participation', error: error.message });
  }
};

exports.removeParticipation = async (req, res) => {
  const { userId, postId } = req.params;

  try {
    await db.query(
      'DELETE FROM event_participations WHERE user_id = ? AND post_id = ?',
      [userId, postId]
    );
    res.json({ message: 'Participation removed successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error removing participation', error: error.message });
  }
};

exports.requestParticipation = async (req, res) => {
  const { userId, postId } = req.body;

  try {
    await db.query(
      'INSERT INTO event_participations (user_id, post_id, status) VALUES (?, ?, ?)',
      [userId, postId, 'pending']
    );
    res.status(201).json({ message: 'Participation requested successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error requesting participation', error: error.message });
  }
};

exports.updateParticipationStatus = async (req, res) => {
  const { userId, postId } = req.params;
  const { status } = req.body;

  try {
    await db.query(
      'UPDATE event_participations SET status = ? WHERE user_id = ? AND post_id = ?',
      [status, userId, postId]
    );
    res.json({ message: 'Participation status updated successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error updating participation status', error: error.message });
  }
};

exports.getParticipationStatus = async (req, res) => {
  const { userId, postId } = req.params;

  try {
    const [rows] = await db.query(
      'SELECT * FROM event_participations WHERE user_id = ? AND post_id = ?',
      [userId, postId]
    );

    if (rows.length > 0) {
      res.json({ status: rows[0].status });
    } else {
      res.json({ status: 'not_participating' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving participation status', error: error.message });
  }
};

exports.addSpeakerParticipation = async (req, res) => {
  console.log('Received request to add speaker participation:', req.body);
  const { email, postId } = req.body;

  try {
    const [userResults] = await db.query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (userResults.length > 0) {
      const userId = userResults[0].id;

      const [participationResults] = await db.query(
        'SELECT * FROM event_participations WHERE user_id = ? AND post_id = ?',
        [userId, postId]
      );

      if (participationResults.length === 0) {
        await db.query(
          'INSERT INTO event_participations (user_id, post_id, status) VALUES (?, ?, ?)',
          [userId, postId, 'accepted']
        );
      } else {
        await db.query(
          'UPDATE event_participations SET status = ? WHERE user_id = ? AND post_id = ?',
          ['accepted', userId, postId]
        );
      }

      res.status(201).json({ message: 'Speaker participation handled successfully' });
    } else {
      res.status(404).json({ message: 'User not found with the provided email' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error handling speaker participation', error: error.message });
  }
};

exports.acceptParticipation = async (req, res) => {
  const { requesterId, postId } = req.params;
  const { status } = req.body;

  try {
    await db.query(
      'UPDATE event_participations SET status = ? WHERE user_id = ? AND post_id = ?',
      [status, requesterId, postId]
    );
    res.json({ message: 'Participation status accepted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error accepting participation', error: error.message });
  }
};
