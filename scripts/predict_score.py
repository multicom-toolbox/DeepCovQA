# -*- coding: utf-8 -*-
"""
Created on Wed Feb 22 21:37:04 2017

@author: Jie Hou
"""

 

##### using all SCOP95 data to train the model 

# cd /home/jh7x3/DeepCov_QA/results/DeepCov_training
import sys
sys.path.append('/home/casp13/DeepCov_QA/scripts/DN_package/')  

from Data_loading import load_test_data_padding_with_interval



#print len(sys.argv)
if len(sys.argv) != 4:
        print 'please input the right parameters: list, model, weight, kmax'
        sys.exit(1)


data_file=sys.argv[1] 
feature_dir=sys.argv[2]  #'/home/jh7x3/DLS2F/DLS2F_Project/PDB_SCOP95_SEQ/Feature_data_SCOP/Feature_aa_ss_sa/'
output_dir=sys.argv[3]

#CV_dir='/home/jh7x3/DeepCov_QA/results/DeepCov_training/test'

# /home/casp13/QA_run/valid_novel/T1111/model.list
#data_file ='/home/casp13/QA_run/valid_novel/T1111_stg2/model.list'
#feature_dir = '/home/casp13/QA_run/valid_novel/T1111_stg2/ALL_scores'

import time
testdata_all_dict_padding_interval15 = load_test_data_padding_with_interval(data_file,feature_dir,15, 'kmax30',2000,train=False)


from model_evaluation import predict_local,predict_global,predict_local_global



interv = [1,5]
#weight_dir ='/home/jh7x3/DeepCov_QA/results/DeepCov_training/weights_lewis/'
#weight_dir ='/home/jh7x3/DeepCov_QA/results/DeepCov_training_Single_domain/weights_lewis/'
weight_dir ='/home/casp13/DeepCov_QA/scripts/DN_package/fulllength_weights/'
#output_dir ='/home/casp13/QA_run/valid_novel/T1111_stg2/predictions'
for int in interv:
    print "running interval " + str(int)
    # interval 15
    model_in=weight_dir+'model_ResCNN_pssm-train-local-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.json'
    model_weight_in=weight_dir+'model_ResCNN_pssm-train-local-weight-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.h5'
    outputfile=output_dir+'/testing_local_prediction_int'+str(int)+'.txt'
    logfile=output_dir+'/testing_local_prediction_int'+str(int)+'.log'
    test_list=data_file
    predict_local(test_list,feature_dir,model_in,model_weight_in,outputfile,logfile)
    
    
    model_in=weight_dir+'model_ResCNN_pssm-train-global-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.json'
    model_weight_in=weight_dir+'model_ResCNN_pssm-train-global-weight-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.h5'
    outputfile=output_dir+'/testing_global_prediction_int'+str(int)+'.txt'
    #outputfile=output_dir+'/test/testing_list_prediction_int15.txt'
    logfile=output_dir+'/testing_global_prediction_int'+str(int)+'.log'
    #logfile=output_dir+'/test/testing_list_prediction_int15.log'
    test_list=data_file
    #test_list=output_dir+'/test/test.list'
    predict_global(test_list,feature_dir,model_in,model_weight_in,outputfile,logfile)
    
    
    
    local_model_in=weight_dir+'model_ResCNN_pssm-train-integrate-local-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.json'
    local_model_weight_in=weight_dir+'model_ResCNN_pssm-train-integrate-local-weight-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.h5'
    global_model_in=weight_dir+'model_ResCNN_pssm-train-global-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.json'
    global_model_weight_in=weight_dir+'model_ResCNN_pssm-train-integrate-global-weight-iterative-padding-withaa-complex-kmax30-win'+str(int)+'_bias-sigmoid.h5'
    local_outputfile=output_dir+'/testing_iterative_local_prediction_int'+str(int)+'.txt'
    global_outputfile=output_dir+'/testing_iterative_global_prediction_int'+str(int)+'.txt'
    #outputfile=output_dir+'/test/testing_list_prediction_int15.txt'
    local_logfile=output_dir+'/testing_iterative_local_prediction_int'+str(int)+'.log'
    global_logfile=output_dir+'/testing_iterative_global_prediction_int'+str(int)+'.log'
    #logfile=output_dir+'/test/testing_list_prediction_int15.log'
    test_list=data_file
    #test_list=output_dir+'/test/test.list'
    predict_local_global(test_list,feature_dir,local_model_in,local_model_weight_in,global_model_in,global_model_weight_in,local_outputfile,global_outputfile,local_logfile)

    