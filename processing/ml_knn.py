"""
This algorithm is largely from:
http://alexminnaar.com/time-series-classification-and-clustering-with-python.html
"""

import pandas as pd
import numpy as np
import matplotlib.pylab as plt
from math import sqrt

import localdb as db
from pony.orm import *
import json
import numpy as np

from collections import Counter

from sklearn.metrics import classification_report

def DTWDistance(s1, s2):
    DTW={}
    
    for i in range(len(s1)):
        DTW[(i, -1)] = float('inf')
    for i in range(len(s2)):
        DTW[(-1, i)] = float('inf')
    DTW[(-1, -1)] = 0

    for i in range(len(s1)):
        for j in range(len(s2)):
            dist= (s1[i]-s2[j])**2
            DTW[(i, j)] = dist + min(DTW[(i-1, j)],DTW[(i, j-1)], DTW[(i-1, j-1)])
		
    return sqrt(DTW[len(s1)-1, len(s2)-1])

def DTWDistance(s1, s2,w):
    DTW={}
    
    w = max(w, abs(len(s1)-len(s2)))
    
    for i in range(-1,len(s1)):
        for j in range(-1,len(s2)):
            DTW[(i, j)] = float('inf')
    DTW[(-1, -1)] = 0
  
    for i in range(len(s1)):
        for j in range(max(0, i-w), min(len(s2), i+w)):
            dist= (s1[i]-s2[j])**2
            DTW[(i, j)] = dist + min(DTW[(i-1, j)],DTW[(i, j-1)], DTW[(i-1, j-1)])
		
    return sqrt(DTW[len(s1)-1, len(s2)-1])

def LB_Keogh(s1,s2,r):
    LB_sum=0
    for ind,i in enumerate(s1):

        lower_bound=min(s2[(ind-r if ind-r>=0 else 0):(ind+r)])
        upper_bound=max(s2[(ind-r if ind-r>=0 else 0):(ind+r)])

        if i>upper_bound:
            LB_sum=LB_sum+(i-upper_bound)**2
        elif i<lower_bound:
            LB_sum=LB_sum+(i-lower_bound)**2

    return sqrt(LB_sum)

def knn(train,test,w):
    preds=[]
    for ind,i in enumerate(test):
        min_dist=float('inf')
        closest_seq=[]
        #print ind
        for j in train:
            if LB_Keogh(i[:-1],j[:-1],5)<min_dist:
                dist=DTWDistance(i[:-1],j[:-1],w)
                if dist<min_dist:
                    min_dist=dist
                    closest_seq=j
        preds.append(closest_seq[-1])
    return classification_report(test[:,-1],preds)

@db_session
def from_db(act, clgroup):
    raw = select(x for x in db.Sens if x.act==act)
    done = []
    for x in raw:
        try:
            grip = json.loads(x.grip)
            dist = [x.dist]
            proc_ = json.loads(x.processed)
            proc = proc_[8][0:2]+proc_[9][0:2]+proc_[10][0:2]+proc_[11][0:2]+proc_[12][0:2]+proc_[13][0:2]
            line = grip + dist + proc + [clgroup]
            
            done.append(line)
        except Exception as e:
            print("Error, likely invalid data in db. Don't use this dataset if many errors appear")

    nparr = np.array(done)
    
    trainlen = int(len(nparr) * 0.7)
    
    train, test = nparr[:trainlen], nparr[trainlen:]
    
    # test = test [:,:-1]
    return train, test


def compile_datas(names, clgroups):
    trains = []
    tests = []
    for x in range(len(names)):
        tr, te = from_db(names[x], clgroups[x])
        trains.append(tr)
        tests.append(te)
    
    try:
        tr_final = np.concatenate(trains, axis=0)
        te_final = np.concatenate(tests, axis=0)
    except:
        print(trains)
    
    return tr_final, te_final


# labels = ['normal_1', 'parkinsons_1', 'haemoplegic_1', 'limp_right_1']
# clgroups = [1.0, 2.0, 3.0, 4.0]
# labels = ['normal_1', 'parkinsons_1', 'haemoplegic_1']
# clgroups = [1.0, 2.0, 3.0]
# tr, te = compile_datas(labels, clgroups)

def knn_line(train,test,w):
    preds=[]
    c = Counter()
    for ind,i in enumerate(test):
        min_dist=float('inf')
        closest_seq=[]
        #print ind
        for j in train:
            if LB_Keogh(i[:-1],j[:-1],5)<min_dist:
                dist=DTWDistance(i[:-1],j[:-1],w)
                if dist<min_dist:
                    min_dist=dist
                    closest_seq=j
        preds.append(closest_seq[-1])

        c[closest_seq[-1]] += 1
        
    return c.most_common(1)[0][0], float(c.most_common(1)[0][1]) / len(preds)
    
    # return preds
    # return classification_report(test[:,-1],preds)

def predict(train, test, expected, w):
    x = knn_line(train, test, w)
    #print(x)
    
    cgood = sum(1 for y in x if y==expected)
    
    pgood = 100 * cgood / len(x)
    pbad = 100 - pgood
    
    print("Correct: %f%% \t\t, Bad: %f%%" % (pgood, pbad))

    
# tr1, te1 = compile_datas(
#    ['normal_t_1', 'normal_t_2', 'normal_t_3', 'normal_t_4',
#    'haemoplegic_t_1','haemoplegic_t_2','haemoplegic_t_3','haemoplegic_t_4'],
#    [1.0, 1.0, 1.0, 1.0, 3.0, 3.0, 3.0, 3.0])

#tr1, te1 = compile_datas(['normal_t_2', 'parkinsons_t_3'], [1.0, 2.0])

# mydata = te[65:70]
#predict(tr, tr1, 3.0, 4)

#print(knn(tr, tr1, 20))

# print(knn_line(tr, te[35:40], 5))
#print knn(tr, te, 4)

#no_train, no_test = from_db('no', 1)
#limp_train, limp_test = from_db('test-feet-limp', 2)

#train = np.concatenate((no_train, limp_train), axis=0)
#test = np.concatenate((no_test, limp_test), axis=0)

#print knn(train,test,4)