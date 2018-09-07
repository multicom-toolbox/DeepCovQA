# -*- coding: utf-8 -*-
"""
Created on Wed Feb 22 21:41:28 2017

@author: Jie Hou
"""

from keras.constraints import maxnorm

from keras.models import Model
from keras.layers import Activation, Dense, Dropout, Flatten, Input, Merge, Convolution1D, Convolution2D
from keras.layers.normalization import BatchNormalization


from Custom_class import K_max_pooling1d,KMaxPooling2D

# Helper to build a conv -> BN -> relu block
def _conv_bn_relu1D(nb_filter, nb_row, subsample,use_bias=True):
    def f(input):
        conv = Convolution1D(nb_filter=nb_filter, filter_length=nb_row, subsample_length=subsample,bias=use_bias,
                             init="he_normal", activation='relu', border_mode="same")(input)
        norm = BatchNormalization(mode=0, axis=2)(conv)
        return Activation("relu")(norm)
    
    return f


# Helper to build a conv -> BN -> relu block
def _conv_bn_Linear1D(nb_filter, nb_row, subsample,name,use_bias=True):
    def f(input):
        conv = Convolution1D(nb_filter=nb_filter, filter_length=nb_row, subsample_length=subsample,bias=use_bias,
                             init="he_normal", activation='relu', border_mode="same",name="%s_conv" % name)(input)
        norm = BatchNormalization(mode=0, axis=2,name="%s_nor" % name)(conv)
        return Activation("sigmoid",name="%s_acti" % name)(norm)
    
    return f




def DlocalQA_construct_local_win(win_array,ktop_node,use_bias,hidden_type):
    #### for model 40~100
    ss_feature_num = 3
    sa_feature_num = 2
    aa_feature_num = 20
    pssm_feature_num = 20
    ss_match = 1
    sa_match = 1
    #contact_match = 1
    disorder_num=1
    deepqa_energy_num=6
    #rosetta_high=120
    rosetta_high=24
    #rosetta_low=35
    rosetta_low=7
    
    
    ktop_node= ktop_node
    print "Setting hidden models as ",hidden_type
    ########################################## set up ss model
    DlocalQA_input_shape =(None,aa_feature_num+ss_feature_num+sa_feature_num+pssm_feature_num+ss_match+sa_match+disorder_num+deepqa_energy_num+rosetta_high+rosetta_low)
    nb_filters = 10
    nb_layers = 10
    #filter_sizes=[5,11,15,20]
    filter_sizes=win_array
    DlocalQA_input = Input(shape=DlocalQA_input_shape)
    DlocalQA_convs = []
    for fsz in filter_sizes:
        DlocalQA_conv = DlocalQA_input
        for i in range(0,nb_layers):
            DlocalQA_conv = _conv_bn_relu1D(nb_filter=nb_filters, nb_row=fsz, subsample=1,use_bias=use_bias)(DlocalQA_conv)
        
        DlocalQA_conv = _conv_bn_Linear1D(nb_filter=1, nb_row=fsz, subsample=1,use_bias=use_bias,name='local_start')(DlocalQA_conv)
        #pool = MaxPooling1D(pool_length=sequence_length-fsz+1)(conv)
        #DlocalQA_pool = K_max_pooling1d(ktop=ktop_node)(DlocalQA_conv)
        
        #DlocalQA_ResCNN = Model(input=[DlocalQA_input], output=DlocalQA_conv) 
        #DlocalQA_flatten = Flatten()(DlocalQA_conv)
        DlocalQA_convs.append(DlocalQA_conv)
    
    if len(filter_sizes)>1:
        DlocalQA_out = Merge(mode='average')(DlocalQA_convs)
    else:
        DlocalQA_out = DlocalQA_convs[0]  
       
    DlocalQA_ResCNN = Model(input=[DlocalQA_input], output=DlocalQA_out) 
    #sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
    DlocalQA_ResCNN.compile(loss="mean_squared_error", metrics=['mse'], optimizer="sgd")
    
    return DlocalQA_ResCNN



def DlocalQA_construct_global_win(win_array,ktop_node,output_dim,use_bias,hidden_type):
    #### for model 40~100
    ss_feature_num = 3
    sa_feature_num = 2
    aa_feature_num = 20
    pssm_feature_num = 20
    ss_match = 1
    sa_match = 1
    #contact_match = 1
    disorder_num=1
    deepqa_energy_num=6
    rosetta_high=24
    rosetta_low=7
    ktop_node= ktop_node
    print "Setting hidden models as ",hidden_type
    ########################################## set up ss model
    DglobalQA_input_shape =(None,aa_feature_num+ss_feature_num+sa_feature_num+pssm_feature_num+ss_match+sa_match+disorder_num+deepqa_energy_num+rosetta_high+rosetta_low)
    nb_filters = 10
    nb_layers = 10
    #filter_sizes=[5,11,15,20]
    filter_sizes=win_array
    DglobalQA_input = Input(shape=DglobalQA_input_shape)
    DglobalQA_convs = []
    
    for fsz in filter_sizes:
        DglobalQA_conv = DglobalQA_input
        for i in range(0,nb_layers):
            DglobalQA_conv = _conv_bn_relu1D(nb_filter=nb_filters, nb_row=fsz, subsample=1,use_bias=use_bias)(DglobalQA_conv)
        
        #pool = MaxPooling1D(pool_length=sequence_length-fsz+1)(conv)
        DglobalQA_pool = K_max_pooling1d(ktop=ktop_node)(DglobalQA_conv)
        DglobalQA_flatten = Flatten()(DglobalQA_pool)
        DglobalQA_convs.append(DglobalQA_flatten)
    
    if len(filter_sizes)>1:
        DglobalQA_out = Merge(mode='concat')(DglobalQA_convs)
    else:
        DglobalQA_out = DglobalQA_convs[0]  
    
    #DglobalQA_dense1 = Dense(output_dim=500, init='he_normal', activation='sigmoid', W_constraint=maxnorm(3))(DglobalQA_out)
    DglobalQA_dense1 = Dense(output_dim=50, init='he_normal', activation=hidden_type, W_constraint=maxnorm(3))(DglobalQA_out) # changed on 20170314 to check if can visualzie better
    DglobalQA_dropout1 = Dropout(0.2)(DglobalQA_dense1)
    DglobalQA_output = Dense(output_dim=output_dim, init="he_normal", activation="sigmoid")(DglobalQA_dropout1)
    DglobalQA_ResCNN = Model(input=[DglobalQA_input], output=DglobalQA_output) 
    #sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
    DglobalQA_ResCNN.compile(loss="mean_squared_error", metrics=['mse'], optimizer="sgd")
    
    return DglobalQA_ResCNN


