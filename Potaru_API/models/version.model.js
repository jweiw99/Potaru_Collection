var mongoose = require('mongoose');
// Setup schema
var versionSchema = mongoose.Schema({
    app: { type: String, required: true },
    last_update_date: { type: Number },
}, { collection: 'Version' });
// Export faculty model
module.exports = mongoose.model('Version', versionSchema);
