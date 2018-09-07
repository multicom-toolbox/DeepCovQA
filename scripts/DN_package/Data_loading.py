# -*- coding: utf-8 -*-
"""
Created on Wed Feb 22 21:40:30 2017

@author: Jie Hou
"""
import os
import numpy as np
import pickle
def chkdirs(fn):
  dn = os.path.dirname(fn)
  if not os.path.exists(dn): os.makedirs(dn)



def import_DLS2FSVM(filename, delimiter='\t', delimiter2=' ',comment='>',skiprows=0, start=0, end = 0,target_col = 1, dtype=np.float32):
    # Open a file
    file = open(filename, "r")
    #print "Name of the file: ", file.name
    if skiprows !=0:
       dataset = file.read().splitlines()[skiprows:]
    if skiprows ==0 and start ==0 and end !=0:
       dataset = file.read().splitlines()[0:end]
    if skiprows ==0 and start !=0:
       dataset = file.read().splitlines()[start:]
    if skiprows ==0 and start !=0 and end !=0:
       dataset = file.read().splitlines()[start:end]
    else:
       dataset = file.read().splitlines()
    #print dataset
    newdata = []
    for i in range(0,len(dataset)):
        line = dataset[i]
        if line[0] != comment:
           temp = line.split(delimiter,target_col)
           feature = temp[target_col]
           label = temp[0]
           if label == 'SVM':
               label = 0
           if label == 'N':
               label = 0
           fea = feature.split(delimiter2)
           newline = []
           #newline.append(int(label))
           newline.append(label)
           for j in range(0,len(fea)):
               if fea[j].find(':') >0 :
                   (num,val) = fea[j].split(':')
                   newline.append(float(val))
            
           newdata.append(newline)
    data = np.array(newdata, dtype=dtype)
    file.close()
    return data

"""
Feature_aa_ss_sa_dir ='/home/jh7x3/DeepCov_QA/results/Features/Feature_aa_ss_sa'
pssm_dir ='/home/jh7x3/DeepCov_QA/results/Features/PSSM_Fea'
Feature_disorder_dir ='/home/jh7x3/DeepCov_QA/results/Features/Feature_disorder'
DeepQA_energy_dir ='/home/jh7x3/DeepCov_QA/results/Features/DeepQA_energy'
SA_match_dir ='/home/jh7x3/DeepCov_QA/results/Features/SA_match'
SS_match_dir ='/home/jh7x3/DeepCov_QA/results/Features/SS_match'
rosetta_casp8 = '/home/jh7x3/DeepCov_QA/data/casp8_scrwl_all_predictions_final_proq3'
rosetta_casp9 = '/home/jh7x3/DeepCov_QA/data/casp9_scrwl_all_predictions_final_proq3'
rosetta_casp10 = '/home/jh7x3/DeepCov_QA/data/casp10_scrwl_all_predictions_final_proq3'
rosetta_casp11 = '/home/jh7x3/DeepCov_QA/data/casp11_scrwl_all_predictions_final_proq3'
rosetta_casp12 = '/home/jh7x3/DeepCov_QA/data/casp12_scrwl_all_predictions_final_proq3'
Targets_scores_dir='/home/jh7x3/DeepCov_QA/results/Targets_out'
"""



def load_test_data_padding_with_interval(data_file,feature_dir, Interval,prefix,seq_end,train=True):# return path
    import pickle
    ### loading training data 
    print "##loading testing file set instead %s ..." % (data_file)
    

    import time
    start_time = time.time()       
    sequence_file=open(data_file,'r').readlines() 
    feature_all_dict_global = dict()
    data_all_dict=dict()
    file_processed=0
    for i in xrange(len(sequence_file)):
        if sequence_file[i].find('local_native_length') >0 :
            print "Skip line ",sequence_file[i]
            continue
        source = sequence_file[i].split('\t')[0]  ## test\tT0859\tMULTICOM_TS1
        targetid = sequence_file[i].split('\t')[1]
        modelid = sequence_file[i].split('\t')[2]
        
        file_processed += 1
        
        if file_processed % 100 == 0:
            print str(file_processed) + " processed"
        #### import global feature
        if targetid not in feature_all_dict_global.keys():
            #print "Processing ",targetid
            featurefile = feature_dir + '/' + targetid + '.fea_aa_ss_sa'
            pssmfile = feature_dir + '/' + targetid + '.pssm_fea'
            Feature_disorder = feature_dir + '/' + targetid + '.disorder_label'
            if not os.path.isfile(featurefile):
                        print "feature file not exists: ",featurefile, " pass!"
                        exit(1)         
                        
            if not os.path.isfile(pssmfile):
                        print "pssm feature file not exists: ",pssmfile, " pass!"
                        exit(1)          
                          
            if not os.path.isfile(Feature_disorder):
                        print "disorder feature file not exists: ",Feature_disorder, " pass!"
                        exit(1)  
            
            
            featuredata = import_DLS2FSVM(featurefile)
            pssmdata = import_DLS2FSVM(pssmfile) # d1ft8e_ has wrong length, in pdb, it has 57, but in pdb, it has 44, why?
            disorderdata = import_DLS2FSVM(Feature_disorder,delimiter=' ')
            
            
            pssm_fea = pssmdata[:,1:]
            disorder_fea = disorderdata[:,1:]
            fea_len = (featuredata.shape[1]-1)/(20+3+2)
            
            if fea_len != disorder_fea.shape[1]:
                print "The aa feature length %i not equal to disorder feature length %i for target %s!" % (fea_len,disorder_fea.shape[1],targetid)
                raise Exception("The aa feature length %i not equal to disorder feature length %i!" % (fea_len,disorder_fea.shape[1]))
            
                
            #train_labels = featuredata[:,0]


            train_feature = featuredata[:,1:]
            train_feature_seq = train_feature.reshape(fea_len,25)
            train_feature_aa = train_feature_seq[:,0:20]
            train_feature_ss = train_feature_seq[:,20:23]
            train_feature_sa = train_feature_seq[:,23:25]
            train_feature_pssm = pssm_fea.reshape(fea_len,20)
            train_feature_disorder=disorder_fea.reshape(fea_len,1)
            
            featuredata_global = np.concatenate((train_feature_aa,train_feature_ss,train_feature_sa,train_feature_pssm,train_feature_disorder), axis=1)
            feature_all_dict_global[targetid]=featuredata_global
        else:
            featuredata_global=feature_all_dict_global[targetid]
        
        
        #### import model-based feature
        #print "Processing ",pdb_name
        DeepQA_energy_dir =  feature_dir + '/DeepQA_energy'
        SS_match_dir =  feature_dir + '/SS_match'
        SA_match_dir =  feature_dir + '/SA_match'
        deepQA_energy = DeepQA_energy_dir + '/' + targetid + '_' + modelid + '.DeepQAenergy'
        SS_matchfile = SS_match_dir + '/' + targetid + '_' + modelid + '.ss_match'
        SA_matchfile = SA_match_dir + '/' + targetid + '_' + modelid + '.sa_match'
        rosetta_dir = feature_dir + '/rosetta'
        
        rosetta_highfile = rosetta_dir + '/' + targetid +'/' + modelid + '.pdb.features.highres.resetta.svm'
        rosetta_lowfile = rosetta_dir+ '/' + targetid  +'/' + modelid + '.pdb.features.lowres.resetta.svm'
    
            
        
        if not os.path.isfile(deepQA_energy):
                    print "deepQA_energy file not exists: ",deepQA_energy, " pass!"
                    exit(1)           
                             
                      
        if not os.path.isfile(SA_matchfile):
                    print "SA_matchfile feature file not exists: ",SA_matchfile, " pass!"
                    exit(1)        
                      
        if not os.path.isfile(SS_matchfile):
                    print "SS_matchfile feature file not exists: ",SS_matchfile, " pass!"
                    exit(1)      
                      
        if not os.path.isfile(rosetta_highfile):
                    print "rosetta_highfile feature file not exists: ",rosetta_highfile, " pass!"
                    exit(1)   
                      
        if not os.path.isfile(rosetta_lowfile):
                    print "rosetta_lowfile feature file not exists: ",rosetta_lowfile, " pass!"
                    exit(1)   
        
        
        featuredata = import_DLS2FSVM(featurefile)
        pssmdata = import_DLS2FSVM(pssmfile) # d1ft8e_ has wrong length, in pdb, it has 57, but in pdb, it has 44, why?
        

        deepQA_energydata = import_DLS2FSVM(deepQA_energy,delimiter=' ')
        SA_matchdata = import_DLS2FSVM(SA_matchfile,delimiter=' ')
        SS_matchdata = import_DLS2FSVM(SS_matchfile,delimiter=' ')
        
        rosetta_highdata = import_DLS2FSVM(rosetta_highfile,delimiter=' ') #(91L, 121L)
        rosetta_lowdata = import_DLS2FSVM(rosetta_lowfile,delimiter=' ')#(91L, 36L)
        train_rosetta_highdata = rosetta_highdata[:,1:25] #(91L, 120L)  1:25 only score,no win
        train_rosetta_lowdata = rosetta_lowdata[:,1:8] #(91L, 35L)
        if rosetta_highdata.shape[1] !=121:
                    print "rosetta_highfile feature file has wrong dimension: ",rosetta_highfile, " pass!"
                    exit(1) 
            
        if rosetta_lowdata.shape[1] !=36:
                    print "rosetta_lowfile feature file has wrong dimension: ",rosetta_lowfile, " pass!"
                    exit(1) 
        
        deepQA_energy_fea = np.tile(deepQA_energydata[:,1:],[fea_len,1]) #(91L, 6L)
        if deepQA_energy_fea.shape[1] !=6:
            print "The deepqa feature length %i of target id %s and model %s not equal to 6 in %s!\n\n" % (deepQA_energy_fea.shape[1],targetid,modelid,deepQA_energy)
            exit(1)
            #raise Exception("The deepqa feature length %i of target id %s and model %s not equal to 6 in %s!" % (deepQA_energy_fea.shape[1],targetid,modelid,deepQA_energy))
        SA_matchdata_fea = SA_matchdata[:,1:]
        SS_matchdata_fea = SS_matchdata[:,1:]


        train_feature_deepQA_energy=deepQA_energy_fea.reshape(fea_len,6)
        train_feature_SA_match=SA_matchdata_fea.reshape(fea_len,1)
        train_feature_SS_match=SS_matchdata_fea.reshape(fea_len,1)
        #train_feature_rosetta_highdata=train_rosetta_highdata.reshape(fea_len,120)
        train_feature_rosetta_highdata=train_rosetta_highdata.reshape(fea_len,24)
        #train_feature_rosetta_lowdata=train_rosetta_lowdata.reshape(fea_len,35)
        train_feature_rosetta_lowdata=train_rosetta_lowdata.reshape(fea_len,7)

        
        ### reconstruct feature, each residue represent aa,ss,sa,pssm, and model-based features
        featuredata_all = np.concatenate((featuredata_global,train_feature_SS_match,train_feature_SA_match,train_feature_rosetta_lowdata,train_feature_rosetta_highdata,train_feature_deepQA_energy), axis=1)
        #featuredata_all = featuredata_all.reshape(1,featuredata_all.shape[0]*featuredata_all.shape[1])
        #featuredata_all_tmp = np.concatenate((train_labels.reshape((1,1)),featuredata_all), axis=1)
        
        #featuredata_all.shape  #(91L, 209L)
        
        
        ## load virtual local and global score 
        global_score = np.zeros((1,1))
        local_score = np.zeros((fea_len,1))
        local_score_array=local_score.reshape(fea_len,1)
        
        complete_data = np.concatenate((local_score_array,featuredata_all), axis=1)

        ### remove the residue doesn't exist in native structure 
        
        complete_data_filtered = complete_data[complete_data[:,0] !=10000,:]
        complete_data_filtered_local_score = complete_data_filtered[:,0]
        complete_data_filtered_feature = complete_data_filtered[:,1:]
        
        native_len = complete_data_filtered.shape[0] 
        complete_data_filtered_feature_flatten = complete_data_filtered_feature.reshape(1,complete_data_filtered_feature.shape[0]*complete_data_filtered_feature.shape[1])
        
        featuredata_all_tmp = np.concatenate((global_score.reshape((1,1)),complete_data_filtered_local_score.reshape(1,native_len),complete_data_filtered_feature_flatten), axis=1)
        
        
        
        if native_len <30: # suppose k-max = 30
            native_len = 30
            #featuredata_all_new = np.zeros((featuredata_all_tmp.shape[0],30*(20+20+3+2+1+1+1+6+120+35+1)+1))# additional 1 inside () because each residue has 1 local score 
            featuredata_all_new = np.zeros((featuredata_all_tmp.shape[0],30*(20+20+3+2+1+1+1+6+24+7+1)+1))# additional 1 inside () because each residue has 1 local score 
            featuredata_all_new[:featuredata_all_tmp.shape[0],:featuredata_all_tmp.shape[1]] = featuredata_all_tmp
        else:
            featuredata_all_new = featuredata_all_tmp
        
        for ran in range(0,seq_end,Interval):
            start_ran = ran
            end_ran = ran + Interval
            if end_ran > seq_end:
                end_ran = seq_end 
            if native_len >start_ran and   native_len <= end_ran:
                #featuredata_all_pad = np.zeros((featuredata_all_new.shape[0],end_ran*(20+20+3+2+1+1+1+6+120+35+1)+1))
                featuredata_all_pad = np.zeros((featuredata_all_new.shape[0],end_ran*(20+20+3+2+1+1+1+6+24+7+1)+1))
                featuredata_all_pad[:featuredata_all_new.shape[0],:featuredata_all_new.shape[1]] = featuredata_all_new
                
                #print "fea_len: ",fea_len
                fea_len_new=end_ran
                if fea_len_new in data_all_dict:
                    data_all_dict[fea_len_new].append(featuredata_all_pad)
                else:
                    data_all_dict[fea_len_new]=[]
                    data_all_dict[fea_len_new].append(featuredata_all_pad)               
            else:
                continue
    
    
    print("--- Data loading: %s seconds ---" % (time.time() - start_time))            
    # list(data_all_dict.keys()).
    for key in data_all_dict.keys():
        myarray = np.asarray(data_all_dict[key])
        data_all_dict[key] = myarray.reshape(len(myarray),myarray.shape[2])
        print "keys: ", key, " shape: ", data_all_dict[key].shape

    return data_all_dict