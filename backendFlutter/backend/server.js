const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;
const eventParticipationRoutes = require('./src/routes/eventParticipationRoutes');
const { scheduleDeleteOldPosts } = require('./scheduledJobs');

// Middleware per il logging delle richieste
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Configurazione CORS
app.use(cors({
  origin: '*', // In produzione, specificare i domini consentiti
  methods: ['GET', 'POST', 'DELETE', 'PUT', 'PATCH']
}));

app.use(express.json());

// Importa le routes
app.use('/api/users', require('./src/routes/userRoutes'));
app.use('/api/posts', require('./src/routes/postRoutes'));
app.use('/api/event-sessions', require('./src/routes/eventSessionRoutes'));
app.use('/api/comments', require('./src/routes/commentRoutes'));
app.use('/api/questions', require('./src/routes/questionRoutes'));
app.use('/api/event-participations', require('./src/routes/eventParticipationRoutes'));
console.log('Event participation routes loaded:', eventParticipationRoutes.stack.map(r => r.route.path));
app.use('/api/notifications', require('./src/routes/notificationRoutes'));

// Gestione degli errori globale
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// Verifica della connessione al database
const db = require('./src/models/db');

db.query('SELECT 1')
  .then(() => console.log('Database connection successful'))
  .catch(err => console.error('Database connection failed:', err));

scheduleDeleteOldPosts();

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

async function checkDatabaseConnection() {
  try {
    const connection = await db.getConnection();
    console.log('Successfully connected to the database.');
    console.log(`Connected to MySQL server on ${process.env.DB_HOST}:${process.env.DB_PORT || 3306}`);
    console.log(`Using database: ${process.env.DB_NAME}`);
    connection.release();
  } catch (error) {
    console.error('Failed to connect to the database:', error);
    process.exit(1);  
  }
}

checkDatabaseConnection();