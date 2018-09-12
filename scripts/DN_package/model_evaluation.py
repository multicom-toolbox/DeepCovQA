from keras.models import model_from_json
from keras.engine.topology import Layer
import theano.tensor as T
from keras import backend as K
import os 
import numpy as np
from Custom_class import Dynamick_max_pooling1d, K_max_pooling1d,sum_local_out
from keras.models import model_from_json
#from Data_loading import import_DLS2FSVM
import numpy as np
import math


def chkdirs(fn):
  dn = os.path.dirname(fn)
  if not os.path.exists(dn): os.makedirs(dn)



import numpy as np
import theano.tensor as T
import keras.backend as K
epsilon = 1.0e-9
def custom_objective_local2global(y_true, y_pred):
    '''Just another crossentropy'''
    y_pred = K.clip(y_pred, epsilon, 1 - epsilon)
    y_pred = K.mean(y_pred,axis=1)
    y_true = K.reshape(y_true,(1,y_true.shape[0],y_true.shape[1]))
    loss = K.mean(K.square(y_pred - y_true))
    return loss

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


def predict_local(test_list,feature_dir,model_in,model_weight_in,outputfile,logfile):

  if os.path.exists(model_in):
      print "######## Loading existing model ",model_in;
      # load json and create model
      json_file_model = open(model_in, 'r')
      loaded_model_json = json_file_model.read()
      json_file_model.close()
      
      print("######## Loaded model from disk")
      DLS2F_ResCNN_local = model_from_json(loaded_model_json, custom_objects={'sum_local_out': sum_local_out,'Dynamick_max_pooling1d': Dynamick_max_pooling1d,'K_max_pooling1d': K_max_pooling1d})        
  else:
      raise Exception("######## Couldn't find initial model: "+model_in)
  
  if os.path.exists(model_weight_in):
      print "######## Loading existing weights ",model_weight_in;
      DLS2F_ResCNN_local.load_weights(model_weight_in)
      DLS2F_ResCNN_local.compile(loss="mean_squared_error", metrics=['mse'], optimizer="sgd")
  else:
      raise Exception("######## Couldn't find initial weights: "+model_weight_in)
 
 #casp_label      id      model   local_native_length     local_all_length
 #CASP11  T0759   Alpha-Gelly-Server_TS1  96      109
 
  Testlist_target2model_keys = dict()
  Testlist_model2len_keys = dict()
  Testlist_data_keys = dict()
  sequence_file=open(test_list,'r').readlines() 
  
  file_processed=0;

  for i in xrange(len(sequence_file)):
      if sequence_file[i].find('local_native_length') >0 :
          print "Skip line ",sequence_file[i]
          continue
      #source = sequence_file[i].split('\t')[0]
      targetid = sequence_file[i].split('\t')[1]
      modelid = sequence_file[i].split('\t')[2]
      orignal_length = sequence_file[i].split('\t')[4]

      fea_len=int(orignal_length)
      file_processed +=1 
      if file_processed % 100 == 0:
          print str(file_processed) + " processed"
      
      #### import model-based feature
      #print "Processing ",pdb_name
      DeepQA_energy_dir =  feature_dir + '/DeepQA_energy'
      SS_match_dir =  feature_dir + '/SS_match'
      SA_match_dir =  feature_dir + '/SA_match'
      deepQA_energy = DeepQA_energy_dir + '/' + targetid + '_' + modelid + '.DeepQAenergy'
      SS_matchfile = SS_match_dir + '/' + targetid + '_' + modelid + '.ss_match'
      SA_matchfile = SA_match_dir + '/' + targetid + '_' + modelid + '.sa_match'
      
      rosetta_dir = feature_dir + '/rosetta'+'/' + targetid 
      
      rosetta_highfile = rosetta_dir +'/' + modelid + '.pdb.features.highres.resetta.svm'
      rosetta_lowfile = rosetta_dir +'/' + modelid + '.pdb.features.lowres.resetta.svm'
        
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


      deepQA_energydata = import_DLS2FSVM(deepQA_energy,delimiter=' ')
      SA_matchdata = import_DLS2FSVM(SA_matchfile,delimiter=' ')
      SS_matchdata = import_DLS2FSVM(SS_matchfile,delimiter=' ')
      
      rosetta_highdata = import_DLS2FSVM(rosetta_highfile,delimiter=' ') #(91L, 121L)
      rosetta_lowdata = import_DLS2FSVM(rosetta_lowfile,delimiter=' ')#(91L, 36L)
      train_rosetta_highdata = rosetta_highdata[:,1:121] #(91L, 120L)  1:25 only score,no win
      train_rosetta_lowdata = rosetta_lowdata[:,1:36] #(91L, 35L)
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
      train_feature_rosetta_highdata=train_rosetta_highdata.reshape(fea_len,120)
      train_feature_rosetta_lowdata=train_rosetta_lowdata.reshape(fea_len,35)
      
      pssm_fea = pssmdata[:,1:]
      disorder_fea = disorderdata[:,1:]
      fea_len = (featuredata.shape[1]-1)/(20+3+2)
        
      if fea_len != disorder_fea.shape[1]:
            print "The aa feature length %i not equal to disorder feature length %i for target %s!" % (fea_len,disorder_fea.shape[1],targetid)
            raise Exception("The aa feature length %i not equal to disorder feature length %i!" % (fea_len,disorder_fea.shape[1]))
            
            
      train_feature = featuredata[:,1:]
      train_feature_seq = train_feature.reshape(fea_len,25)
      train_feature_aa = train_feature_seq[:,0:20]
      train_feature_ss = train_feature_seq[:,20:23]
      train_feature_sa = train_feature_seq[:,23:25]
      train_feature_pssm = pssm_fea.reshape(fea_len,20)
      train_feature_disorder=disorder_fea.reshape(fea_len,1)
    
      featuredata_global = np.concatenate((train_feature_aa,train_feature_ss,train_feature_sa,train_feature_pssm,train_feature_disorder), axis=1)
      featuredata_all = np.concatenate((featuredata_global,train_feature_SS_match,train_feature_SA_match,train_feature_rosetta_lowdata,train_feature_rosetta_highdata,train_feature_deepQA_energy), axis=1)
      ## load local and global score 
      global_score = np.zeros((1,1))
      local_score = np.zeros((fea_len,1))
      local_score_array=local_score.reshape(fea_len,1)
      
      complete_data = np.concatenate((local_score_array,featuredata_all), axis=1)

      ### remove the residue doesn't exist in native structure 
      
      
      # when predicting, predict all residue, but global score need normalize by length, compare evaluate both normalize or not
      complete_data_filtered = complete_data
      complete_data_filtered_local_score = complete_data_filtered[:,0]
      complete_data_filtered_feature = complete_data_filtered[:,1:]
      
      
      native_len = complete_data_filtered.shape[0] 
      complete_data_filtered_feature_flatten = complete_data_filtered_feature.reshape(1,complete_data_filtered_feature.shape[0]*complete_data_filtered_feature.shape[1])
      
      featuredata_all_tmp = np.concatenate((global_score.reshape((1,1)),complete_data_filtered_local_score.reshape(1,native_len),complete_data_filtered_feature_flatten), axis=1)
      
      
      
      #if native_len <30: # suppose k-max = 30
      #    native_len = 30
      #    featuredata_all_new = np.zeros((featuredata_all_tmp.shape[0],30*(20+20+3+2+1+1+1+6+120+35+1)+1))# additional 1 inside () because each residue has 1 local score 
      #    #featuredata_all_new = np.zeros((featuredata_all_tmp.shape[0],30*(20+20+3+2+1+1+1+6+24+7+1)+1))# additional 1 inside () because each residue has 1 local score 
      #    featuredata_all_new[:featuredata_all_tmp.shape[0],:featuredata_all_tmp.shape[1]] = featuredata_all_tmp
      #else:
      featuredata_all_new = featuredata_all_tmp
      
      
      mark_id = targetid+'_'+modelid
      
      if targetid in Testlist_target2model_keys:
            Testlist_target2model_keys[targetid].append(mark_id)
      else:
            Testlist_target2model_keys[targetid] = []
            Testlist_target2model_keys[targetid].append(mark_id)
      
      
      
      if mark_id in Testlist_data_keys:
            raise Exception("duplicate id: "+ mark_id)
      else:
            Testlist_data_keys[mark_id] = featuredata_all_new
            Testlist_model2len_keys[mark_id]=native_len
      
      
 
  print "Data loading finished!"
  
  predict_mod2local=dict()
  predict_mod2local_converted=dict()
  for key in Testlist_target2model_keys.keys():
        mark_id = Testlist_target2model_keys[key]

        for mod in mark_id:
            trainfeaturedata = Testlist_data_keys[mod]
            seq_len = Testlist_model2len_keys[mod]
      
      
            train_local = trainfeaturedata[:,1:seq_len+1]
            train_feature = trainfeaturedata[:,seq_len+1:]
            ## transform the local score to proq3 format 
            train_local = 1/(1+(train_local/3)**2) #https://arxiv.org/pdf/1602.05832.pdf
            
            
            if len(trainfeaturedata) < 1:
                print "len(trainfeaturedata): ",len(trainfeaturedata)
                continue
            
            train_feature_seq = train_feature.reshape(train_feature.shape[0],seq_len,45+1+1+1+6+120+35)
            train_feature_aa = train_feature_seq[:,:,0:20]
            train_feature_ss = train_feature_seq[:,:,20:23]
            train_feature_sa = train_feature_seq[:,:,23:25]
            train_feature_pssm = train_feature_seq[:,:,25:45]
            train_feature_disorder = train_feature_seq[:,:,45]
            train_feature_SS_match = train_feature_seq[:,:,46]
            train_feature_SA_match = train_feature_seq[:,:,47]
            train_feature_rosetta_lowdata = train_feature_seq[:,:,48:48+35]
            train_feature_rosetta_highdata = train_feature_seq[:,:,48+35:48+35+120]
            train_feature_deepQA_energy = train_feature_seq[:,:,203:209]
            min_pssm=-8
            max_pssm=16
            
            train_feature_pssm_normalize = np.empty_like(train_feature_pssm)
            train_feature_pssm_normalize[:] = train_feature_pssm
            train_feature_pssm_normalize=(train_feature_pssm_normalize-min_pssm)/(max_pssm-min_pssm)
            train_featuredata_all = np.concatenate((train_feature_aa,train_feature_ss,train_feature_sa,train_feature_pssm_normalize,train_feature_disorder.reshape((train_feature_disorder.shape[0],train_feature_disorder.shape[1],1)),train_feature_SS_match.reshape((train_feature_SS_match.shape[0],train_feature_SS_match.shape[1],1)),train_feature_SA_match.reshape((train_feature_SA_match.shape[0],train_feature_SA_match.shape[1],1)),train_feature_rosetta_lowdata,train_feature_rosetta_highdata,train_feature_deepQA_energy), axis=2)
            train_local_targets = np.zeros((train_local.shape[0], seq_len ), dtype=float)
            for i in range(0, train_local.shape[0]):
                train_local_targets[i] = train_local[i]
            
            
            score = DLS2F_ResCNN_local.predict([train_featuredata_all], batch_size=50, verbose=0)
            score_convert = 3* np.sqrt((1-score)/score)
            score_convert[score_convert>15]=15
            score_convert[score_convert<0]=0
            
            if mod in predict_mod2local:
                 raise Exception("duplicate id: "+ mod)
            else:
                 predict_mod2local[mod]=score
                 predict_mod2local_converted[mod]=score_convert
      
  with open(outputfile, "w") as myfile:
      myfile.write("Method DeepCov\n")
  
  #key='T0404_MULTICOM-CLUSTER_TS2'
  for key in predict_mod2local.keys():
     score = predict_mod2local[key]
     score_convert = predict_mod2local_converted[key] 
     global_score = np.mean(score.flatten('F'))
     with open(outputfile, "a") as myfile:
          myfile.write(key + " "+ str(global_score) + " " +  " ".join(np.char.mod('%f', score_convert.flatten('F'))) + "\n")



def predict_local_global_joint(test_list,feature_dir,model_in,model_weight_in,outputfile,logfile):

  if os.path.exists(model_in):
      print "######## Loading existing model ",model_in;
      # load json and create model
      json_file_model = open(model_in, 'r')
      loaded_model_json = json_file_model.read()
      json_file_model.close()
      
      print("######## Loaded model from disk")
      DLS2F_ResCNN_local = model_from_json(loaded_model_json, custom_objects={'sum_local_out': sum_local_out,'Dynamick_max_pooling1d': Dynamick_max_pooling1d,'K_max_pooling1d': K_max_pooling1d})        
  else:
      raise Exception("######## Couldn't find initial model: "+model_in)
  
  if os.path.exists(model_weight_in):
      print "######## Loading existing weights ",model_weight_in;
      DLS2F_ResCNN_local.load_weights(model_weight_in)
      DLS2F_ResCNN_local.compile(loss="mean_squared_error", metrics=['mse'], optimizer="sgd")
  else:
      raise Exception("######## Couldn't find initial weights: "+model_weight_in)
 
 #casp_label      id      model   local_native_length     local_all_length
 #CASP11  T0759   Alpha-Gelly-Server_TS1  96      109
 
  Testlist_target2model_keys = dict()
  Testlist_model2len_keys = dict()
  Testlist_data_keys = dict()
  sequence_file=open(test_list,'r').readlines() 
  
  file_processed=0;

  for i in xrange(len(sequence_file)):
      if sequence_file[i].find('local_native_length') >0 :
          print "Skip line ",sequence_file[i]
          continue
      #source = sequence_file[i].split('\t')[0]
      targetid = sequence_file[i].split('\t')[1]
      modelid = sequence_file[i].split('\t')[2]
      orignal_length = sequence_file[i].split('\t')[4]

      fea_len=int(orignal_length)
      file_processed +=1 
      if file_processed % 100 == 0:
          print str(file_processed) + " processed"
      
      #### import model-based feature
      #print "Processing ",pdb_name
      DeepQA_energy_dir =  feature_dir + '/DeepQA_energy'
      SS_match_dir =  feature_dir + '/SS_match'
      SA_match_dir =  feature_dir + '/SA_match'
      deepQA_energy = DeepQA_energy_dir + '/' + targetid + '_' + modelid + '.DeepQAenergy'
      SS_matchfile = SS_match_dir + '/' + targetid + '_' + modelid + '.ss_match'
      SA_matchfile = SA_match_dir + '/' + targetid + '_' + modelid + '.sa_match'
      
      rosetta_dir = feature_dir + '/rosetta'+'/' + targetid 
      
      rosetta_highfile = rosetta_dir +'/' + modelid + '.pdb.features.highres.resetta.svm'
      rosetta_lowfile = rosetta_dir +'/' + modelid + '.pdb.features.lowres.resetta.svm'
        
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


      deepQA_energydata = import_DLS2FSVM(deepQA_energy,delimiter=' ')
      SA_matchdata = import_DLS2FSVM(SA_matchfile,delimiter=' ')
      SS_matchdata = import_DLS2FSVM(SS_matchfile,delimiter=' ')
      
      rosetta_highdata = import_DLS2FSVM(rosetta_highfile,delimiter=' ') #(91L, 121L)
      rosetta_lowdata = import_DLS2FSVM(rosetta_lowfile,delimiter=' ')#(91L, 36L)
      train_rosetta_highdata = rosetta_highdata[:,1:121] #(91L, 120L)  1:25 only score,no win
      train_rosetta_lowdata = rosetta_lowdata[:,1:36] #(91L, 35L)
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
      train_feature_rosetta_highdata=train_rosetta_highdata.reshape(fea_len,120)
      train_feature_rosetta_lowdata=train_rosetta_lowdata.reshape(fea_len,35)
      
      pssm_fea = pssmdata[:,1:]
      disorder_fea = disorderdata[:,1:]
      fea_len = (featuredata.shape[1]-1)/(20+3+2)
        
      if fea_len != disorder_fea.shape[1]:
            print "The aa feature length %i not equal to disorder feature length %i for target %s!" % (fea_len,disorder_fea.shape[1],targetid)
            raise Exception("The aa feature length %i not equal to disorder feature length %i!" % (fea_len,disorder_fea.shape[1]))
            
            
      train_feature = featuredata[:,1:]
      train_feature_seq = train_feature.reshape(fea_len,25)
      train_feature_aa = train_feature_seq[:,0:20]
      train_feature_ss = train_feature_seq[:,20:23]
      train_feature_sa = train_feature_seq[:,23:25]
      train_feature_pssm = pssm_fea.reshape(fea_len,20)
      train_feature_disorder=disorder_fea.reshape(fea_len,1)
    
      featuredata_global = np.concatenate((train_feature_aa,train_feature_ss,train_feature_sa,train_feature_pssm,train_feature_disorder), axis=1)
      featuredata_all = np.concatenate((featuredata_global,train_feature_SS_match,train_feature_SA_match,train_feature_rosetta_lowdata,train_feature_rosetta_highdata,train_feature_deepQA_energy), axis=1)
      ## load local and global score 
      global_score = np.zeros((1,1))
      local_score = np.zeros((fea_len,1))
      local_score_array=local_score.reshape(fea_len,1)
      
      complete_data = np.concatenate((local_score_array,featuredata_all), axis=1)

      ### remove the residue doesn't exist in native structure 
      
      
      # when predicting, predict all residue, but global score need normalize by length, compare evaluate both normalize or not
      complete_data_filtered = complete_data
      complete_data_filtered_local_score = complete_data_filtered[:,0]
      complete_data_filtered_feature = complete_data_filtered[:,1:]
      
      
      native_len = complete_data_filtered.shape[0] 
      complete_data_filtered_feature_flatten = complete_data_filtered_feature.reshape(1,complete_data_filtered_feature.shape[0]*complete_data_filtered_feature.shape[1])
      
      featuredata_all_tmp = np.concatenate((global_score.reshape((1,1)),complete_data_filtered_local_score.reshape(1,native_len),complete_data_filtered_feature_flatten), axis=1)
      
      
      
      #if native_len <30: # suppose k-max = 30
      #    native_len = 30
      #    featuredata_all_new = np.zeros((featuredata_all_tmp.shape[0],30*(20+20+3+2+1+1+1+6+120+35+1)+1))# additional 1 inside () because each residue has 1 local score 
      #    #featuredata_all_new = np.zeros((featuredata_all_tmp.shape[0],30*(20+20+3+2+1+1+1+6+24+7+1)+1))# additional 1 inside () because each residue has 1 local score 
      #    featuredata_all_new[:featuredata_all_tmp.shape[0],:featuredata_all_tmp.shape[1]] = featuredata_all_tmp
      #else:
      featuredata_all_new = featuredata_all_tmp
      
      
      mark_id = targetid+'_'+modelid
      
      if targetid in Testlist_target2model_keys:
            Testlist_target2model_keys[targetid].append(mark_id)
      else:
            Testlist_target2model_keys[targetid] = []
            Testlist_target2model_keys[targetid].append(mark_id)
      
      
      
      if mark_id in Testlist_data_keys:
            raise Exception("duplicate id: "+ mark_id)
      else:
            Testlist_data_keys[mark_id] = featuredata_all_new
            Testlist_model2len_keys[mark_id]=native_len
      
      
 
  print "Data loading finished!"
  
  predict_mod2local=dict()
  predict_mod2local_converted=dict()
  for key in Testlist_target2model_keys.keys():
        mark_id = Testlist_target2model_keys[key]

        for mod in mark_id:
            trainfeaturedata = Testlist_data_keys[mod]
            seq_len = Testlist_model2len_keys[mod]
      
      
            train_local = trainfeaturedata[:,1:seq_len+1]
            train_feature = trainfeaturedata[:,seq_len+1:]
            ## transform the local score to proq3 format 
            train_local = 1/(1+(train_local/3)**2) #https://arxiv.org/pdf/1602.05832.pdf
            
            
            if len(trainfeaturedata) < 1:
                print "len(trainfeaturedata): ",len(trainfeaturedata)
                continue
            
            train_feature_seq = train_feature.reshape(train_feature.shape[0],seq_len,45+1+1+1+6+120+35)
            train_feature_aa = train_feature_seq[:,:,0:20]
            train_feature_ss = train_feature_seq[:,:,20:23]
            train_feature_sa = train_feature_seq[:,:,23:25]
            train_feature_pssm = train_feature_seq[:,:,25:45]
            train_feature_disorder = train_feature_seq[:,:,45]
            train_feature_SS_match = train_feature_seq[:,:,46]
            train_feature_SA_match = train_feature_seq[:,:,47]
            train_feature_rosetta_lowdata = train_feature_seq[:,:,48:48+35]
            train_feature_rosetta_highdata = train_feature_seq[:,:,48+35:48+35+120]
            train_feature_deepQA_energy = train_feature_seq[:,:,203:209]
            min_pssm=-8
            max_pssm=16
            
            train_feature_pssm_normalize = np.empty_like(train_feature_pssm)
            train_feature_pssm_normalize[:] = train_feature_pssm
            train_feature_pssm_normalize=(train_feature_pssm_normalize-min_pssm)/(max_pssm-min_pssm)
            train_featuredata_all = np.concatenate((train_feature_aa,train_feature_ss,train_feature_sa,train_feature_pssm_normalize,train_feature_disorder.reshape((train_feature_disorder.shape[0],train_feature_disorder.shape[1],1)),train_feature_SS_match.reshape((train_feature_SS_match.shape[0],train_feature_SS_match.shape[1],1)),train_feature_SA_match.reshape((train_feature_SA_match.shape[0],train_feature_SA_match.shape[1],1)),train_feature_rosetta_lowdata,train_feature_rosetta_highdata,train_feature_deepQA_energy), axis=2)
            train_local_targets = np.zeros((train_local.shape[0], seq_len ), dtype=float)
            for i in range(0, train_local.shape[0]):
                train_local_targets[i] = train_local[i]
            
            train_featuredata_all_padding = np.zeros((train_featuredata_all.shape[0],train_featuredata_all.shape[1]+1,train_featuredata_all.shape[2]), dtype=float)
            for i in range(0, train_featuredata_all.shape[0]):        
                train_featuredata_all_padding[i,0:train_featuredata_all.shape[1],:] = train_featuredata_all[i]
                            
            score = DLS2F_ResCNN_local.predict([train_featuredata_all_padding], batch_size=50, verbose=0)[0]
            local_score_predict = score[0:train_featuredata_all.shape[1],:]
            global_score_predict = score[train_featuredata_all.shape[1],:]
            
            score_convert = 3* np.sqrt((1-local_score_predict)/local_score_predict)
            score_convert[score_convert>15]=15
            score_convert[score_convert<0]=0
            
            if mod in predict_mod2local:
                 raise Exception("duplicate id: "+ mod)
            else:
                 predict_mod2local[mod]=score
                 predict_mod2local_converted[mod]=score_convert
      
  with open(outputfile, "w") as myfile:
      myfile.write("Method DeepCov\n")
  
  #key='T0404_MULTICOM-CLUSTER_TS2'
  for key in predict_mod2local.keys():
     score = predict_mod2local[key]
     score_convert = predict_mod2local_converted[key] 
     global_score = np.mean(score.flatten('F'))
     with open(outputfile, "a") as myfile:
          myfile.write(key + " "+ str(global_score) + " " +  " ".join(np.char.mod('%f', score_convert.flatten('F'))) + "\n")
