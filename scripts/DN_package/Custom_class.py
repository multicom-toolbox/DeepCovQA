
from keras.engine.topology import Layer
import theano.tensor as T
from keras import backend as K
import os 

def chkdirs(fn):
  dn = os.path.dirname(fn)
  if not os.path.exists(dn): os.makedirs(dn)



class K_max_pooling1d(Layer):
    
   # def __init__(self,  ktop=40, **kwargs):
    def __init__(self,  ktop, **kwargs):
        self.ktop = ktop
        super(K_max_pooling1d, self).__init__(**kwargs)
    
    def get_output_shape_for(self, input_shape):
        return (input_shape[0],self.ktop,input_shape[2])
    
    def call(self,x,mask=None):
        output = x[T.arange(x.shape[0]).dimshuffle(0, "x", "x"),
              T.sort(T.argsort(x, axis=1)[:, -self.ktop:, :], axis=1),
              T.arange(x.shape[2]).dimshuffle("x", "x", 0)]
        return output
    
    def get_config(self):
        config = {'ktop': self.ktop}
        base_config = super(K_max_pooling1d, self).get_config()
        return dict(list(base_config.items()) + list(config.items()))


       

class sum_local_out(Layer):

   # def __init__(self,  ktop=40, **kwargs):
    def __init__(self,  ktop, **kwargs):
        self.ktop = ktop
        super(sum_local_out, self).__init__(**kwargs)

    def get_output_shape_for(self, input_shape):
        return (input_shape[0],input_shape[2])

    def call(self,x,mask=None):
        output = T.sum(x,axis=1)
        return output

    def get_config(self):
        config = {'ktop': self.ktop}
        base_config = super(sum_local_out, self).get_config()
        return dict(list(base_config.items()) + list(config.items()))


class Dynamick_max_pooling1d(Layer):
    """ 
    not used
    """   
    #def __init__(self, incoming=None,inputdim=1, numLayers=5, currlayer=1, ktop=40, **kwargs):
    def __init__(self, numLayers, currlayer, ktop, **kwargs):
        self.numLayers = numLayers
        self.currlayer = currlayer
        self.ktop = ktop
        self.inputdim = 1
        super(Dynamick_max_pooling1d, self).__init__(**kwargs)
    
    def get_output_shape_for(self, input_shape):
        get_k=K.cast(K.max([self.ktop,T.ceil((self.numLayers-self.currlayer)/float(self.numLayers)*self.inputdim)]),'int32')
        return (input_shape[0],get_k,input_shape[2])
    
    def call(self,x,mask=None):
        get_k=K.cast(K.max([self.ktop,T.ceil((self.numLayers-self.currlayer)/float(self.numLayers)*self.inputdim)]),'int32')
        output = x[T.arange(x.shape[0]).dimshuffle(0, "x", "x"),
              T.sort(T.argsort(x, axis=1)[:, -get_k:, :], axis=1),
              T.arange(x.shape[2]).dimshuffle("x", "x", 0)]
        return output
    
    def get_config(self):
        config = {'numLayers': self.numLayers,
                  'currlayer': self.currlayer,
                  'ktop': self.ktop}
        base_config = super(Dynamick_max_pooling1d, self).get_config()
        return dict(list(base_config.items()) + list(config.items()))


