var request = require('request');
var Jimp = require('jimp');
var htmlToImage = require('node-html-to-image');

exports.getTimetable = (req, res) => {
    request.post({
        url: 'https://potaru-web.herokuapp.com/timetable/',
        form: { JSESSIONID: req.body.JSESSIONID },
        headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36',
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        method: 'POST'
    }, function (error, response, body) {
        if (!error && response.statusCode == 200) {
            content = JSON.parse(body);
            for (var i in content.semester) {
                content.semester[i] = JSON.parse(content.semester[i]);
            }
            for (var i in content.timetable) {
                content.timetable[i] = JSON.parse(content.timetable[i]);
            }
            for (var i in content.attendance) {
                content.attendance[i] = JSON.parse(content.attendance[i]);
            }
            for (var i in content.courseGrade) {
                content.courseGrade[i] = JSON.parse(content.courseGrade[i]);
            }
            for (var i in content.cgpa) {
                content.cgpa[i] = JSON.parse(content.cgpa[i]);
            }
            res.json({
                status: "Success",
                message: "Timetable retrieved successfully",
                data: content
            });
        } else {
            res.status(500).json({
                status: "Error",
                message: error,
            });
        }
    });
};

exports.getTimetableImage = async (req, res) => {
    var timetableContent = "";

    var reqBodyRow = JSON.parse(req.body.row);
    var reqBodyContent = JSON.parse(req.body.content);

    var weekDay = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var i = 0; i < 7; i++) {
        var rowspan = 1;
        if (weekDay[i] in reqBodyRow) rowspan = reqBodyRow[weekDay[i]];
        timetableContent += getWeekDayCourseContent(i, rowspan);
    }

    function getWeekDayCourseContent(weekdayNo, rowspan) {
        var content = `<tr align="center">
            <th class="day" rowspan="${rowspan}">${weekDay[weekdayNo]}</th>`;

        if (weekDay[weekdayNo] in reqBodyContent) {
            for (var row = 0; row < rowspan; row++) {
                if (row > 0) content += `</tr><tr>`;
                var skip = 0;
                for (var i = 0; i < 32; i++) {
                    if (i in reqBodyContent[weekDay[weekdayNo]][row]) {
                        var cssColor = "unit";
                        if (reqBodyContent[weekDay[weekdayNo]][row][i]['courseType'] == "E") cssColor = "exam";
                        var colspan = reqBodyContent[weekDay[weekdayNo]][row][i]['courseHrs'];
                        colspan = Math.round(colspan / 0.5);
                        content += `
                        <td valign="top" align="center" colspan="${colspan}" class="${cssColor}">
                            ${reqBodyContent[weekDay[weekdayNo]][row][i]['courseVenue']}<br>
                            <span id="unit">
                                ${reqBodyContent[weekDay[weekdayNo]][row][i]['courseName']}
                                (${reqBodyContent[weekDay[weekdayNo]][row][i]['courseType']})
                                (${reqBodyContent[weekDay[weekdayNo]][row][i]['courseGroup']})
                            </span><br>
                        </td>
                    `;
                        skip = i + colspan;
                    } else if (i < skip) {
                        continue;
                    } else {
                        content += `<td></td>`;
                    }
                }
            }
        } else {
            for (var i = 0; i < 32; i++) {
                content += "<td></td>";
            }
        }
        content += `</tr >`;
        return content;
    }

    var imageData = await htmlToImage({
        html: `
        <html>
        <head>
            <style>
                body {
                    width: 1000px;
                    height: 600px;
                }
                .tbltimetable {
                    position: absolute;
                    top: 8; 
                    bottom: 0; 
                    left: 8; 
                    right: 0;
                    border-collapse: collapse;
                    border: 1px solid #333;
                    height:100%;
                    width: 100%;
                    font-size: 8pt;
                }
                .tbltimetable th {
                    border: 1px dotted #666;
                    padding: 4px;
                    vertical-align: middle;
                }
                .tbltimetable th[scope=col] {
                    background-color: #70b0e0;
                    border-bottom: 2px solid #333;
                    border-right: 1px dotted #666;
                    color: #fff;
                    font-family: "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
                }
                .tbltimetable .col {
                    background-color: #70b0e0;
                    color: #fff;
                }
                .tbltimetable .day {
                    background-color: #faff93;
                }
                .tbltimetable .unit {
                    background-color: #E1EEB5;
                }
                .tbltimetable .exam {
                    background-color: #F0D0D0;
                }
                .tbltimetable td {
                    border: 1px dotted #666;
                    padding: 4px;
                    vertical-align: top;
                    font-size: 9pt;
                }
                #unit {
                    color: #0000CC;
                }
            </style>
        </head>

        <body>
            <table width="100%" height:"100%" align="center" cellpadding="0" cellspacing="0" class="tbltimetable">
                <tbody>
                    <tr valign="middle">
                        <th rowspan="2" width="50" scope="col">Day/Time</th>
                        <th colspan="2" class="col">
                            <div align="center">07:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">08:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">09:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">10:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">11:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">12:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">01:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">02:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">03:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">04:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">05:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">06:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">07:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">08:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">09:00</div>
                        </th>
                        <th colspan="2" class="col">
                            <div align="center">10:00</div>
                        </th>
                    </tr>
                    <tr>
                        <th colspan="2" scope="col">
                            <div align="center">08:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">09:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">10:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">11:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">12:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">01:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">02:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">03:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">04:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">05:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">06:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">07:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">08:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">09:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">10:00</div>
                        </th>
                        <th colspan="2" scope="col">
                            <div align="center">11:00</div>
                        </th>
                    </tr>
                    ${timetableContent}
                </tbody>
            </table>
        </body>
        </html>`
    });
    res.writeHead(200, { 'Content-Type': 'image/png' });

    await Jimp.read(imageData, (err, image) => {
        image.rotate(-90).getBuffer(Jimp.MIME_PNG, function (err, src) {
            res.end(src, 'binary');
        });
    });

};

