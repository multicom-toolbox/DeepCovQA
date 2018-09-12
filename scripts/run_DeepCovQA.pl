#! /usr/bin/perl -w
#
use Cwd;
#use lib "/scratch/jh7x3/DeepCov_human_QA/tools/MIME-Lite-2.117/lib/";

use lib "/home/tools/MIME-Lite-2.117/lib/";
use email;
use MIME::Lite;
require 5.003; # need this version of Perl or newer
use English; # use English names, not cryptic ones
use FileHandle; # use FileHandles instead of open(),close()
use Carp; # get standard error / warning messages
#use strict; # force disciplined use of variables
use Cwd 'abs_path';
use Scalar::Util qw(looks_like_number);
sub filter_score($$);

our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;



my $GLOBAL_PATH='/home/jh7x3/DeepCov_QA/Github/DeepCovQA/';

############## Revise the path ########################
my($H_script) = "$GLOBAL_PATH/scripts";
my($H_tool) = "$GLOBAL_PATH/tools";

########################################################


if(@ARGV <4 or @ARGV >6)
{
die "The number of parameter is not correct!\n";
}

$targetname = $ARGV[0];
$seqfile = abs_path($ARGV[1]);
$dir_models = abs_path($ARGV[2]);
$dir_output = abs_path($ARGV[3]);

$human_method_starttime = time();

if(!(-d $dir_output))
{
	`mkdir $dir_output`;
}


##### filter the models according to the fasta sequence 
if(!(-d "$dir_output/mod2"))
{
	`mkdir  $dir_output/mod2`;
}else{
	`rm -rf $dir_output/mod2/*`;
}

open(INPUT, "$seqfile") || die "ERROR! Could not open $seqfile\n";
@fasta_arr = <INPUT>;
close INPUT;
shift @fasta_arr;
$fasta_seq = shift @fasta_arr;
chomp $fasta_seq;

opendir(DIR,$dir_models) || die "Failed to open dir $dir_models\n";
@targets = readdir(DIR);
closedir(DIR);
$model_num = 0;

%len_seq = ();
$dup_len_id=0;
foreach $model (@targets)
{
	chomp $model;
	if($model eq '.' or $model eq '..')
	{
		next;
	}
	$file_PDB = "$dir_models/$model";
	$seq = "";
	open(INPUTPDB, "$file_PDB") || die "ERROR! Could not open $file_PDB\n";
	while(<INPUTPDB>){
		next if $_ !~ m/^ATOM/;
		next unless (parse_pdb_row($_,"aname") eq "CA");
		confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $file_PDB! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
		my $res = $AA3TO1{parse_pdb_row($_,"rname")};
		$seq .= $res;
	}
	close INPUTPDB;
	
	### copy all models to modAll for pairwise modelling
	$modAll = "$dir_output/modAll/";
	if(!(-d $modAll))
	{
		`mkdir $modAll`;
	}
	`cp $file_PDB $modAll`;
	
	
	#### Classify models based on length
	$len = length($seq);
	if(exists($len_seq{$len}))
	{
		if($len_seq{$len} eq $seq)
		{
			### need reindex pdb
			print "perl $GLOBAL_PATH/scripts/reindex_pdb.pl $file_PDB   $dir_output/modLen_$len/$model\n";
			system("perl $GLOBAL_PATH/scripts/reindex_pdb.pl $file_PDB   $dir_output/modLen_$len/$model");
			`cp $file_PDB $dir_output/modLen_${len}_noreindex/`;
		}else{
			print "Warning: same length but differerent sequence<$file_PDB>, skip\n";
			$dup_len_id++;
			
			$len = "${len}_dup$dup_len_id";
			if(exists($len_seq{$len}))
			{
				die "Duplicate id $len for <$file_PDB>\n\n";
			}
			$len_seq{$len} = $seq;
			`mkdir $dir_output/modLen_$len`;
			`mkdir $dir_output/modLen_${len}_noreindex/`;
			### need reindex pdb
			print "perl $GLOBAL_PATH/scripts/reindex_pdb.pl $file_PDB   $dir_output/modLen_$len/$model\n";
			system("perl $GLOBAL_PATH/scripts/reindex_pdb.pl $file_PDB   $dir_output/modLen_$len/$model");
			`cp $file_PDB $dir_output/modLen_${len}_noreindex/`;
			
			open(TMP,">$dir_output/len_$len.fasta") || die "Failed to open $dir_output/len_$len.fasta\n";
			print TMP ">len_$len\n";
			print TMP "$seq\n";
			close TMP;
			
			next;
		}
	}else{
		$len_seq{$len} = $seq;
		$moddir = $dir_output.'/modLen_'.$len;
		if(-d $moddir)
		{
			#`rm -rf $outdir/*`;
		}else{
			`mkdir $moddir`;
			print "$moddir created\n"
		}
		$moddir_noreindex = $dir_output.'/modLen_'.$len.'_noreindex';
		if(-d $moddir_noreindex)
		{
			#`rm -rf $outdir/*`;
		}else{
			`mkdir $moddir_noreindex`;
			print "$moddir_noreindex created\n"
		}
		
		### need reindex pdb
		print "perl $GLOBAL_PATH/scripts/reindex_pdb.pl $file_PDB   $dir_output/modLen_$len/$model\n";
		system("perl $GLOBAL_PATH/scripts/reindex_pdb.pl $file_PDB   $dir_output/modLen_$len/$model");
		`cp $file_PDB $moddir_noreindex/`;
		open(TMP,">$dir_output/len_$len.fasta") || die "Failed to open $dir_output/len_$len.fasta\n";
		print TMP ">len_$len\n";
		print TMP "$seq\n";
		close TMP;
	}
}

## redefine dir_models
$dir_models = "$dir_output/modAll";
#print "$model_num models are selected for evaluation\n";


##### create folder
my($TMP_output) = $dir_output."/"."TMP";
-s $TMP_output || system("mkdir $TMP_output");


$ALL_scores = $dir_output."/"."ALL_scores/";
system("mkdir -p  $ALL_scores");

$ALL_14_scores = $dir_output."/"."ALL_14_scores/";
system("mkdir -p $ALL_14_scores");


########## for single qa only
foreach $len (keys %len_seq)
{
	chomp $len;
	print "!!!!!!!!!!!!!!!! Predicting length group $len\n\n";
	$len_model_dir = $dir_output."/modLen_$len";
	$len_model_dir_noreindex = $dir_output."/modLen_${len}_noreindex";
	$len_seqfile = "$dir_output/len_$len.fasta";
	$len_tmpdir = "$dir_output/len_$len";
	if(-d $len_tmpdir)
	{
		#`rm -rf $len_tmpdir/*`;
	}else{
		`mkdir $len_tmpdir`;
	}
	
		
	##### create folder
	my($TMP_output) = $len_tmpdir."/"."TMP";
	-s $TMP_output || system("mkdir $TMP_output");

	$ALL_scores = $len_tmpdir."/"."ALL_scores/";
	system("mkdir -p  $ALL_scores");

	$ALL_14_scores = $len_tmpdir."/"."ALL_14_scores/";
	system("mkdir -p $ALL_14_scores");


	##### (1) Run feature generation
	print "\n\n##### (1) Run feature generation\n\n";
	print("perl  $GLOBAL_PATH/scripts/P1_feature_generation_parallel.pl  $targetname $len_seqfile $len_model_dir $len_tmpdir\n");
	$status = system("perl  $GLOBAL_PATH/scripts/P1_feature_generation_parallel.pl  $targetname $len_seqfile $len_model_dir $len_tmpdir");
	if($status)
	{
		die "Failed to run the feature generation\n";
	}


	print "!!!!!! Checking if all features are generated successfully\n\n";

		
	$all_features_list2 = "disorder_label,pssm_fea,fea_aa_ss_sa,fasta.ss,fasta.acc";
	@all_features = split(',',$all_features_list2);

	%LGA_score_list = ();
	$LGA_model_num=0;

	opendir(DIR,$len_model_dir) || die "Failed to open dir $len_model_dir\n";
	@targets = readdir(DIR);
	closedir(DIR);
	foreach $model (@targets)
	{
		chomp $model;
		if($model eq '.' or $model eq '..')
		{
			next;
		}
		$LGA_model_num++;
	  $LGA_score_list{$model} = 0; # this is for prediction
	}


	### 2. check if all methods have generated score for models as LGA
	$check_iteration=0;
	while($check_iteration<4)
	{
		sleep(10);
		$check_iteration++;
		$incomplete=0;
		foreach $method (@all_features)
		{
		  $method_score = "$len_tmpdir/ALL_scores/$targetname.$method";
		  if(!(-e $method_score))
		  {
			 print "$targetname incomplete (missing $method_score)\n";
			 $incomplete=1;
		  }
		}
		if($incomplete == 0)
		{
			print "\n\n!!!!!!!!!! All features are generated correctly\n\n";
			last;
		}
		print "\n\n##### (1) Re-Run feature generation with iteration $check_iteration\n\n";
		# perl /home/casp13/Human_QA_package/scripts/P1_feature_generation_casp13_parallel.pl  T0946 /home/casp13/Human_QA_package/Jie_dev_casp13/data/casp12_original_seq//T0946.fasta  /home/casp13/Human_QA_package/HQA_cp12//T0946/T0946 /home/casp13/Human_QA_package/HQA_cp12//T0946_para1
		print("perl $GLOBAL_PATH/scripts/P1_feature_generation_parallel.pl $targetname $len_seqfile $len_model_dir $len_tmpdir\n");
		$status = system("perl $GLOBAL_PATH/scripts/P1_feature_generation_parallel.pl $targetname $len_seqfile $len_model_dir $len_tmpdir");		
		if($status)# if failed, should we use at least one score?
		{
			die "Failed to run the feature generation\n";
		}
	}
	
	
	`mkdir $len_tmpdir/predictions/`;
	print("perl $GLOBAL_PATH/scripts/P2_generate_model_list.pl  $targetname  $len_seqfile  $len_model_dir  $len_tmpdir/model.list\n\n");	
	system("perl $GLOBAL_PATH/scripts/P2_generate_model_list.pl  $targetname  $len_seqfile  $len_model_dir  $len_tmpdir/model.list");	
	
	
	print("python $GLOBAL_PATH/scripts/DN_package/predict_score.py  $len_tmpdir/model.list   $len_tmpdir/ALL_scores/ $len_tmpdir/predictions/\n\n");	
	system("python $GLOBAL_PATH/scripts/DN_package/predict_score.py  $len_tmpdir/model.list   $len_tmpdir/ALL_scores/ $len_tmpdir/predictions/");	
	
	print("perl $GLOBAL_PATH/scripts/P6_average_three_methods_local_prediction.pl $len_tmpdir/predictions/local_prediction_InteractQA.txt  $len_tmpdir/predictions/local_prediction_JointQA.txt $len_tmpdir/predictions/local_prediction_LocalQA.txt $len_tmpdir/predictions/local_prediction_AverageQA.txt\n");
	system("perl $GLOBAL_PATH/scripts/P6_average_three_methods_local_prediction.pl $len_tmpdir/predictions/local_prediction_InteractQA.txt  $len_tmpdir/predictions/local_prediction_JointQA.txt $len_tmpdir/predictions/local_prediction_LocalQA.txt $len_tmpdir/predictions/local_prediction_AverageQA.txt");

	#### average three methods
	print("perl $GLOBAL_PATH/scripts/P4_convert_partial2full.pl  $len_tmpdir/predictions/local_prediction_AverageQA.txt  $len_model_dir_noreindex $seqfile    $dir_output/modLen_$len.predictions\n\n");
	system("perl $GLOBAL_PATH/scripts/P4_convert_partial2full.pl  $len_tmpdir/predictions/local_prediction_AverageQA.txt  $len_model_dir_noreindex $seqfile    $dir_output/modLen_$len.predictions");

	
	
}

print "cat $dir_output/modLen_*.predictions >$dir_output/deepcov_prediction.txt\n\n";
`cat $dir_output/modLen_*.predictions >$dir_output/deepcov_prediction.txt`;



print "perl $GLOBAL_PATH/scripts/P5_sort_score.pl $dir_output/deepcov_prediction.txt $dir_output/deepcov_prediction_sort.txt\n\n";
system("perl $GLOBAL_PATH/scripts/P5_sort_score.pl $dir_output/deepcov_prediction.txt $dir_output/deepcov_prediction_sort.txt\n\n");


$human_method_finishtime = time();
$method_diff_hrs = ($human_method_finishtime - $human_method_starttime)/3600;

print "\n\n####### HumanQA prediction done within $method_diff_hrs hr!!!!!\n\n";




sub parse_pdb_row{
	my $row = shift;
	my $param = shift;
	my $result;
	$result = substr($row,6,5) if ($param eq "anum");
	$result = substr($row,12,4) if ($param eq "aname");
	$result = substr($row,16,1) if ($param eq "altloc");
	$result = substr($row,17,3) if ($param eq "rname");
	$result = substr($row,22,5) if ($param eq "rnum");
	$result = substr($row,21,1) if ($param eq "chain");
	$result = substr($row,30,8) if ($param eq "x");
	$result = substr($row,38,8) if ($param eq "y");
	$result = substr($row,46,8) if ($param eq "z");
	print "Invalid row[$row] or parameter[$param]" if (not defined $result);
	$result =~ s/\s+//g;
	return $result;
}
