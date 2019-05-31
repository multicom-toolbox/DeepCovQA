# CNNQA

**Deep convolutional neural networks for protein model quality assessment**

Test Environment
--------------------------------------------------------------------------------------
64-bit PC - Ubuntu 16.04 LTS


Installation Steps
--------------------------------------------------------------------------------------

**(A) Download and Unzip DeepCovQA package**  
Create a working directory called 'DeepCovQA' where all scripts, programs and databases will reside:
```
cd ~
mkdir DeepCovQA
```
Download the DeepCovQA code:
```
cd ~/DeepCovQA/
wget http://sysbio.rnet.missouri.edu/bdm_download/DeepCovQA/DeepCovQA_source_code.tar.gz
tar zxvf DeepCovQA_source_code.tar.gz
mv DeepCovQA_source_code/* ./
rm -rf DeepCovQA_source_code

# Alternately
git clone https://github.com/multicom-toolbox/DeepCovQA.git
```

**(B) Download software package**  
```
cd ~/DeepCovQA/  
wget http://sysbio.rnet.missouri.edu/bdm_download/DeepCovQA/tools.tar.gz
tar -zxf tools.tar.gz
```

**(C) Install theano, Keras, and h5py and Update keras.json**  


(a) Create python virtual environment (if not installed)
```
cd ~/DeepCovQA/  
virtualenv python_virtualenv_qa
source python_virtualenv_qa/bin/activate
pip install --upgrade pip
```

(b) Install Keras:
```
pip install keras==1.2.2
```

(c) Install theano and numpy: 
```
pip install numpy==1.12.1
pip install theano==0.9.0
```

(d) Install the h5py library:  
```
pip install h5py
```

(d) Add the entry [“image_dim_ordering": "tf”,] to your keras..json file at ~/.keras/keras.json. After the update, your keras.json should look like the one below:  
```
{
"epsilon": 1e-07,
"floatx": "float32",
"image_dim_ordering":"tf",
"image_data_format": "channels_last",
"backend": "theano"
}
```

(e) Create keras version2
```
cd ~/DeepCovQA/  
virtualenv python_virtualenv_qa_keras2
source python_virtualenv_qa_keras2/bin/activate
pip install --upgrade pip
pip install numpy
pip install h5py
pip install keras
pip install Theano
```

**(F) Install EMBOSS-6.6.0**  
```
cd ~/DeepCovQA/
cd tools
cd EMBOSS-6.6.
./configure --prefix=./
make
make install
```


**(G) Configure scripts**  

(a) Update the following variables in the script './configure.pl'
```
$R_SCRIPT="/home/tools/R-3.1.1/bin/Rscript";
```
If you don't have "zoo" package, install it by launching R and typing install.packages("zoo")

```
$R

>install.packages("zoo")
>library("zoo")
>q()
```
(b) Configure software

```
perl ./configure.pl
```

**(H) Verify software installation**  

(a) Secondary structure prediction
```
cd ~/DeepCovQA/  

perl ./scripts/gen_feature_multi.pl ./test/T0709.fasta   ./test/T0709_out/aa_ss_sa  ./test/T0709_out/aa_ss_sa/T0709_ss_sa.fea ./ ./tools/SCRATCH-1D_1.1/
```

(b) Disorder prediction
```
cd ~/DeepCovQA/  

perl ./scripts/P1_runpredisorder.pl ./test/T0709.fasta ./tools/predisorder1.1/bin/predict_diso.sh ./test/T0709_out
```

(c) PSSM prediction
```
cd ~/DeepCovQA/  

source ~/python_virtualenv_qa/bin/activate
perl ./scripts/split_fasta_to_folder.pl  ./test/T0709.fasta  ./test/T0709_out/pssm  ./test/T0709_out/pssm/PSSM.list
python ./scripts/run_many_sequence.py --inputfile ./test/T0709_out/pssm//PSSM.list  --seqdir ./test/T0709_out/pssm/ --script_dir ./DeepCovQA/scripts/  --pspro_dir ./tools/DeepQA/tools/pspro2/  --nr_db ./tools/DeepQA/tools/nr/nr   --big_db ./tools/DeepQA/tools/sspro4/data/big/big_98_X  --outputdir ./DeepCovQA/test/T0709_out/pssm/
```

(d) Global energy score

```
cd ~/DeepCovQA/  

./tools/DeepQA/bin/DeepQA.sh ./test/T0709.fasta ./test/T0709  ./test/T0709_out/deepqa
```

(e) Rosetta Energy score
```
perl ./scripts/P1_run_features_for_rosetta_energy.pl ./test/T0709  ./scripts/run_ProQ3_model_local.sh T0709  ./test/T0709_out/rosetta
```

**(I)  Run DeepCovQA**
```
sh bin/run_DeepCovQA.sh  T0709 test/T0709.fasta test/T0709  ~/test/T0709_out/
```
