#!/bin/sh
# prediction file for protein quality assessment #
if [ $# -lt 4 ]
then
	echo "need four parameters : target_id, path of fasta sequence, directory of input pdbs, directory of output"
	exit 1
fi

GLOBAL_PATH='/home/jh7x3/bdm_github/CNNQA/';

targetid=$1 #T0898
fasta=$2 #T0898.fasta
model_dir=$3 #T0898
outputfolder=$4 #T0898_out


source $GLOBAL_PATH/python_virtualenv_qa/bin/activate
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/DeepQA/libs:$LD_LIBRARY_PATH
export PATH=$GLOBAL_PATH/tools/EMBOSS-6.6.0/bin/:$PATH
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/EMBOSS-6.6.0/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/rosetta_2014.16.56682_bundle/main/source/build/external/release/linux/2.6/64/x86/gcc/4.4/default//:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/rosetta_2014.16.56682_bundle/main/source/build/src/release/linux/2.6/64/x86/gcc/4.4/default/:$LD_LIBRARY_PATH

echo "perl $GLOBAL_PATH/scripts/run_CNNQA.pl $targetid   $fasta  $model_dir  $outputfolder"				
perl $GLOBAL_PATH/scripts/run_CNNQA.pl $targetid   $fasta  $model_dir  $outputfolder				

