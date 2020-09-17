// Filename: api-routes.js
// Initialize express router
let router = require('express').Router();
// Set default API response
router.get('/', function (req, res) {
    res.send('Potaru_API')
});

// Import version controller
var versionController = require('./controllers/version.controller');
// staff routes
router.route('/version')
    .get(versionController.findAll)
router.route('/version/:name')
    .get(versionController.findOne)

// Import staff controller
var staffDirController = require('./controllers/staffDir.controller');
// staff routes
router.route('/staff')
    .get(staffDirController.findAll)
router.route('/staff/:name')
    .get(staffDirController.findOne)

// Import faculty controller
var facultyController = require('./controllers/faculty.controller');
// faculty routes
router.route('/faculty')
    .get(facultyController.findAll)

// Import timetable controller
var timetableController = require('./controllers/timetable.controller');
// timetable routes
router.route('/timetable')
    .post(timetableController.getTimetable)
// timetable image routes
router.route('/timetableImage')
    .post(timetableController.getTimetableImage)

// Export API routes
module.exports = router;