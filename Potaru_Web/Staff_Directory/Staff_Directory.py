from pymongo import MongoClient
from bson.objectid import ObjectId
from urllib.request import urlopen
from bs4 import BeautifulSoup
from time import time, sleep
import datetime
import sys
import re
import cloudinary
import cloudinary.uploader
import cloudinary.api

weekno = datetime.datetime.today().weekday()
if weekno == 2:

    faculty_list = []

    class Faculty:

        def __init__(self, code, name):
            self.code = code
            self.name = name
            self.staff_list = []

    class Staff:
        def __init__(self, id, name, faculty, dept, designation, admin_post1, admin_post2, tel1, tel2,
                     email, qualification, professional, expertise):
            self.id = id
            self.name = name
            self.faculty = faculty
            self.dept = dept
            self.designation = designation
            self.admin_post1 = admin_post1
            self.admin_post2 = admin_post2
            self.tel1 = tel1
            self.tel2 = tel2
            self.email = email
            self.qualification = qualification
            self.professional = professional
            self.expertise = expertise

    def url_open(url):
        retrycount = 0
        s = None
        while s is None:
            try:
                s = urlopen(url, timeout=50).read()
            except:
                retrycount += 1
                print("Retrying : "+str(retrycount))
                if retrycount > 20:
                    sys.exit()
                sleep(5)

        return BeautifulSoup(s, "html.parser")

    SD_URL = "http://www2.utar.edu.my/staffListSearch.jsp"

    SD_Scrap = url_open(SD_URL)
    FAC_Soup = SD_Scrap.find('select', attrs={'name': 'searchDept'})
    for FAC_Name in FAC_Soup.findAll('option'):
        faculty_list.append(
            Faculty(FAC_Name['value'].replace(" ", "+"), FAC_Name.text))

    # Get Staff List

    match_list = ['Name', 'Faculty / Institute / Centre / Division', 'Department / Unit', 'Designation',
                  'Administrative Post', 'Administrative Post', 'Telephone No', 'Email Address', 'Qualification',
                  'Professional Qualification', 'Area of Expertise', 'Homepage URL']

    for fac in faculty_list[1:]:
        pageno = 1
        SD_Page = 1
        while pageno <= SD_Page:
            SD_URL = "http://www2.utar.edu.my/staffListSearch.jsp?iPage=" + \
                str(pageno)+"&searchDept="+fac.code + \
                "&searchDiv=All&submit=Search&searchResult=Y"

            SD_Scrap = url_open(SD_URL)

            if pageno == 1:
                STF_PageSoup = SD_Scrap.find('tr', attrs={'id': 'notDisplay'})
                SD_Page = len(STF_PageSoup.findAll('a'))+1

            STF_Soup = SD_Scrap.find('table', attrs={'cellpadding': '3'})
            for STF_ID in STF_Soup.findAll('table'):
                STF_SID = STF_ID['onclick'].split('searchId=', 1)[1][:-2]
                STF_URL = "http://www2.utar.edu.my/staffListDetail.jsp?searchId="+STF_SID
                STF_Scrap = url_open(STF_URL)
                STF_Info_Soup = STF_Scrap.find(
                    'table', attrs={'class': 'tblstaffdirectory'})
                STF_Info_Soup = STF_Info_Soup.findAll('td')

                i = 0
                count = 0
                data_len = len(STF_Info_Soup)
                match_len = len(match_list)
                STF_DATA = []

                while i < 25:
                    if i < data_len and count < match_len:
                        STF_subData = re.sub(
                            r'\s+', ' ', STF_Info_Soup[i].text).strip()

                        # print(str(i)+STF_subData+match_list[count])

                        if STF_subData[:-2] in match_list[count]:
                            if 'Telephone No' in STF_subData:
                                data = re.sub(
                                    r'\s+', ' ', STF_Info_Soup[i+1].text).strip()
                                if data:
                                    STF_DATA.append(data)
                                    i += 3
                                else:
                                    STF_DATA.append('')
                                    i += 2
                            else:
                                i += 1
                            STF_DATA.append(
                                re.sub(r'\s+', ' ', STF_Info_Soup[i].text).strip())
                        else:
                            STF_DATA.append('')
                            i -= 1
                    elif count < match_len:
                        STF_DATA.append('')
                    else:
                        break

                    count += 1
                    i += 1

                fac.staff_list.append(Staff(STF_SID, STF_DATA[0], STF_DATA[1], STF_DATA[2], STF_DATA[3], STF_DATA[4], STF_DATA[5],
                                            STF_DATA[6], STF_DATA[7], STF_DATA[8], STF_DATA[9], STF_DATA[10], STF_DATA[11]))
                # print(STF_DATA)

                sleep(1)

            pageno += 1

    print("\n\nDownload Completed..")

    # Upload Staff Img

    cloudinary.config(
        cloud_name='',
        api_key='',
        api_secret=''
    )

    for fac in faculty_list:
        for stf in fac.staff_list:
            retrycount = 0
            s = None
            while s is None:
                try:
                    s = cloudinary.uploader.upload(
                        "http://www2.utar.edu.my/getPic.jsp?fkey="+stf.id,
                        public_id="staff_directory/"+stf.id,
                        overwrite=True,
                        invalidate=True,
                        timeout=60
                    )
                except:
                    retrycount += 1
                    print("Retrying : "+str(retrycount))

            #print(stf.id+" - completed")

    print("Upload Completed")

    # Insert into MongoDB

    import time
    from bson.objectid import ObjectId
    from pymongo import MongoClient

    now = int(time.time())
    db_user = ''
    db_pass = ''

    client = MongoClient('')
    db = client['']

    for fac in faculty_list:

        collection = db['Faculty']
        collection.update_one({"code": fac.code},
                              {
            "$set": {
                "name": fac.name,
                "last_update_date": now
            },
            "$setOnInsert": {
                "_id": str(ObjectId()),
                "code": fac.code,
                "insertion_date": now
            }

        }, upsert=True)

        #print(fac.code+" - inserted")

        collection = db['Staff_Directory']

        for stf in fac.staff_list:
            collection.update_one({"sid": stf.id, "faculty_code": fac.code},
                                  {
                "$set": {
                    "name": stf.name,
                    "faculty_code": fac.code,
                    "faculty": stf.faculty,
                    "department": stf.dept,
                    "designation": stf.designation,
                    "administrative_post1": stf.admin_post1,
                    "administrative_post2": stf.admin_post2,
                    "tel_no1": stf.tel1,
                    "tel_no2": stf.tel2,
                    "email": stf.email,
                    "qualification": stf.qualification,
                    "pro_qualification": stf.professional,
                    "expertise": stf.expertise,
                    "last_update_date": now
                },
                "$setOnInsert": {
                    "_id": str(ObjectId()),
                    "sid": stf.id,
                    "roomno": "",
                    "insertion_date": now
                }
            }, upsert=True)

            #print(stf.id+" - inserted")

    collection = db['Faculty']
    collection.delete_many({"last_update_date": {"$lt": now}})

    collection = db['Staff_Directory']
    collection.delete_many({"last_update_date": {"$lt": now}})

    collection = db['Version']
    collection.update_one({"app": "staff_directory"},
                          {
        "$set": {
            "last_update_date": now
        },
        "$setOnInsert": {
            "_id": str(ObjectId()),
            "app": "staff_directory"
        }
    }, upsert=True)

    client.close()
