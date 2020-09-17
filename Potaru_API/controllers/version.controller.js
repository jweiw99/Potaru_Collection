// Import Faculty model
Version = require('../models/version.model');
// Handle find all actions
exports.findAll = (req, res) => {
    Version.aggregate([
        {
            $project: {
                _id: 0,
                'app': '$app',
                'lastUpdateDate': '$last_update_date'
            }
        }
    ]).then(version => {
        res.json({
            status: "Success",
            message: "Version retrieved successfully",
            data: version
        });
    }).catch(err => {
        res.status(500).json({
            status: "Error",
            message: err,
        });
    });
};

// Handle view app info
exports.findOne = (req, res) => {
    Version.aggregate([
        { $match: { 'app': req.params.name } },
        {
            $project: {
                _id: 0,
                'app': '$app',
                'lastUpdateDate': '$last_update_date'
            }
        }
    ]).then(version => {
        if (!version.length)
            res.json({
                status: "Success",
                message: "Version not found",
            });
        else
            res.json({
                status: "Success",
                message: "Version retrieved successfully",
                data: version
            });
    }).catch(err => {
        res.status(500).json({
            status: "Error",
            message: err,
        });
    });
};