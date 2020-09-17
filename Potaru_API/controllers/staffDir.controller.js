// Import Staff Directory model
StaffDir = require('../models/staffDir.model');
// Handle index actions
exports.findAll = (req, res) => {
    StaffDir.aggregate([
        {
            $project: {
                _id: 0,
                'sid': '$sid',
                'name': '$name',
                'facultyCode': '$faculty_code',
                'faculty': '$faculty',
                'department': '$department',
                'designation': '$designation',
                'administrativePost1': '$administrative_post1',
                'administrativePost2': '$administrative_post2',
                'roomNo': '$roomno',
                'telNo1': '$tel_no1',
                'telNo2': '$tel_no2',
                'email': '$email',
                'qualification': '$qualification',
                'proQualification': '$pro_qualification',
                'expertise': '$expertise'
            }
        }
    ]).then(staffDir => {
        res.json({
            status: "Success",
            message: "Staff Directory retrieved successfully",
            data: staffDir
        });
    }).catch(err => {
        res.status(500).json({
            status: "Error",
            message: err,
        });
    });
};
// Handle view staff info
exports.findOne = (req, res) => {
    StaffDir.aggregate([
        { $match: { 'name': { $regex: '.*' + req.params.name + '.*', $options: 'i' } } },
        {
            $project: {
                _id: 0,
                'sid': '$sid',
                'name': '$name',
                'facultyCode': '$faculty_code',
                'faculty': '$faculty',
                'department': '$department',
                'designation': '$designation',
                'administrativePost1': '$administrative_post1',
                'administrativePost2': '$administrative_post2',
                'roomNo': '$roomno',
                'telNo1': '$tel_no1',
                'telNo2': '$tel_no2',
                'email': '$email',
                'qualification': '$qualification',
                'proQualification': '$pro_qualification',
                'expertise': '$expertise'
            }
        }
    ]).then(staffDir => {
        if (!staffDir.length)
            res.json({
                status: "Success",
                message: "Staff not found",
            });
        else
            res.json({
                status: "Success",
                message: "Staff retrieved successfully",
                data: staffDir
            });
    }).catch(err => {
        res.status(500).json({
            status: "Error",
            message: err,
        });
    });
};