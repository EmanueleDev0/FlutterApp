const db = require('../models/db');

exports.createComment = async (req, res) => {
  const { post_id, user_id, user_name, content } = req.body;

  console.log('Received comment data:', req.body);  // Add this line to log the received data

  if (!post_id) {
    return res.status(400).json({ message: 'post_id is required' });
  }

  try {
    const [result] = await db.query(
      `INSERT INTO comments (post_id, user_id, user_name, content) 
       VALUES (?, ?, ?, ?)`,
      [post_id, user_id, user_name, content]
    );
    res.status(201).json({ id: result.insertId, post_id, user_id, user_name, content });
  } catch (error) {
    console.error('Error creating comment:', error);  // Add this line to log the error
    res.status(500).json({ message: 'Error creating comment', error: error.message });
  }
};

exports.getCommentsForPost = async (req, res) => {
  const { postId } = req.params;

  console.log(`Attempting to fetch comments for post ${postId}`);

  try {
    const [rows] = await db.query('SELECT * FROM comments WHERE post_id = ?', [postId]);
    console.log(`Retrieved ${rows.length} comments for post ${postId}`);
    res.json(rows);
  } catch (error) {
    console.error('Error retrieving comments:', error);
    res.status(500).json({ message: 'Error retrieving comments', error: error.message });
  }
};
