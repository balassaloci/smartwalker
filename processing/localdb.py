from pony.orm import *
from datetime import datetime

db = Database()


class Patient(db.Entity):
    name = Required(str)
    birthdate = Required(datetime)

    events = Set("Event")
    # senses = Set("Sens")


class Condition(db.Entity):

    shortname = Required(str)
    longname = Required(str)
    description = Required(str)
    events = Set("Event")


class Event(db.Entity):

    patient = Required(Patient)
    timestamp = Required(datetime)
    confidence = Required(float)
    diagnosis = Required(Condition)


class Sens(db.Entity):

    # patient = Required(Patient)
    timestamp = Required(datetime)
    grip = Required(str)
    dist = Required(float)
    opose = Optional(str)
    vid_id = Required(str)


db.bind('postgres',
        user='postgres',
        password='postgres',
        host='192.168.99.100',
        port='32768')

db.generate_mapping(create_tables=True)


# @db_session
# def runsess():
#     print(select(o for o in SensorGrip)[:])
    #for x in SensorGrip.select(c for c in SensorGrip):
    #    print(x)

# runsess()

# print(SensorGrip.select().order_by(desc(SensorGrip.id)))
