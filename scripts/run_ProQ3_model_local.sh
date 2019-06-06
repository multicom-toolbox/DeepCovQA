#!/bin/bash

if [ $# -ne 3 ]
then
	echo "need two parameters : input pdb , directory of input, directory of output"
	exit 1
fi


model=$1 #*.pdb
input_dir=$2
output_dir=${3%/}

GLOBAL_PATH='/home/jh7x3/bdm_github/CNNQA/';

source $GLOBAL_PATH/python_virtualenv_qa_keras2/bin/activate
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/DeepQA/libs:$LD_LIBRARY_PATH
export PATH=$GLOBAL_PATH/tools/EMBOSS-6.6.0/bin/:$PATH
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/EMBOSS-6.6.0/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/rosetta_2014.16.56682_bundle/main/source/build/external/release/linux/2.6/64/x86/gcc/4.4/default//:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$GLOBAL_PATH/tools/rosetta_2014.16.56682_bundle/main/source/build/src/release/linux/2.6/64/x86/gcc/4.4/default/:$LD_LIBRARY_PATH


substring='.pdb'
#if [ "${model/$substring}" = "$model" ] ; then
#  input_model=$model.pdb
#  echo "${substring} is not in ${model}, adding to it"
#  echo "$model -> $input_model" 
#else
#  input_model=$model
#  echo "Found pdb model ${input_model}"
#fi


subfix=${model: -4}
echo "subfix: $subfix"
if [ $subfix != '.pdb' ]; then
  input_model=$model.pdb
  echo "${substring} is not in ${model}, adding to it"
  echo "$model -> $input_model" 
else
  input_model=$model
  echo "Found pdb model ${input_model}"
fi    


input_model_path=$input_dir/$model
if [ ! -f $input_model_path ]; then
    echo " File ($input_model_path) not found!"
	exit 1
fi


if [ ! -d "$output_dir" ]; then
    echo " Dir ($output_dir) not found!"
	exit 1
fi


cd $GLOBAL_PATH/tools/proq3
source ./paths.sh       # Read in paths


echo "------------- run_all_external.pl ------------------"

cp $input_model_path $output_dir/$input_model
bin/run_all_external.pl -pdb $output_dir/$input_model

echo "------------- run ProQ3 ------------------"

./ProQ3_rosetta_only_local -m $output_dir/$input_model -r no -d yes

echo "------------- Checking the output ------------------"


if [[ ! -f $output_dir/$input_model.proq3.local || ! -f $output_dir/$input_model.proq3.global ]] ; then
    echo "ERROR: ProQ3 failed to run. The output files don't exist"
    exit 1
else
    echo "================ Congrats! Test run has passed without any problems! ===================="
fi



cp $output_dir/$input_model.features.highres.resetta.svm $output_dir/../
cp $output_dir/$input_model.features.lowres.resetta.svm $output_dir/../
cp $output_dir/$input_model.features.lowres_global.resetta.svm $output_dir/../

#rm $output_dir/$input_model*fasta*
rm $output_dir/$input_model*features*temp*
rm $output_dir/*rosetta.log
rm $output_dir/*svm
echo "zip -r -j $output_dir.zip $output_dir"
zip -r -j $output_dir.zip $output_dir
#rm -rf $output_dir
