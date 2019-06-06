# -*- coding: utf-8 -*-

import sys

GLOBAL_PATH='/home/jh7x3/bdm_github/CNNQA/';
sys.path.insert(0, GLOBAL_PATH+'/scripts/DN_package/')


#print len(sys.argv)
if len(sys.argv) != 4:
        print 'please input the right parameters: list, model, weight, kmax'
        sys.exit(1)


data_file=sys.argv[1] 
feature_dir=sys.argv[2]  #
output_dir=sys.argv[3]

import time
from model_evaluation import predict_local,predict_local_global_joint

method_list = ['LocalQA','InteractQA','JointQA']
weight_dir =GLOBAL_PATH+'/scripts/DN_package/models/'

for method in method_list:
    print "running method " + str(method)
    # interval 15
    model_in=weight_dir+'model_'+str(method)+'.json'
    model_weight_in=weight_dir+'model_'+str(method)+'.h5'
    outputfile=output_dir+'/local_prediction_'+str(method)+'.txt'
    logfile=output_dir+'/local_prediction_'+str(method)+'.log'
    test_list=data_file
    
    if method is 'JointQA':
        predict_local_global_joint(test_list,feature_dir,model_in,model_weight_in,outputfile,logfile)
    else:    
        predict_local(test_list,feature_dir,model_in,model_weight_in,outputfile,logfile)
    
