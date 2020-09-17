// Import Faculty model
Faculty = require('../models/faculty.model');
// Handle find all actions
exports.findAll = (req, res) => {
    Faculty.find({},
        '-_id name code'
    ).sort({'name': 'asc'}).then(faculty => {
        res.json({
            status: "Success",
            message: "Faculty retrieved successfully",
            data: faculty
        });
    }).catch(err => {
        res.status(500).json({
            status: "Error",
            message: err,
        });
    });
};