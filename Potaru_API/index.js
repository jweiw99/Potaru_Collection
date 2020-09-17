require('dotenv').config()

let express = require('express')
let bodyParser = require('body-parser');
let mongoose = require('mongoose');

// Initialize the app
let app = express();

// Configure bodyparser to handle post requests
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

// Import routes
let apiRoutes = require("./api-routes")
// Use Api routes in the App
app.use('/api', apiRoutes)

// Send message for default URL
app.get('/', (req, res) => res.send('Potaru_API'));

// Setup server port
const PORT = process.env.PORT;

// Connect to Mongoose and set connection variable
mongoose.connect(`mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_URL}/${process.env.DB_NAME}`,
    {
        useNewUrlParser: true,
        useFindAndModify: false,
        useCreateIndex: true,
        useUnifiedTopology: true
    }).then(() => {
        //var db = mongoose.connection;
        console.log('Connection to database established')

        // Launch app to listen to specified port
        app.listen(PORT, function () {
            console.log("Running FYP_API on port " + PORT);
        });

    }).catch(err => {
        console.log(`db error ${err.message}`);
    });