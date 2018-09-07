#!/bin/sh
# HumanQA prediction file for protein quality assessment #
if [ $# -lt 4 ]
then
	echo "need three parameters : path of fasta sequence, directory of input pdbs, directory of output"
	exit 1
fi

targetid=$1 #T0898
fasta=$2 #/home/casp13/Human_QA_package/Jie_dev_casp13/data/casp12_original_seq/T0898.fasta
model_dir=$3 #/home/casp13/Human_QA_package/HQA_cp12new//T0898/T0898
outputfolder=$4 #/home/casp13/Human_QA_package/HQA_cp12new//T0898


source /home/casp13/Human_QA_package/scripts/python_lib/HUMANqa_python_env/bin/activate
export LD_LIBRARY_PATH=/home/casp13/Human_QA_package/HUMAN/tools/DeepQA/libs:$LD_LIBRARY_PATH
export PATH=/home/casp13/Human_QA_package/HUMAN/tools/EMBOSS-6.6.0/bin/:$PATH
export LD_LIBRARY_PATH=/home/casp13/Human_QA_package/HUMAN/tools/EMBOSS-6.6.0/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/casp13/Human_QA_package/HUMAN/tools/rosetta_2014.16.56682_bundle/main/source/build/external/release/linux/2.6/64/x86/gcc/4.4/default//:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/casp13/Human_QA_package/HUMAN/tools/rosetta_2014.16.56682_bundle/main/source/build/src/release/linux/2.6/64/x86/gcc/4.4/default/:$LD_LIBRARY_PATH

echo "perl scripts/run_DeepCovQA.pl $targetid   $fasta  $model_dir  $outputfolder"				
perl scripts/run_DeepCovQA.pl $targetid   $fasta  $model_dir  $outputfolder				

