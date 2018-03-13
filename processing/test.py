import localdb as db
import datetime
from pony import orm


@orm.db_session
def insert_test():
    x = db.SensorGrip(
        timestamp=datetime.datetime.now(),
        left=12.2,
        right=12.4)

    y = db.SensorGrip(
        timestamp=datetime.datetime.now(),
        left=12.4,
        right=12.4)


@orm.db_session
def select_test():

    x = db.SensorGrip.select().order_by(db.desc(db.SensorGrip.id))

    for y in x:
        print(y)


# insert_test()
select_test()

