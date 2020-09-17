var mongoose = require('mongoose');
// Setup schema
var facultySchema = mongoose.Schema({
    code: { type: String, required: true },
    name: { type: String, required: true },
    insertion_date: { type: Date, default: Date.now },
    last_update_date: { type: Date, default: Date.now },
}, { collection: 'Faculty' });
// Export faculty model
module.exports = mongoose.model('Faculty', facultySchema);
