# CNNQA
Deep convolutional neural networks for protein model quality assessment


Test Environment
--------------------------------------------------------------------------------------
64-bit PC - Ubuntu 16.04 LTS


Installation Steps
--------------------------------------------------------------------------------------

**(A) Download and Unzip CNNQA package**  
Create a working directory called 'CNNQA' where all scripts, programs and databases will reside:
```
cd ~
mkdir CNNQA
```
Download the CNNQA code:
```
cd ~/CNNQA/
wget http://sysbio.rnet.missouri.edu/bdm_download/CNNQA/CNNQA_source_code.tar.gz
tar zxvf CNNQA_source_code.tar.gz
mv CNNQA_source_code/* ./
rm -rf CNNQA_source_code

# Alternately
git clone https://github.com/multicom-toolbox/CNNQA.git
```

**(B) Download software package**  
```
cd ~/CNNQA/  
wget http://sysbio.rnet.missouri.edu/bdm_download/CNNQA/tools.tar.gz
tar -zxf tools.tar.gz
```

**(C) Install theano, Keras, and h5py and Update keras.json**  


(a) Create python virtual environment (if not installed)
```
cd ~/CNNQA/  
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
cd ~/CNNQA/  
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
cd ~/CNNQA/
cd tools
cd EMBOSS-6.6.0
./configure --prefix=/home/jh7x3/CNNQA/tools/EMBOSS-6.6.0
make
make install
```


**(G) Configure scripts**  

(a) Update the path of Rscript in the script './configure.pl', (assume R is pre-installed)
```
$R_SCRIPT="/home/tools/R-3.2.0/bin/Rscript";
```
If you don't have "zoo" package, install it by launching R and typing install.packages("zoo")

```
$R

>install.packages("zoo")
>library("zoo")
>q()
```
We used R-3.2.0, which can be downloaded from https://cran.r-project.org/src/base/R-3/R-3.2.0.tar.gz
```
cd /home/tools/
wget https://cran.r-project.org/src/base/R-3/R-3.2.0.tar.gz
cd /home/tools/R-3.2.0/
./configure  --prefix=/home/tools/R-3.2.0  --with-readline=no --with-x=no
make
make insatll
```

(b) Configure software

```
cd ~/CNNQA/ 
perl ./configure.pl
```

**(H) Verify software installation**  

(a) Secondary structure prediction
```
cd ~/CNNQA/  
mkdir -p  test/T0709_out/aa_ss_sa
perl ./scripts/gen_feature_multi.pl ./test/T0709.fasta   ./test/T0709_out/aa_ss_sa  ./test/T0709_out/aa_ss_sa/T0709_ss_sa.fea ./ ./tools/SCRATCH-1D_1.1/
```

(b) Disorder prediction
```
cd ~/CNNQA/  
mkdir -p  test/T0709_out/
perl ./scripts/P1_runpredisorder.pl ./test/T0709.fasta ./tools/predisorder1.1/bin/predict_diso.sh ./test/T0709_out/T0709.disorder

more ./test/T0709_out/T0709.disorder
```

(c) PSSM prediction
```
cd ~/CNNQA/  
mkdir -p  test/T0709_out/pssm
source python_virtualenv_qa/bin/activate
perl ./scripts/split_fasta_to_folder.pl  ./test/T0709.fasta  ./test/T0709_out/pssm  ./test/T0709_out/pssm/PSSM.list
python ~/CNNQA/scripts/run_many_sequence.py --inputfile ~/CNNQA/test/T0709_out/pssm//PSSM.list  --seqdir ~/CNNQA/test/T0709_out/pssm/ --script_dir ~/CNNQA/scripts/  --pspro_dir ~/CNNQA/tools/DeepQA/tools/pspro2/  --nr_db ~/CNNQA/tools/DeepQA/tools/nr/nr   --big_db ~/CNNQA/tools/DeepQA/tools/sspro4/data/big/big_98_X  --outputdir ~/CNNQA/test/T0709_out/pssm/
```

(d) Global energy score

```
cd ~/CNNQA/  
mkdir -p  test/T0709_out/deepqa
./tools/DeepQA/bin/DeepQA.sh ~/CNNQA/test/T0709.fasta ~/CNNQA/test/T0709  ~/CNNQA/test/T0709_out/deepqa
```

(e) Rosetta Energy score
```
mkdir -p  test/T0709_out/rosetta
perl ./scripts/P1_run_features_for_rosetta_energy.pl ~/CNNQA/test/T0709  ~/CNNQA/scripts/run_ProQ3_model_local.sh T0709  ~/CNNQA/test/T0709_out/rosetta
```

**(I)  Run CNNQA**
```
mkdir -p  test/T0709_out
sh bin/run_CNNQA.sh  T0709 ~/CNNQA/test/T0709.fasta ~/CNNQA/test/T0709  ~/CNNQA/test/T0709_out/
```
