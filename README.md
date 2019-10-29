# CNNQA
Deep convolutional neural networks for protein model quality assessment


Test Environment
--------------------------------------------------------------------------------------
64-bit PC - Ubuntu 16.04 LTS

CentOS Linux 7 (Core)

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

```
Examples:

$ cat ./test/T0709_out/aa_ss_sa//T0709/T0709.ss
T0709
CCCCCECCECCCECCCHHHCCCCCEECCCCEEE

$ cat ./test/T0709_out/aa_ss_sa//T0709/T0709.acc
T0709
e-e-eeeeeeeee-eeeee-eee-e-eeeee-e
```

(b) Disorder prediction
```
cd ~/CNNQA/  
mkdir -p  test/T0709_out/
perl ./scripts/P1_runpredisorder.pl ./test/T0709.fasta ./tools/predisorder1.1/bin/predict_diso.sh ./test/T0709_out/T0709.disorder

more ./test/T0709_out/T0709.disorder

Output:
GCPRPRGDNPPLTCSQDSDCLAGCVCGPNGFCG
DDDDDDDDDDDDDDDDDDDODOOODODDDDDDD
0.844 0.752 0.854 0.792 0.731 0.618 0.631 0.607 0.592 0.56 0.524 0.537 0.522 0.504 0.53 0.571 0.522 0.512 0.512 0.435 0.501 0.412 0.322 0.163 0.507 0.481 0.527 0.539 0.57 0.622 0.623 0.58 0.695

```

(c) PSSM prediction
```
cd ~/CNNQA/  
mkdir -p  test/T0709_out/pssm
source python_virtualenv_qa/bin/activate
perl ./scripts/split_fasta_to_folder.pl  ./test/T0709.fasta  ./test/T0709_out/pssm  ./test/T0709_out/pssm/PSSM.list
python ~/CNNQA/scripts/run_many_sequence.py --inputfile ~/CNNQA/test/T0709_out/pssm//PSSM.list  --seqdir ~/CNNQA/test/T0709_out/pssm/ --script_dir ~/CNNQA/scripts/  --pspro_dir ~/CNNQA/tools/DeepQA/tools/pspro2/  --nr_db ~/CNNQA/tools/DeepQA/tools/nr/nr   --big_db ~/CNNQA/tools/DeepQA/tools/sspro4/data/big/big_98_X  --outputdir ~/CNNQA/test/T0709_out/pssm/
```

```

```
(d) Global energy score

```
cd ~/CNNQA/  
mkdir -p  test/T0709_out/deepqa
./tools/DeepQA/bin/DeepQA.sh ~/CNNQA/test/T0709.fasta ~/CNNQA/test/T0709  ~/CNNQA/test/T0709_out/deepqa

more ~/CNNQA/test/T0709_out/deepqa/DeepQA_predictions.txt 
server02_TS1	0.67492
server05_TS1	0.70553
server01_TS1	0.62495
server04_TS1	0.65402
server20_TS1	0.65512
server03_TS1	0.64157
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

```
more ~/CNNQA/test/T0709_out/cnnqa_prediction.txt

server04_TS1 0.42369696969697 13.03800 10.73117 8.96967 7.84303 7.14159 6.42102 5.93556 5.27732 4.92141 4.36968 4.13160 3.85842 3.59111 3.51296 3.51485 3.33758 3.64299 3.32786 2.66825 2.23299 2.16602 1.98023 1.79759 1.63
553 1.53159 1.47175 1.57423 2.38159 2.65286 2.34148 3.89906 5.43124 7.34015
server03_TS1 0.244 12.96352 11.19187 9.07755 9.36823 8.54138 8.14147 7.39810 6.76978 6.35322 6.25694 6.11346 4.99721 5.41461 6.22171 6.01248 4.94903 6.28008 5.09555 3.37312 3.51814 3.04673 3.43511 4.27367 3.20835 3.12889
 3.93427 2.60802 5.72165 6.54535 6.49567 6.60704 6.78360 7.35180
server02_TS1 0.218787878787879 12.92555 10.95947 8.90688 9.11084 8.68887 8.19832 7.49031 6.91729 6.54522 6.50172 6.28066 5.62634 5.36674 6.27796 6.72148 5.46213 6.82938 6.10658 4.34379 4.03088 3.36334 4.01413 4.27376 3.7
0689 3.43354 3.91280 3.30827 5.79596 6.86534 6.78042 6.83866 7.06309 7.62098
server20_TS1 0.193787878787879 12.95286 10.57254 8.62333 8.64976 8.43831 8.16921 7.52131 6.61277 6.08345 5.86340 5.56862 5.23658 4.68728 5.40952 6.24747 5.42172 5.82595 5.79051 4.38909 4.15675 3.66015 4.46298 4.52066 4.9
3993 5.27136 5.43951 6.13127 8.17565 8.32486 8.34816 8.50581 8.90916 9.51023
server01_TS1 0.160515151515151 12.99038 11.60374 9.31985 9.67905 9.62410 9.38118 9.20264 8.72803 8.26637 7.75265 7.63331 6.69149 7.06099 6.91081 6.93759 6.88198 6.75154 6.70573 4.86989 5.16535 4.64878 5.87310 6.61991 5.1
4578 5.76509 6.55558 4.23555 6.82708 6.90724 6.80199 6.80967 7.03906 7.60786
server05_TS1 0.109363636363636 12.98078 12.13569 9.56474 10.14403 10.34882 10.31552 10.29324 9.95418 9.55113 9.11604 8.93996 8.67282 8.18791 7.99373 7.91369 7.85933 7.85584 7.77035 7.84253 7.85840 7.95919 8.06622 7.96380
 7.85353 7.74676 7.79368 7.90726 8.07966 8.05442 7.90851 7.78660 7.98189 8.68772
```
