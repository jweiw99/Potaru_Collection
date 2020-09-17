var mongoose = require('mongoose');
// Setup schema
var staffSchema = mongoose.Schema({
    sid: Number,
    name: String,
    faculty_code: String,
    faculty: String,
    department: String,
    designation: String,
    administrative_post1: String,
    administrative_post2: String,
    tel_no1: String,
    tel_no2: String,
    roomno: String,
    email: String,
    qualification: String,
    pro_qualification: String,
    expertise: String,
    insertion_date: Number,
    last_update_date: Number,
}, { collection: 'Staff_Directory' });
// Export staff model
module.exports = mongoose.model('StaffDir', staffSchema);