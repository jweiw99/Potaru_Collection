from bs4 import BeautifulSoup
from urllib import request, parse
from bson.objectid import ObjectId
from pymongo import MongoClient
from datetime import timedelta, datetime
import requests
import json
import flask
import re
import os
import time
import math

StudentID = ""
StudentEmail = ""
now = int(time.time())
db_user = ''
db_pass = ''


class Semester:

    def __init__(self, session, start_date, end_date, total_week):
        self.session = session
        self.startDate = start_date
        self.endDate = end_date
        self.totalWeek = total_week

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True)


class Timetable:

    def __init__(self, course_code, course_name, course_type, course_group, course_date, startDate, course_starttime, course_endtime, course_hrs, course_venue, lecturer_id, lecturer_name, remind, courseStartDate, recurring):
        self.courseCode = course_code
        self.courseName = course_name
        self.courseType = course_type
        self.courseGroup = course_group
        self.courseDate = course_date
        self.startDate = startDate
        self.courseStartTime = course_starttime
        self.courseEndTime = course_endtime
        self.courseHrs = course_hrs
        self.courseVenue = course_venue
        self.lecturerID = lecturer_id
        self.lecturerName = lecturer_name
        self.remind = remind
        self.courseStartDate = courseStartDate
        self.recurring = recurring

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True)


class SubjectGrade:

    def __init__(self, session, course_code, course_name, course_type, grade, status):
        self.session = session
        self.courseCode = course_code
        self.courseName = course_name
        self.courseType = course_type
        self.status = status
        self.grade = grade

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True)


class SemCGPA:

    def __init__(self, session, gpa, cgpa, creditHrs):
        self.session = session
        self.gpa = gpa
        self.cgpa = cgpa
        self.creditHrs = creditHrs

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True)


class Attendance:

    def __init__(self, session, course_code, course_type, courseDate, courseStartTime, attendance):
        self.session = session
        self.courseCode = course_code
        self.courseType = course_type
        self.courseDate = courseDate
        self.courseStartTime = courseStartTime
        self.attendance = attendance

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True)


class Lecturer:

    def __init__(self, lecturer_id, roomNo):
        self.lecturer_id = lecturer_id
        self.roomNo = roomNo


def monthToNum(shortMonth):
    return{
        'JANUARY': '01',
        'FEBRUARY': '02',
        'MARCH': '03',
        'APRIL': '04',
        'MAY': '05',
        'JUNE': '06',
        'JULY': '07',
        'AUGUST': '08',
        'SEPTEMBER': '09',
        'OCTOBER': '10',
        'NOVEMBER': '11',
        'DECEMBER': '12'
    }[shortMonth]


def dayToNum(day):
    return{
        'Mon': 0,
        'Tue': 1,
        'Wed': 2,
        'Thu': 3,
        'Fri': 4,
        'Sat': 5,
        'Sun': 6,
    }[day]


def url_open(url, data, session):
    retrycount = 0
    s = None
    while s is None:
        try:
            req = request.Request(url, data=data, headers={'Cookie': session})
            s = request.urlopen(req, timeout=30).read()
        except:
            retrycount += 1
            print("Retrying : "+str(retrycount))
            sleep(5)
            if retrycount > 20:
                sys.exit()

    return BeautifulSoup(s, "html.parser")


def result_open(url):
    retrycount = 0
    s = None
    while s is None:
        try:
            session = requests.Session()
            s = session.get(url, verify=False, timeout=30)
        except:
            retrycount += 1
            print("Retrying : "+str(retrycount))
            sleep(5)
            if retrycount > 20:
                sys.exit()

    return BeautifulSoup(s.text, "html.parser")


app = flask.Flask(__name__)


@app.route("/timetable/", methods=['POST'])
def get_portal_data():
    Cookie_session = "JSESSIONID="+flask.request.form.get('JSESSIONID')

    schedule_data = list()
    timetable_data = list()
    grade_data = list()
    cgpa_data = list()
    attendance_data = list()
    lecturer_data = list()

    _tempTimetable = list()
    _tempAttendance = list()
    _tempLecturer = list()
    _tempVenue = dict()

    # ----------------- Semester ----------------------------

    Portal_URL = "http://portal.utar.edu.my/stuIntranet/timetable/index.jsp"

    Schedule_Scrap = url_open(Portal_URL, None, Cookie_session)

    Schedule_Soup = Schedule_Scrap.findAll('input', attrs={'name': 'Enter'})

    if len(Schedule_Soup) > 0:

        if len(Schedule_Soup) > 1:
            Schedule_row = Schedule_Soup[1]
        else:
            Schedule_row = Schedule_Soup[0]

        Schedule_row = Schedule_row['onclick'].split(
            'onEnterClick(', 1)[1][:-1]
        Schedule_row = Schedule_row.replace("'", "").split(',')

        session = Schedule_row[1]
        datetimeobject = datetime.strptime(Schedule_row[6], '%d/%m/%Y')
        start_date = datetimeobject.strftime('%Y-%m-%d')
        datetimeobject = datetime.strptime(Schedule_row[7], '%d/%m/%Y')
        end_date = datetimeobject.strftime('%Y-%m-%d')
        total_week = Schedule_row[8]

        schedule_data.append(
            Semester(str(session), start_date, end_date, str(total_week)).toJSON())

        cgpa_data.append(SemCGPA(str(session), 0.0, 0.0, 0).toJSON())

        # ----------------- Timetable ----------------------------

        Portal_URL = "http://portal.utar.edu.my/stuIntranet/timetable/viewTimetableV2.jsp"
        data = parse.urlencode({'reqSid': Schedule_row[0],
                                'reqSession': Schedule_row[1],
                                'reqLevel': Schedule_row[2],
                                'reqFpartcd': Schedule_row[3],
                                'reqSchool': Schedule_row[4],
                                'reqFbrncd': Schedule_row[5],
                                'reqStartDate': Schedule_row[6],
                                'reqEndDate': Schedule_row[7],
                                'reqTotalWeek': Schedule_row[8],
                                'reqInterval': Schedule_row[9]}).encode()

        Timetable_Scrap = url_open(Portal_URL, data, Cookie_session)

        Timetable_Soup = Timetable_Scrap.find(
            'div', attrs={'class': 'breadcrumb'})
        Timetable_Soup = Timetable_Soup.find('h3')
        Timetable_Soup.find('div').extract()
        StudentEmail = Timetable_Soup.text.split(') ', 1)[1]

        # print(Timetable_Soup)

        Timetable_Soup = Timetable_Scrap.findAll(
            'table', attrs={'class': 'tbltimetable'})[0]
        Timetable_Soup = Timetable_Soup.findAll('td', attrs={'class': 'unit'})

        for row in Timetable_Soup:
            _code = row.find('span').text
            _code = _code.split('(', 1)[0]
            row.find('span').extract()
            row.find('font').extract()
            _venue = row.text
            if _code not in _tempVenue:
                _tempVenue[_code] = dict()
                _tempVenue[_code]['venue'] = list()
                _tempVenue[_code]['count'] = 0
            _tempVenue[_code]['venue'].append(_venue)

        # print(_tempVenue)

        Timetable_Soup = Timetable_Scrap.findAll(
            'table', attrs={'class': 'tbltimetable'})[1]
        Timetable_Soup = Timetable_Soup.findAll('tr')[1:]

        course_name = course_group = course_starttime = course_endtime = ""
        course_day = 0

        for row in Timetable_Soup:
            if len(row) > 3:
                _temp = row.findAll('td')[1:]
                course_code = _temp[0].text
                course_name = _temp[1].text
                course_type = _temp[2].text
                course_group = _temp[3].text
                _temp[4] = _temp[4].find(
                    'a')['onclick'].split('AttDetails(', 1)[1]
                StudentID = _temp[4].split(',')[4][1:-2]
                course_day = _temp[5].text
                _temp[6] = _temp[6].text.split(' - ', 1)
                course_starttime = _temp[6][0]
                course_endtime = _temp[6][1]
                course_hrs = _temp[7].text

            else:
                _temp = row.findAll('td')
                course_day = _temp[0].text
                _temp[1] = _temp[1].text.split(' - ', 1)
                course_starttime = _temp[1][0]
                course_endtime = _temp[1][1]
                course_hrs = _temp[2].text

            timeobject = datetime.strptime(course_starttime, "%I:%M %p")
            course_starttime = timeobject.strftime("%H:%M")
            timeobject = datetime.strptime(course_endtime, "%I:%M %p")
            course_endtime = timeobject.strftime("%H:%M")

            # ----------------- Current Sem Grade ---------------------------------

            if course_type in ["T", "P"]:
                grade_data.append(SubjectGrade(
                    session, course_code, course_name, course_type, "A+", 1).toJSON())

            # print(grade_data)

            # ----------------- Lecturer ----------------------------

            Lecturer_URL = "http://portal.utar.edu.my/stuIntranet/timetable/lecturerTimeslot.jsp?sess=" + \
                session+"&unit="+course_code
            Lecturer_Scrap = url_open(Lecturer_URL, None, Cookie_session)
            lecturer_id = Lecturer_Scrap.find(
                'div', attrs={'class': 'in rtin tpin'}).find('img')
            lecturer_id = lecturer_id['src'].split('fkey=', 1)[1]
            Lecturer_Soup = Lecturer_Scrap.find(
                'table', attrs={'class': 'tblinfo'})
            Lecturer_Soup = Lecturer_Soup.findAll('tr')
            lecturer_name = Lecturer_Soup[0].findAll('td')[1].text
            if lecturer_id not in _tempLecturer:
                _tempLecturer.append(lecturer_id)
                roomNo = Lecturer_Soup[5].findAll('td')[1].text
                lecturer_data.append(Lecturer(lecturer_id, roomNo))

            course_startdate = datetime.strptime(start_date, "%Y-%m-%d")
            course_startdate = course_startdate + \
                timedelta(dayToNum(course_day))
            for temp_coursedate in (course_startdate + timedelta(n*7) for n in range(int(total_week))):
                timetable_data.append(Timetable(course_code, course_name, course_type, course_group, temp_coursedate.strftime("%Y-%m-%d"), start_date, course_starttime,
                                                course_endtime, course_hrs, _tempVenue[course_code]['venue'][_tempVenue[course_code]['count']], lecturer_id, lecturer_name, 1, course_startdate.strftime("%Y-%m-%d"), "W").toJSON())
                _tempTimetable.append(
                    course_code+course_type+temp_coursedate.strftime("%Y-%m-%d")+course_starttime)

            _tempVenue[course_code]['count'] += 1

        for row in Timetable_Soup:
            if len(row) > 3:
                _temp = row.findAll('td')[1:]
                course_code = _temp[0].text
                course_name = _temp[1].text
                course_type = _temp[2].text
                course_group = _temp[3].text

            # ----------------- Attendance ----------------------------

            if (course_code+course_type) not in _tempAttendance:
                _tempAttendance.append(course_code+course_type)
                Attendance_URL = "http://portal.utar.edu.my/stuIntranet/timetable/myAttendance.jsp?unit="+course_code + \
                    "&type="+course_type+"&section="+course_group + \
                    "&strsession="+session+"&id="+StudentID
                Attendace_Scrap = url_open(
                    Attendance_URL, None, Cookie_session)
                Attendace_Soup = Attendace_Scrap.find(
                    'table', attrs={'class': 'tblblue'})

                for row in Attendace_Soup.findAll('tr')[1:]:
                    col = row.findAll('td')
                    if col[0].text != "Sorry, no record found":
                        _temp_date = col[1].text.split(' - ', 1)
                        timeobject = datetime.strptime(
                            _temp_date[0], "%d.%m.%Y (%I:%M %p")
                        timeobjectEndTime = datetime.strptime(timeobject.strftime(
                            "%Y-%m-%d")+" " + _temp_date[1], "%Y-%m-%d %I:%M %p)")
                        attendance_date = timeobject.strftime("%Y-%m-%d")
                        attendance_starttime = timeobject.strftime("%H:%M")
                        attendance_endtime = timeobjectEndTime.strftime(
                            "%H:%M")
                        temphrs = str(math.floor(
                            ((timeobjectEndTime - timeobject).total_seconds() / 60.0) / 60))
                        tempMin = "0"
                        if int(((timeobjectEndTime - timeobject).total_seconds() / 60.0) % 60) == 30:
                            tempMin = "5"
                        else:
                            tempMin = str(
                                int(((timeobjectEndTime - timeobject).total_seconds() / 60.0) % 60))
                        course_hrs = temphrs + "." + tempMin

                        if col[3].text == "N/C":
                            col[3].text = "√"
                        attendance_data.append(Attendance(
                            session, course_code, course_type, attendance_date, attendance_starttime, col[3].text).toJSON())
                        if (course_code+course_type+attendance_date+attendance_starttime) not in _tempTimetable:
                            _tempTimetable.append(
                                course_code+course_type+attendance_date+attendance_starttime)
                            timetable_data.append(Timetable(course_code, course_name, course_type, course_group, attendance_date, start_date, attendance_starttime,
                                                            attendance_endtime, course_hrs, "N/A", lecturer_id, lecturer_name, 1, attendance_date, "N").toJSON())

        # ----------------- Current Sem Course Grade without timetable ----------------------------

        Timetable_Soup = Timetable_Scrap.prettify().split(
            'class="tblnoborder" width="80%">')[1]
        Timetable_Soup = Timetable_Soup.split('<!--page content -->')[0]
        Timetable_Soup = BeautifulSoup(
            Timetable_Soup, "html.parser").findAll('td')[4:]

        _tempCount = 0
        _tempCourseCode = ""
        for row in Timetable_Soup:
            row = re.sub(r'\s+', ' ', row.text).strip()
            if _tempCount == 1:
                _tempCourseCode = row
            elif _tempCount == 2:
                if not any(_tempCourseCode in g for g in grade_data):
                    grade_data.append(SubjectGrade(
                        session, _tempCourseCode, row, "F", "A+", 1).toJSON())

            _tempCount += 1
            if _tempCount == 4:
                _tempCount = 0

        # print(grade_data)

        # ----------------- Previous Sem Course Grade ---------------------------------------------

        Portal_URL = "http://portal.utar.edu.my/stuIntranet/index.jsp"

        AT_Scrap = url_open(Portal_URL, None, Cookie_session)

        AT_Soup = AT_Scrap.find(
            'a', text='Academic Transcript/Statement of Results')
        if AT_Soup['href']:
            Portal_URL = AT_Soup['href']
            Redirect_Scrap = url_open(Portal_URL, None, Cookie_session)

            if Redirect_Scrap.text:
                Portal_URL = re.search(
                    r"href='([^\">]+)'", Redirect_Scrap.text)[1]
                Grades_Scrap = result_open(Portal_URL)
                Grades_Soup = Grades_Scrap.find(
                    lambda tag: tag.name == "td" and "TRIMESTER" in tag.text)
                Grades_Soup = Grades_Soup.parent.parent
                Grades_Soup = Grades_Soup.findAll('tr', attrs={'style': None})
                # print(Grades_Soup)

                _tempSem = ""
                _tempGPA = 0.0
                _tempCGPA = 0.0
                _tempCreditEarn = 0
                for row in Grades_Soup:
                    semester_row = row.find('td', attrs={'align': 'top'})

                    if semester_row:
                        # print(semester_row)
                        temp_trimester_data = semester_row.text.split(':')[1]
                        temp_trimester_data = temp_trimester_data.split(' ')
                        temp_trimester_data = temp_trimester_data[2] + monthToNum(
                            temp_trimester_data[1])
                        schedule_data.append(
                            Semester(temp_trimester_data, '', '', 0).toJSON())
                        _tempSem = temp_trimester_data
                    else:
                        subject_row = row.find('td', attrs={'valign': 'top'})
                        if subject_row:
                            subject_row = subject_row.parent
                            subject_row = subject_row.findAll('td')
                            _tempGrade = subject_row[3].text.strip()
                            _tempStatus = 1
                            if _tempGrade == "PS":
                                _tempStatus = 0
                            grade_data.append(SubjectGrade(
                                _tempSem, subject_row[0].text, subject_row[1].text, "F", _tempGrade, _tempStatus).toJSON())
                        else:
                            cgpa_row = row.find('table')
                            if cgpa_row:
                                grade_row = cgpa_row.findAll('td')
                                _tempGPA = float(grade_row[0].text.split(':')[
                                    1].strip())
                                _tempCGPA = float(grade_row[1].text.split(':')[
                                    1].strip())
                                _tempCreditEarn = round(float(grade_row[3].text.split(':')[
                                    1].strip()))
                                cgpa_data.append(
                                    SemCGPA(_tempSem, _tempGPA, _tempCGPA, _tempCreditEarn).toJSON())

        # ----------------- Update Lecturer Room No ----------------------------
        client = MongoClient('')
        db = client['']

        collection = db['Staff_Directory']

        for stf in lecturer_data:
            collection.update_one({"sid": stf.lecturer_id},
                                  {
                "$set": {
                    "roomno": stf.roomNo,
                    "last_update_date": now
                }
            }, upsert=True)

            # print(stf.lecturer_id+" - Updated")

        client.close()

    return flask.jsonify({
        'semester': schedule_data,
        'timetable': timetable_data,
        'attendance': attendance_data,
        'courseGrade': grade_data,
        'cgpa': cgpa_data
    })


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 3000))
    app.run(host='0.0.0.0', port=port)
