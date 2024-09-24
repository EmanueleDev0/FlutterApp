const db = require('../models/db');

exports.getNotificationsForUser = async (req, res) => {
  const { userId } = req.params;

  try {
    const [rows] = await db.query(
      'SELECT * FROM notifications WHERE userId = ? ORDER BY date DESC',
      [userId]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching notifications', error: error.message });
  }
};

exports.createNotification = async (req, res) => {
  const {
    userId,
    title,
    message,
    date,
    type,
    postId,
    requesterId,
    status
  } = req.body;

  try {
    await db.query(
      'INSERT INTO notifications (userId, title, message, date, type, postId, requesterId, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [userId, title, message, date, type, postId, requesterId, status]
    );
    res.status(201).json({ message: 'Notification created successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error creating notification', error: error.message });
  }
};

exports.deleteNotification = async (req, res) => {
  const { id } = req.params;

  try {
    await db.query(
      'DELETE FROM notifications WHERE id = ?',
      [id]
    );
    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting notification', error: error.message });
  }
};