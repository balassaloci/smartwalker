from pony.orm import *
from datetime import datetime

db = Database()


class Patient(db.Entity):
    name = Required(str)
    birthdate = Required(datetime)

    events = Set("Event")
    # senses = Set("Sens")


class Condition(db.Entity):

    name = Required(str)
    description = Required(str)
    events = Set("Event")


class Event(db.Entity):

    patient = Required(Patient)
    timestamp = Required(datetime)
    measurement_from = Optional(datetime)
    measurement_to = Optional(datetime)
    confidence = Required(float)
    diagnosis = Required(Condition)


class Sens(db.Entity):

    # patient = Required(Patient)
    timestamp = Required(datetime)
    grip = Required(str)
    dist = Required(float)
    opose = Optional(str)
    vid_id = Required(str)
    act = Optional(str)
    meta = Required(str)
    processed = Optional(str)


db.bind('postgres',
        user='postgres',
        password='postgres',
        host='localhost',
        port='5432')

db.generate_mapping(create_tables=True)


@db_session
def create_conditions():
    norm = Condition(name="Normal", description="The gait looks normal")

    park = Condition(name="Parkinson's disease",description=
"""Parkinson's disease (PD) is a long-term degenerative disorder of the central nervous system that mainly affects the motor system. The symptoms generally come on slowly over time. Early in the disease, the most obvious are shaking, rigidity, slowness of movement, and difficulty with walking. Thinking and behavioral problems may also occur. Dementia becomes common in the advanced stages of the disease. Depression and anxiety are also common occurring in more than a third of people with PD. Other symptoms include sensory, sleep, and emotional problems. The main motor symptoms are collectively called "parkinsonism", or a "parkinsonian syndrome". (Wikipedia)""")

    more = Condition(name="Haemoweird walk", description="No")

@db_session
def create_patients():
    josh = Patient(name="Joshua Brown", birthdate='1996-05-03 00:00')
    loci = Patient(name="Lorinc Balassa", birthdate='1995-02-01 00:00')
    david= Patient(name="David Pasztor", birthdate='1995-10-15 00:00')


if __name__ == "__main__":
    # create_conditions()
    create_patients()
    print(" [x] created conditions")

# @db_session
# def runsess():
#     print(select(o for o in SensorGrip)[:])
    #for x in SensorGrip.select(c for c in SensorGrip):
    #    print(x)

# runsess()

# print(SensorGrip.select().order_by(desc(SensorGrip.id)))
