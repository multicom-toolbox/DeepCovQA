# DeepCovQA

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
wget http://sysbio.rnet.missouri.edu/bdm_download/DeepCovQA.tar.gz
tar zxvf DeepCovQA.tar.gz
# Alternately
git clone https://github.com/multicom-toolbox/DeepCovQA.git
```

**(B) Install DeepQA**  
```
cd ~/DeepCovQA/  
cd tools 
wget http://sysbio.rnet.missouri.edu/bdm_download/DeepQA_cactus/DeepQA.tar.gz
tar -zxf DeepQA.tar.gz
cd DeepQA
perl ./configure.pl 
cd ./test/
../bin/DeepQA.sh T0709.fasta T0709 test_T0709
```

**(C) Install theano, Keras, and h5py and Update keras.json**  

(a) Install theano: 
```
sudo pip install theano
```
(b) Install Keras:
```
sudo pip install keras
```
(c) Install the h5py library:  
```
sudo pip install python-h5py
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

**(D) Install Legacy Blast**  
```
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/legacy/2.2.26/blast-2.2.26-x64-linux.tar.gz
tar zxvf blast-2.2.26-x64-linux.tar.gz
```

**(E) Install SCRATCH Suite** 
```
cd ~/DeepCovQA/
cd tools
wget http://download.igb.uci.edu/SCRATCH-1D_1.1.tar.gz
tar zxvf SCRATCH-1D_1.1.tar.gz
cd SCRATCH-1D_1.1/
perl install.pl
// Replace the 32-bit blast with 64-bit version (if needed)
mv ./pkg/blast-2.2.26 ./pkg/blast-2.2.26.original
cp -r ~/blast-2.2.26 ./pkg/ (64-bit Legacy Blast is already installed)
```

**[OPTIONAL] Verify SCRATCH installation**  
```
cd ~/DNCON2/SCRATCH-1D_1.1/
cd doc
../bin/run_SCRATCH-1D_predictors.sh test.fasta test.out 4
```

**(F) Install EMBOSS-6.6.0**  
```
cd ~/DeepCovQA/
cd tools
wget ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz
tar zxf EMBOSS-6.6.0.tar.gz
cd EMBOSS-6.6.
./configure --prefix=./
make
make install
```

**(F) Install Rosetta package**  
```
cd ~/DeepCovQA/
cd tools 
wget http://sysbio.rnet.missouri.edu/bdm_download/rosetta_2014.16.56682_bundle.tgz 
tar -zxf  rosetta_2014.16.56682_bundle.tgz
```

**(G) Configure scripts**  

(a) Update the following variables in the script 'tools/proq3/paths.sh'
```
R_SCRIPT="/home/jh7x3/tools/R-3.1.1/bin/Rscript"  
```
If you don't have "zoo" package, install it by launching R and typing install.packages("zoo")


**(H)  Verify DeepCovQA scripts**

(a) [OPTIONAL] Verify the script 'run-ccmpred-freecontact-psicov.pl'
```

perl ./scripts/P1_runpredisorder.pl ./test/T0709.fasta ./tools/predisorder1.1/bin/predict_diso.sh ./test/T0709_out

perl ./scripts/split_fasta_to_folder.pl  ./test/T0709.fasta  ./test/T0709_out/pssm  ./test/T0709_out/pssm/PSSM.list
python ./scripts/run_many_sequence.py --inputfile ./test/T0709_out/pssm//PSSM.list  --seqdir ./test/T0709_out/pssm/ --script_dir ./DeepCovQA/scripts/  --pspro_dir ./tools/DeepQA/tools/pspro2/  --nr_db ./tools/DeepQA/tools/nr/nr   --big_db ./tools/DeepQA/tools/sspro4/data/big/big_98_X  --outputdir ./DeepCovQA/test/T0709_out/pssm/


perl ./scripts/gen_feature_multi.pl ./test/T0709.fasta   ./test/T0709_out/aa_ss_sa  ./test/T0709_out/aa_ss_sa/T0709_ss_sa.fea ./ ./tools/SCRATCH-1D_1.1/


./tools/DeepQA/bin/DeepQA.sh ./test/T0709.fasta ./test/T0709  ./test/T0709_out/deepqa


perl ./scripts/P1_run_features_for_rosetta_energy.pl ./test/T0709  ./scripts/run_ProQ3_model_local.sh T0709  ./test/T0709_out/rosetta

```
