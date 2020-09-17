from urllib.request import Request, urlopen
from bson.objectid import ObjectId
from pymongo import MongoClient
from time import sleep
import json
import datetime
import sys
import re
import time


class PublicHoliday:
    def __init__(self, name, year, month, day):
        self.name = name
        self.year = year
        self.month = month
        self.day = day


def url_open(url):
    retrycount = 0
    s = None
    while s is None:
        try:
            req = Request(url)
            req.add_header(
                'User-agent', 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5')
            s = urlopen(req, timeout=30).read()
        except:
            retrycount += 1
            print("Retrying : "+str(retrycount))
            sleep(5)
            if retrycount > 20:
                sys.exit()

    return s


public_holiday_data = list()

year_now = str(datetime.datetime.today().year)
PH_URL = "https://calendarific.com/api/v2/holidays?api_key=17c10e88dfc734a0d204edc95731493ade5247c9&country=MY&year="+year_now

PH_Scrap = url_open(PH_URL)
json_data = json.loads(PH_Scrap)
data = json_data['response']['holidays']

for row in data:
    if row['type'][0] == "National holiday" or row['type'][0] == "Common local holiday" or row['type'][0] == "Local holiday":
        if row['states'] == "All":
            public_holiday_data.append(PublicHoliday(
                row['name'], row['date']['datetime']['year'], row['date']['datetime']['month'], row['date']['datetime']['day']))
        else:
            for state in row['states']:
                if state['abbrev'] == "PRK" or state['abbrev'] == "SGR" or state['abbrev'] == "KUL":
                    public_holiday_data.append(PublicHoliday(
                        row['name'], row['date']['datetime']['year'], row['date']['datetime']['month'], row['date']['datetime']['day']))


now = int(time.time())
db_user = ''
db_pass = ''

client = MongoClient('mongodb+srv://'+db_user+':'+db_pass +
                     '@potaru')
db = client['']

collection = db['Public_Holiday']
collection.delete_many({})

for ph in public_holiday_data:

    collection.update_one(
        {
            "name": ph.name,
            "year": ph.year,
            "month": ph.month,
            "day": ph.day
        },
        {
            "$setOnInsert": {
                "_id": str(ObjectId()),
                "name": ph.name,
                "year": ph.year,
                "month": ph.month,
                "day": ph.day,
                "insertion_date": now
            }

        }, upsert=True)

    #print(ph.name+" - inserted")

collection = db['Version']
collection.update_one({"app": "publicholiday"},
                      {
    "$set": {
        "last_update_date": now
    },
    "$setOnInsert": {
        "_id": str(ObjectId()),
        "app": "publicholiday"
    }
}, upsert=True)

client.close()
