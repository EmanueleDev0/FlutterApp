const cron = require('node-cron');
const postController = require('./src/controllers/postController');

// Funzione per eseguire deleteOldPosts
const runDeleteOldPosts = async () => {
  try {
    await postController.deleteOldPosts({}, { json: () => console.log('Old posts deleted successfully') });
    console.log('Scheduled job: deleteOldPosts completed successfully');
  } catch (error) {
    console.error('Scheduled job: deleteOldPosts failed:', error);
  }
};

// Schedula il job per essere eseguito ogni giorno a mezzanotte
const scheduleDeleteOldPosts = () => {
  cron.schedule('0 0 * * *', () => {
    console.log('Running scheduled job: deleteOldPosts');
    runDeleteOldPosts();
  });
};

module.exports = {
  scheduleDeleteOldPosts
};