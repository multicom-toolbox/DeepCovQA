#########################################################################################################################
DeepQA: Master estimation of model accuracy with deep neural networks
Free for Academic only.
All rights reserved.

Authors:
Renzhi Cao             rcrg4@mail.missouri.edu
debswapna bhattacharya db279@mail.missouri.edu
Jie Hou                jh7x3@mail.missouri.edu
Jianlin Cheng          chengji@missouri.edu         
Department of Computer Science
University of Missouri, Columbia

Please send your questions, feedback and comments to: chengji@missouri.edu.

#########################################################################################################################
1. INSTALLATION
#########################################################################################################################

The software was developed and tested on the RedHat 4.4.7 and ARCH Linux 3.8.11

1). Download the DeepQA tool (DeepQA_package.tar.gz) at http://cactus.rnet.missouri.edu/DeepQA/, 
	The DeepQA tool includes:
	--------------------------------------------
	Name                Size          Size
					(decompressed) (compressed)
	--------------------------------------------
	README.txt      4.00   K      
	bin/            8.00   K      
	data/           4.00   K      
	script/         392    K      
	test/           132    K      

	TOTAL          ~5.80   GB        ~2.00  GB
	--------------------------------------------
2). Unzip DeepQA_pacage.tar.gz
	$ tar -zxvf DeepQA_package.tar.gz

3). Go to the DeepQA folder, run the configure file
	$ ./configure.pl

4). Installation is done if you don't see any errors, otherwise fix it by installing the missing tools or contact the authors.

-------------------------------------------------------------------------------------------------------------------------

There should be one file named DeepQA.sh in the bin directory, simply run it and you will see three inputs are needed. path of fasta sequence, directory of input pdbs, directory of output.

(1). Path of sequence in fasta format. The file is in fasta format, and the sequence inside should be the sequence of the 3D model (pdb) to be evaluated.

(2). Path of the folder including all models for evaluation. All models in pdb format with the same sequence is put together inside this input folder. 

(3). Path of the output folder. The evaluation result (DeepQA.scores) will be stored in this folder. 

     For the final score, the first column in the output prediction file is the model name, the second column is the global quality score. 


-------------------------------------------------------------------------------------------------------------------------

#########################################################################################################################
2. USAGE
#########################################################################################################################

Testing example:
1) Go to test folder in the DeepQA tool, run:
	$ cd ./test/
	$ ../bin/DeepQA.sh T0709.fasta T0709 test_T0709

   The predicted score can be found in 'test_T0709/Predictions.txt'

-------------------------------------------------------------------------------------------------------------------------





scripts/run_DeepCovQA.pl
scripts/P1_feature_generation_parallel.pl


configure   tools/predisorder1.1
		\DeepCovQA\tools\predisorder1.1\configure.pl


##### install DeepQA
cd tools 
wget http://sysbio.rnet.missouri.edu/bdm_download/DeepQA_cactus/DeepQA.tar.gz
tar -zxf DeepQA.tar.gz
cd DeepQA
perl ./configure.pl 
cd ./test/
../bin/DeepQA.sh T0709.fasta T0709 test_T0709

####### install 64-bit blast 

cd tools 
tar -zxf blast-2.2.26-x64-linux.tar.gz



(F) Install SCRATCH Suite

cd tools 
wget http://download.igb.uci.edu/SCRATCH-1D_1.1.tar.gz
tar zxf SCRATCH-1D_1.1.tar.gz
cd SCRATCH-1D_1.1/
perl install.pl
// Replace the 32-bit blast with 64-bit version (if needed)
mv ./pkg/blast-2.2.26 ./pkg/blast-2.2.26.original
cp -r ../blast-2.2.26 ./pkg/ (64-bit Legacy Blast is already installed)


##### install EMBOSS-6.6.0
cd tools
wget ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz
tar zxf EMBOSS-6.6.0.tar.gz
cd EMBOSS-6.6.
./configure --prefix=./
make
make install


##### install Rosetta package
cd tools 
wget http://sysbio.rnet.missouri.edu/bdm_download/rosetta_2014.16.56682_bundle.tgz 
tar -zxf  rosetta_2014.16.56682_bundle.tgz


## set proq3 
set R_SCRIPT in tools/proq3/paths.sh
If you don't have "zoo" package, install it by launching R and typing install.packages("zoo")



### install numpy, keras

source /home/casp13/python_virtualenv/bin/activate

#### test predisorder 


perl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/P1_runpredisorder.pl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709.fasta /home/jh7x3/DeepCov_QA/Github/DeepCovQA/tools/predisorder1.1/bin/predict_diso.sh /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out

perl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/split_fasta_to_folder.pl  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709.fasta  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/pssm  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/pssm/PSSM.list
python /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/run_many_sequence.py --inputfile /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/pssm//PSSM.list  --seqdir /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/pssm/ --script_dir /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/  --pspro_dir /home/jh7x3/DeepCov_QA/Github/DeepCovQA/tools/DeepQA/tools/pspro2/  --nr_db /home/jh7x3/DeepCov_QA/Github/DeepCovQA/tools/DeepQA/tools/nr/nr   --big_db /home/jh7x3/DeepCov_QA/Github/DeepCovQA/tools/DeepQA/tools/sspro4/data/big/big_98_X  --outputdir /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/pssm/


perl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/gen_feature_multi.pl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709.fasta   /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/aa_ss_sa  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/aa_ss_sa/T0709_ss_sa.fea /home/jh7x3/DeepCov_QA/Github/DeepCovQA /home/jh7x3/DeepCov_QA/Github/DeepCovQA/tools/SCRATCH-1D_1.1/


/home/jh7x3/DeepCov_QA/Github/DeepCovQA/tools/DeepQA/bin/DeepQA.sh  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709.fasta /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/deepqa


perl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/P1_run_features_for_rosetta_energy.pl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/run_ProQ3_model_local.sh T0709  /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709_out/rosetta


### test
perl /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/run_DeepCovQA.pl  T0709 /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709.fasta /home/jh7x3/DeepCov_QA/Github/DeepCovQA/test/T0709  /home/jh7x3/test/T0709_out/
python /home/jh7x3/DeepCov_QA/Github/DeepCovQA/scripts/DN_package/predict_score.py  /home/jh7x3/test/T0709_out/len_33/model.list    /home/jh7x3/test/T0709_out/len_33//ALL_scores/ /home/jh7x3/test/T0709_out/len_33/predictions/




*** average the three methods 
/home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_local_global_jointly_withRosetta_final_retrain_interative_inter_2_filter5_layers5_optnadam_ftsize6_epoch50_predicting-test-interactive-local-strategy1-withRosetta-bestval.txt
/storage/htc/bdm/jh7x3/DeepCov_QA_revision/Training_packages_complex_rosetta/All_retrain_for_paper_20180819/SingleDomain_proteins_training/local_global_jointly_reviewer1_results_newdata_20171020_withRosetta/results




/home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_local_only_withRosetta_intervalTune_interative_inter_1_filter5_layers5_optnadam_ftsize6_predicting-test-local-strategy1-withRosetta-bestval.txt
/storage/htc/bdm/jh7x3/DeepCov_QA_revision/Training_packages_complex_rosetta/All_parameter_local_predictions_summary_20180815/


/home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_local_global_interactive_withRosetta_original_predicting-test-interactive-local-win2-withRosetta-bestval.txt
mkdir /storage/htc/bdm/jh7x3/DeepCov_QA_revision/Training_packages_complex_rosetta/Re-evaluate_local_global_models_20180822
cd /storage/htc/bdm/jh7x3/DeepCov_QA_revision/Training_packages_complex_rosetta/Re-evaluate_local_global_models_20180822
cp -ar /storage/htc/bdm/jh7x3/scratch_file_backup/DeepCov_QA/Training_model_single_domain ./
cp -ar /storage/htc/bdm/jh7x3/scratch_file_backup/DeepCov_QA/Training_model ./

cp /storage/htc/bdm/jh7x3/DeepCov_QA_revision/Training_packages_complex_rosetta/SingleDomain_proteins_training/predict_main_iterative_strategy1_20171019_auto_local_global_withRosetta.py  ./predict_main_iterative_strategy1_20171019_auto_local_global_withRosetta_20180821.py  

cd /storage/htc/bdm/jh7x3/DeepCov_QA_revision/Training_packages_complex_rosetta/Re-evaluate_local_global_models_20180822
sbatch P1_run_sbatch_win15_singleDomain.sh



perl /home/jh7x3/DeepCov_QA/scripts/P31_average_three_methods_local_prediction.pl  /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_local_only_withRosetta_intervalTune_interative_inter_1_filter5_layers5_optnadam_ftsize6_predicting-test-local-strategy1-withRosetta-bestval.txt /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_local_global_jointly_withRosetta_final_retrain_interative_inter_2_filter5_layers5_optnadam_ftsize6_epoch50_predicting-test-interactive-local-strategy1-withRosetta-bestval.txt /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_local_global_interactive_withRosetta_original_predicting-test-interactive-local-win2-withRosetta-bestval.txt /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_three_method_average-withRosetta-bestval.txt

	**  /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_three_method_average-withRosetta-bestval.txt
	
	
perl /home/jh7x3/DeepCov_QA/scripts/P26_evaluate_local_prediction_jie_version_basedonCASP11_CASP12_inhouse.pl /home/jh7x3/DeepCov_QA/results/Testing_list_casp11_12_20171020.txt Singleset_three_method_average_withRosetta /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_three_method_average-withRosetta-bestval.txt  /home/jh7x3/DeepCov_QA/results/CASP12_local_QA_results_converted/stage1 /home/jh7x3/DeepCov_QA/results/Targets_out /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_eva_20180825
perl /home/jh7x3/DeepCov_QA/scripts/P26_evaluate_local_prediction_jie_version_basedonCASP11_CASP12_inhouse.pl /home/jh7x3/DeepCov_QA/results/Testing_list_casp11_12_20171020.txt Singleset_three_method_average_withRosetta /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_20180825/Singleset_three_method_average-withRosetta-bestval.txt  /home/jh7x3/DeepCov_QA/results/CASP12_local_QA_results_converted/stage2 /home/jh7x3/DeepCov_QA/results/Targets_out /home/jh7x3/DeepCov_QA/results/QA_local_evaluation/All_local_selected_predictions_for_paper_eva_20180825


						

