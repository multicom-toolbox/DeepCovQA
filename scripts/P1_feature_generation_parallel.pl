#! /usr/bin/perl -w
#
 use Cwd;

 require 5.003; # need this version of Perl or newer
 use English; # use English names, not cryptic ones
 use FileHandle; # use FileHandles instead of open(),close()
 use Carp; # get standard error / warning messages
 #use strict; # force disciplined use of variables
 use Cwd 'abs_path';
 use Scalar::Util qw(looks_like_number);
 sub filter_score($$);


my $GLOBAL_PATH='/home/jh7x3/bdm_github/CNNQA/';



 ############## Revise the path ########################
 my($H_script) = "$GLOBAL_PATH/scripts";
 my($H_tool) = "$GLOBAL_PATH/tools";

 ########################################################


 if(@ARGV != 4)
 {
   die "The number of parameter is not correct!\n";
 }
 
 $targetname = $ARGV[0];
 $seqfile = $ARGV[1];
 $dir_models = $ARGV[2];
 $dir_output = $ARGV[3];
 
 ###### get sequence 
 open(IN,"$seqfile") || die "Fail to open file $seqfile\n";
 @content = <IN>;
 close IN;
 
 if(@content <2)
 {
   die "The seqfile should have two rows!\n";
 }
 
 shift @content;
 $sequence = shift @content;
 chomp $targetname;
 chomp $sequence;
 
 
$HumanQA_starttime = time();


##### create folder
-s $dir_output || system("mkdir $dir_output");
$dir_output = abs_path($dir_output);
my($TMP_output) = $dir_output."/"."TMP";
-s $TMP_output || system("mkdir $TMP_output");

#`rm -rf $TMP_output/*`;
my($LOG_output) = $dir_output."/"."LOG";
-s $LOG_output || system("mkdir $LOG_output");


 system("chmod 777 $TMP_output");
 my($tmp_tarball,$CASPTAR);
 $TMP_output = abs_path($TMP_output);
 
 
### mention here, we change the working directory to $TMP_output !
chdir($TMP_output);


## write out the fasta file
$|=1;
my($fasta_seq) = $TMP_output."/".$targetname.".fasta";
$OUT = new FileHandle ">$fasta_seq";
defined($OUT) || die "Cannot write to $fasta_seq!\n";
print $OUT ">$targetname\n";
print $OUT "$sequence";
$OUT->close();


my($fasta_seq2) = $TMP_output."/".$targetname;
$OUT = new FileHandle ">$fasta_seq2";
defined($OUT) || die "Cannot write to $fasta_seq2!\n";
print $OUT ">$targetname\n";
print $OUT "$sequence";
$OUT->close();


## write the new model
my($models_folder) = $TMP_output."/".$targetname."_2";
if(-d $models_folder)
{
	`rm -rf $models_folder/*`;
}else{
	mkdir($models_folder);
}
system("cp -R $dir_models/* $models_folder");


my($models_rosetta) = $TMP_output."/mod_rosetta";
if(-d $models_rosetta)
{
	`rm -rf $models_rosetta/*`;
}else{
	mkdir($models_rosetta);
}
system("cp -R $dir_models/* $models_rosetta");

my($models_dssp) = $TMP_output."/mod_dssp";
if(-d $models_dssp)
{
	`rm -rf $models_dssp/*`;
}else{
	mkdir($models_dssp);
}
system("cp -R $dir_models/* $models_dssp");


my($models_DeepQA) = $TMP_output."/mod_DeepQA";
if(-d $models_DeepQA)
{
	`rm -rf $models_DeepQA/*`;
}else{
	mkdir($models_DeepQA);
}
system("cp -R $dir_models/* $models_DeepQA");



my($pssm_dir) = $TMP_output."/PSSM";
if(-d $pssm_dir)
{
	`rm -rf $pssm_dir/*`;
}else{
	mkdir($pssm_dir);
}

my($disorder_dir) = $TMP_output."/Disorder";
if(-d $disorder_dir)
{
	`rm -rf $disorder_dir/*`;
}else{
	mkdir($disorder_dir);
}

my($ss_match_dir) = $TMP_output."/SS_match";
if(-d $ss_match_dir)
{
	`rm -rf $ss_match_dir/*`;
}else{
	mkdir($ss_match_dir);
}

my($sa_match_dir) = $TMP_output."/SA_match";
if(-d $sa_match_dir)
{
	`rm -rf $sa_match_dir/*`;
}else{
	mkdir($sa_match_dir);
}

my($aa_ss_sa) = $TMP_output."/AA_SS_SA";
if(-d $aa_ss_sa)
{
	`rm -rf $aa_ss_sa/*`;
}else{
	mkdir($aa_ss_sa);
}


 ### now we get every thing I need #####
 # we are at $TMP_output folder #
 my($OUTLOG,$logfile);
 $logfile = $TMP_output."/"."log.txt";
 $OUTLOG = new FileHandle ">$logfile";
 
 
#!!!!!!!!!  1. Run my NOVEL server to get several scores ###
 
############## running all jobs #####################
$ren_disorder=$TMP_output."/$targetname.disorder";
$ren_disorder_label=$TMP_output."/$targetname.disorder_label";
$ren_pssm=$TMP_output."/$targetname.pssm";
$ren_pssm_fea=$TMP_output."/$targetname.pssm_fea";
$ren_aa_ss_sa=$TMP_output."/$targetname.fea_aa_ss_sa";
$ren_ss=$TMP_output."/$targetname.ss";
$ren_acc=$TMP_output."/$targetname.acc";
$ren_models_dssp_ss=$TMP_output."/${targetname}_models_dssp_ss.txt";
$ren_models_dssp_sa=$TMP_output."/${targetname}_models_dssp_sa.txt";

 
$ALL_scores = $dir_output."/"."ALL_scores/";
-s $ALL_scores || system("mkdir -p  $ALL_scores");



$tools2		="rosetta,disorder,pssm,aa_ss_sa,DeepQA";
@tools		=split(/,/,$tools2);

$post_process = 0; 
$thread_num = @tools;
%thread_ids = ();
$EXEC_LIMIT_HRS = 60*60*12;#6 hrs
 
#$EXEC_LIMIT_HRS = 60*3;#10 hrs
for ($i = 0; $i < @tools; $i++)
{
	$tool = $tools[$i];
	if ( !defined( $kidpid = fork() ) )
	{
		die "can't create process $i to run <$tool>\n";
	}
	elsif ($kidpid == 0)
	{
		print "start thread $i\n";
		if ($tool eq "disorder")### 1. generating dfire score
		{		
			#run dfire:
			$disorder_starttime = time();
			if(-e "$dir_output/ALL_scores/$targetname.disorder_label")
			{
			  print "1. $dir_output/ALL_scores/$targetname.disorder_label already generated! Pass\n\n";
			  `cp $dir_output/ALL_scores/$targetname.disorder_label  $ren_disorder_label`;
			}else{
			   $res = "$LOG_output/disorder.is_running";
			   $cmd = "perl $GLOBAL_PATH/scripts/P1_runpredisorder.pl $fasta_seq  $GLOBAL_PATH/tools/predisorder1.1/bin/predict_diso.sh  $ren_disorder";
			   
			   $OUT = new FileHandle ">$res";
			   print $OUT "1. generating disorder score\n   $cmd \n\n";
			   print  "1. generating disorder score\n\n";
			   $OUT->close();
			   $ren_return_val=system("$cmd &>> $res");
				if ($ren_return_val)
				{
					$disorder_finishtime = time();
					$disorder_diff_hrs = ($disorder_finishtime - $disorder_starttime)/3600;
					print "1. disorder modeling finished within $disorder_diff_hrs hrs!\n\n";
					
					system("mv $LOG_output/disorder.is_running $LOG_output/disorder.is_finished");
					open(TMP,">>$LOG_output/disorder.is_finished");
					print TMP "ERROR! disorder execution <$cmd> failed!\n";
					print TMP "disorder modeling finished within $disorder_diff_hrs hrs!\n\n";
					close TMP;				
					print "ERROR! disorder execution failed!";
					exit 0;
				}
			   if(-e $ren_disorder)
			   {
					print "!!Successfully generated $ren_disorder\n\n";
					system("cp $ren_disorder $ALL_scores");
			   }else{
					print "!!Failed to generate $ren_disorder\n\n";
			   }
			   
			  $cmd = "perl $GLOBAL_PATH/scripts/P1_generate_disorder_feature.pl $ren_disorder   $fasta_seq    $disorder_dir";
			  $OUT = new FileHandle ">$res";
			  print $OUT "1. generating disorder features\n   $cmd \n\n";
			  print  "1. generating disorder features\n\n";
			  $OUT->close();
			  system("$cmd &>> $res");
			  
			  if(-e "$disorder_dir/$targetname.disorder_label" and -e "$disorder_dir/$targetname.disorder_prob")
			  {
				`cp $disorder_dir/$targetname.disorder_label $disorder_dir/$targetname.disorder_prob  $dir_output/ALL_scores/`;
				`cp $disorder_dir/$targetname.disorder_label  $ren_disorder`;
				`cp $disorder_dir/$targetname.disorder_label  $ren_disorder_label`;
			  }
			   
			}

			
			#ToDo: Check if disorder ran successfully			
			$disorder_finishtime = time();
			$disorder_diff_hrs = ($disorder_finishtime - $disorder_starttime)/3600;
			print "1. disorder modeling finished within $disorder_diff_hrs hrs!\n\n";
			if(-e "$LOG_output/disorder.is_running")
			{
				system("mv $LOG_output/disorder.is_running $LOG_output/disorder.is_finished");
			}
			open(TMP,">>$LOG_output/disorder.is_finished");
			print TMP "disorder modeling finished within $disorder_diff_hrs hrs!\n\n";
			close TMP;		
			exit 0;
		}elsif ($tool eq "pssm") ### 2. generating pssm score
		{
			#run pssm:
			$pssm_starttime = time();
			if(-e "$dir_output/ALL_scores/$targetname.pssm_fea")
			{
			  print "2. $dir_output/ALL_scores/$targetname.pssm_fea already generated! Pass\n\n";
			  `cp $dir_output/ALL_scores/$targetname.pssm_fea  $ren_pssm_fea`;
			}else{
			
			   $res = "$LOG_output/pssm.is_running";
			   $OUT = new FileHandle ">$res";
			   $cmd = "perl $H_script/split_fasta_to_folder.pl  $fasta_seq  $pssm_dir  $pssm_dir/PSSM.list";
			   #print("$cmd &>> $res\n");
			   system("$cmd &>> $res");
			   
			   $cmd = "python $H_script/run_many_sequence.py --inputfile $pssm_dir/PSSM.list  --seqdir $pssm_dir  --script_dir $H_script --pspro_dir $H_tool/DeepQA/tools/pspro2/  --nr_db $H_tool/DeepQA/tools/nr/nr   --big_db $H_tool/DeepQA/tools/sspro4/data/big/big_98_X  --outputdir $pssm_dir";
			   #print("$cmd &>> $res\n");
			   system("$cmd &>> $res");
			   
			   
			   print $OUT "2. generating pssm score\n   $cmd \n\n";
			   print  "2. generating pssm score\n\n";
			   $OUT->close();
			   $ren_return_val=system("$cmd &>> $res");
				if ($ren_return_val)
				{
					$pssm_finishtime = time();
					$pssm_diff_hrs = ($pssm_finishtime - $pssm_starttime)/3600;
					print "2. pssm modeling finished within $pssm_diff_hrs hrs!\n\n";
					
					system("mv $LOG_output/pssm.is_running $LOG_output/pssm.is_finished");
					open(TMP,">>$LOG_output/pssm.is_finished");
					print TMP "ERROR! pssm execution <$cmd> failed!\n";
					print TMP "pssm modeling finished within $pssm_diff_hrs hrs!\n\n";
					close TMP;				
					print "ERROR! pssm execution failed!";
					exit 0;
				}
			   $pssm_file  = "$pssm_dir/pssm_features/$targetname.pssm";
			   if(-e $pssm_file)
			   {
					print "!!Successfully generated $ren_pssm\n\n";
					system("cp $pssm_file $ren_pssm");
					system("cp $ren_pssm $ALL_scores");
					
					system("perl $H_script/process_pssm_file.pl  $pssm_dir/pssm_features/    $pssm_dir/pssm_features/");
					
					$pssm_file_fea  = "$pssm_dir/pssm_features/$targetname.pssm_fea";
					
					if(-e $pssm_file_fea)
				    {
						print "!!Successfully generated $pssm_file_fea\n\n";
						system("cp $pssm_file_fea $ren_pssm_fea");
						system("cp $ren_pssm_fea $ALL_scores");
					}
			   }else{
					print "!!Failed to generate $ren_pssm\n\n";
			   }
			   
			   			   
			   
			}

			
			#ToDo: Check if pssm ran successfully			
			$pssm_finishtime = time();
			$pssm_diff_hrs = ($pssm_finishtime - $pssm_starttime)/3600;
			print "2. pssm modeling finished within $pssm_diff_hrs hrs!\n\n";
			
			if(-e "$LOG_output/pssm.is_running")
			{
				system("mv $LOG_output/pssm.is_running $LOG_output/pssm.is_finished");
			}
			
			open(TMP,">>$LOG_output/pssm.is_finished");
			print TMP "pssm modeling finished within $pssm_diff_hrs hrs!\n\n";
			close TMP;		
			exit 0;
		}elsif ($tool eq "aa_ss_sa") ### 3. generating aa_ss_sa score
		{
			#run aa_ss_sa:
			$res = "$LOG_output/aa_ss_sa.is_running";
			$OUT = new FileHandle ">$res";
			$aa_ss_sa_starttime = time();
			if(-e "$dir_output/ALL_scores/$targetname.fea_aa_ss_sa" and -e "$dir_output/ALL_scores/$targetname.fasta.ss" and -e "$dir_output/ALL_scores/$targetname.fasta.acc")
			{
			  print "3. $dir_output/ALL_scores/$targetname.fea_aa_ss_sa already generated! Pass\n\n";
			  `cp $dir_output/ALL_scores/$targetname.fea_aa_ss_sa  $ren_aa_ss_sa`;
			  `cp $dir_output/ALL_scores/$targetname.fasta.ss  $ren_ss`;
			  `cp $dir_output/ALL_scores/$targetname.fasta.acc  $ren_acc`;
			}else{
			
			   #print "Failed to find $dir_output/ALL_scores/$targetname.fea_aa_ss_sa or $dir_output/ALL_scores/$targetname.fasta.ss or $dir_output/ALL_scores/$targetname.fasta.acc\n\n";
				
			   $cmd = "perl $H_script/gen_feature_multi.pl  $fasta_seq   $aa_ss_sa  $aa_ss_sa/${targetname}_ss_sa.fea $GLOBAL_PATH $H_tool/SCRATCH-1D_1.1/";
			   
			   
			   print $OUT "3. generating aa_ss_sa score\n   $cmd \n\n";
			   print  "3. generating aa_ss_sa score\n\n";
			   
			   $ren_return_val=system("$cmd &>> $res");
				if ($ren_return_val)
				{
					$aa_ss_sa_finishtime = time();
					$aa_ss_sa_diff_hrs = ($aa_ss_sa_finishtime - $aa_ss_sa_starttime)/3600;
					print "3. aa_ss_sa modeling finished within $aa_ss_sa_diff_hrs hrs!\n\n";
					
					system("mv $LOG_output/aa_ss_sa.is_running $LOG_output/aa_ss_sa.is_finished");
					open(TMP,">>$LOG_output/aa_ss_sa.is_finished");
					print TMP "ERROR! aa_ss_sa execution <$cmd> failed!\n";
					print TMP "aa_ss_sa modeling finished within $aa_ss_sa_diff_hrs hrs!\n\n";
					close TMP;				
					print "ERROR! aa_ss_sa execution failed!";
					exit 0;
				}
				
				#print("perl $H_script/P3_extract_protein_feature_from_single_file.pl  $aa_ss_sa/${targetname}_ss_sa.fea $aa_ss_sa/\n\n");
				system("perl $H_script/P3_extract_protein_feature_from_single_file.pl  $aa_ss_sa/${targetname}_ss_sa.fea $aa_ss_sa/");

				$aa_ss_sa_file = "$aa_ss_sa/$targetname.fea_aa_ss_sa";
			   if(-e $aa_ss_sa_file)
			   {
					print "!!Successfully generated $ren_aa_ss_sa\n\n";
					system("cp  $aa_ss_sa_file $ren_aa_ss_sa");
					system("cp $ren_aa_ss_sa $ALL_scores");
			   }else{
					print "!!Failed to generate $ren_aa_ss_sa\n\n";
			   }
			   
			   $ssfile = "$aa_ss_sa/${targetname}.fasta.ss";
			   $accfile = "$aa_ss_sa/${targetname}.fasta.acc";
			   if(-e $ssfile and -e $accfile)
			   {
					print "!!Successfully generated $accfile and $ssfile\n\n";
					system("cp  $ssfile $ren_ss");
					system("cp $ssfile $ALL_scores");
					system("cp  $accfile $ren_acc");
					system("cp $accfile $ALL_scores");
			   }else{
					print "!!Failed to generate $ren_ss and $ren_acc\n\n";
			   }
			}
			
			
			$tmp_ss_dir = "$TMP_output/temp_ss/";
			$tmp_sa_dir = "$TMP_output/temp_sa/";
			if(-d "$tmp_ss_dir")
			{
				`rm -rf $tmp_ss_dir/*`;
			}else{
				`mkdir $tmp_ss_dir`;
			}
			if(-d "$tmp_sa_dir")
			{
				`rm -rf $tmp_sa_dir/*`;
			}else{
				`mkdir $tmp_sa_dir`;
			}
			$cmd ="perl  $H_script/P1_extract_ss_from_dssp.pl $models_dssp $tmp_ss_dir $H_tool/dsspcmbi  $H_script/dssp2dataset.pl  $fasta_seq    $ren_models_dssp_ss $H_script/model2seq.pl";
			print $OUT "3.1. extract_ss_from_dssp\n   $cmd \n\n";
			print  "3.1. extract_ss_from_dssp\n\n";
			
			system("$cmd &>> $res");
		   
			$cmd ="perl  $H_script/P1_extract_sa_from_dssp.pl $models_dssp $tmp_sa_dir $H_tool/dsspcmbi  $H_script/dssp2dataset.pl  $fasta_seq  $ren_models_dssp_sa $H_script/model2seq.pl";
			print $OUT "3.2. extract_sa_from_dssp\n   $cmd \n\n";
			print  "3.2. extract_sa_from_dssp\n\n";
			
			system("$cmd &>> $res");
			
			$cmd ="perl $H_script/P1_generate_ss_match_feature.pl   $ren_models_dssp_ss   $ren_ss  $ss_match_dir";
			print $OUT "3.3. generate_ss_match_feature\n   $cmd \n\n";
			print  "3.3. generate_ss_match_feature\n\n";
			
			system("$cmd &>> $res");
			
			$cmd ="perl $H_script/P1_generate_sa_match_feature.pl   $models_dssp   $fasta_seq  $ren_models_dssp_sa  $ren_acc  $sa_match_dir";
			print $OUT "3.4. generate_sa_match_feature\n   $cmd \n\n";
			print  "3.4. generate_sa_match_feature\n\n";
			$OUT->close();
			system("$cmd &>> $res");
			
			`cp -ar $sa_match_dir $dir_output/ALL_scores/`;
			`cp -ar $ss_match_dir $dir_output/ALL_scores/`;
			
			#ToDo: Check if aa_ss_sa ran successfully			
			$aa_ss_sa_finishtime = time();
			$aa_ss_sa_diff_hrs = ($aa_ss_sa_finishtime - $aa_ss_sa_starttime)/3600;
			print "5. aa_ss_sa modeling finished within $aa_ss_sa_diff_hrs hrs!\n\n";
			if(-e "$LOG_output/aa_ss_sa.is_running")
			{
				system("mv $LOG_output/aa_ss_sa.is_running $LOG_output/aa_ss_sa.is_finished");
			}
			
			open(TMP,">>$LOG_output/aa_ss_sa.is_finished");
			print TMP "aa_ss_sa modeling finished within $aa_ss_sa_diff_hrs hrs!\n\n";
			close TMP;		
			exit 0;
		}elsif ($tool eq "DeepQA") ### 4. generating DeepQA score
		{
			#run DeepQA:
			$DeepQA_starttime = time();
			$ren_DeepQA_features=$TMP_output."/DeepQA";
			if(!(-d $ren_DeepQA_features))
			{
				`mkdir $ren_DeepQA_features`;
			}
			
			if(-e "$dir_output/ALL_scores/$targetname.deepqa_complete" and -d "$dir_output/ALL_scores/DeepQA_energy")
			{
			  print "4. $dir_output/ALL_scores/DeepQA_energy already generated! Pass\n\n";
			  #`cp -avr $dir_output/ALL_scores/DeepQA_energy  $ren_DeepQA_features`;
			}else{
			   $res = "$LOG_output/DeepQA.is_running";
			   
				my($score_deepqa) = $ren_DeepQA_features."/"."DeepQA_predictions.txt";
				
			   $cmd = "$H_tool/DeepQA/bin/DeepQA.sh  $fasta_seq    $models_DeepQA $ren_DeepQA_features";
			   $OUT = new FileHandle ">$res";
			   
			   
			   if(!(-e $score_deepqa))
			   {
				   print $OUT "4. generating DeepQA score\n   $cmd \n\n";
				   print  "4. generating DeepQA score\n\n";
				   $ren_return_val=system("$cmd &>> $res");
					if ($ren_return_val)
					{
						$DeepQA_finishtime = time();
						$DeepQA_diff_hrs = ($DeepQA_finishtime - $DeepQA_starttime)/3600;
						print "4. DeepQA modeling finished within $DeepQA_diff_hrs hrs!\n\n";
						
						system("mv $LOG_output/DeepQA.is_running $LOG_output/DeepQA.is_finished");
						open(TMP,">>$LOG_output/DeepQA.is_finished");
						print TMP "ERROR! DeepQA execution <$cmd> failed!\n";
						print TMP "DeepQA modeling finished within $DeepQA_diff_hrs hrs!\n\n";
						close TMP;				
						print "ERROR! DeepQA execution failed!";
						exit 0;
					}
				}
				$OUT->close();
			   if(-e $score_deepqa)
			   {
				   $cmd = "perl $H_script/P1_generate_DeepQA_energy_feature.pl  $ren_DeepQA_features  $fasta_seq  $ren_DeepQA_features";
				   
				   $OUT = new FileHandle ">$res";
				   print $OUT "4. generating DeepQA energy score\n   $cmd \n\n";
				   print  "4. generating DeepQA energy score\n\n";
				   $OUT->close();
				   system("$cmd &>> $res");
				   `touch $dir_output/ALL_scores/$targetname.deepqa_complete`;
				   `rm -rf $dir_output/ALL_scores/DeepQA_energy`;
				   `cp -ar $ren_DeepQA_features $dir_output/ALL_scores/DeepQA_energy`;
					
			   }
			   
			   
			}

			
			#ToDo: Check if DeepQA ran successfully			
			$DeepQA_finishtime = time();
			$DeepQA_diff_hrs = ($DeepQA_finishtime - $DeepQA_starttime)/3600;
			print "4. DeepQA modeling finished within $DeepQA_diff_hrs hrs!\n\n";
			if(-e "$LOG_output/DeepQA.is_running")
			{
				system("mv $LOG_output/DeepQA.is_running $LOG_output/DeepQA.is_finished");
			}
			
			open(TMP,">>$LOG_output/DeepQA.is_finished");
			print TMP "DeepQA modeling finished within $DeepQA_diff_hrs hrs!\n\n";
			close TMP;		
			exit 0;
		}elsif ($tool eq "rosetta") ### 16. generating rosetta score
		{
			#run rosetta:
			$rosetta_starttime = time();
			$ren_rosetta_features=$TMP_output."/rosetta";
			if(!(-d $ren_rosetta_features))
			{
				`mkdir $ren_rosetta_features`;
			}
			
			if(-e "$dir_output/ALL_scores/$targetname.rosetta_complete" and -d "$dir_output/ALL_scores/rosetta")
			{
			  print "5. $dir_output/ALL_scores/rosetta already generated! Pass\n\n";
			  #`cp -avr $dir_output/ALL_scores/rosetta_energy  $ren_rosetta_features`;
			}else{
			   $res = "$LOG_output/rosetta.is_running";
			   $cmd = "perl $H_script/P1_run_features_for_rosetta_energy.pl $models_rosetta  $H_script/run_ProQ3_model_local.sh $targetname   $ren_rosetta_features";
			   $OUT = new FileHandle ">$res";
			   print $OUT "5. generating rosetta score\n   $cmd \n\n";
			   print  "5. generating rosetta score\n\n";
			   $OUT->close();
			   $ren_return_val=system("$cmd &>> $res");
				if ($ren_return_val)
				{
					$rosetta_finishtime = time();
					$rosetta_diff_hrs = ($rosetta_finishtime - $rosetta_starttime)/3600;
					print "5. rosetta modeling finished within $rosetta_diff_hrs hrs!\n\n";
					
					system("mv $LOG_output/rosetta.is_running $LOG_output/rosetta.is_finished");
					open(TMP,">>$LOG_output/rosetta.is_finished");
					print TMP "ERROR! rosetta execution <$cmd> failed!\n";
					print TMP "rosetta modeling finished within $rosetta_diff_hrs hrs!\n\n";
					close TMP;				
					print "ERROR! rosetta execution failed!";
					exit 0;
				}
				
				
			   `touch $dir_output/ALL_scores/$targetname.rosetta_complete`;
			   `rm -rf $dir_output/ALL_scores/rosetta`;
			   `cp -ar $ren_rosetta_features $dir_output/ALL_scores/rosetta`;
				
			}

			
			#ToDo: Check if rosetta ran successfully			
			$rosetta_finishtime = time();
			$rosetta_diff_hrs = ($rosetta_finishtime - $rosetta_starttime)/3600;
			print "5. rosetta modeling finished within $rosetta_diff_hrs hrs!\n\n";
			if(-e "$LOG_output/rosetta.is_running")
			{
				system("mv $LOG_output/rosetta.is_running $LOG_output/rosetta.is_finished");
			}
			
			open(TMP,">>$LOG_output/rosetta.is_finished");
			print TMP "rosetta modeling finished within $rosetta_diff_hrs hrs!\n\n";
			close TMP;		
			exit 0;
		}
	}else{
		$thread_ids[$i] = $kidpid;
		print "The process id of the thread $i is $thread_ids[$i].\n\n";
	}


}
###############################################################################


#if ($i == @servers && $post_process == 0)
if ($i == $thread_num && $post_process == 0)
{
	print "The main process starts to wait for the base predictors to finish...\n";
	$post_process = 1;
	
	#rosetta,disorder,pssm,aa_ss_sa,DeepQA
	
	$rosetta_finish=1;
	$disorder_finish=1;
	$pssm_finish=1;
	$aa_ss_sa_finish=1;
	$DeepQA_finish=1;
	
	$rosetta_manuallystop=0;
	$disorder_manuallystop=0;
	$pssm_manuallystop=0;
	$aa_ss_sa_manuallystop=0;
	$DeepQA_manuallystop=0;
	
	$checktime = time();
	while(1)
	{
		if($rosetta_finish)
		{
			$checkfile = "$dir_output/ALL_scores/rosetta";
			if(-d $checkfile or $rosetta_manuallystop == 1)
			{
				if(-d $checkfile)
				{
					$rosetta_finish = 0;
					next;
				}
				if($rosetta_manuallystop == 0)
				{
					print "rosetta modeling finished!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "rosetta modeling finished! ($model_diff_hrs hr)\n";
					close STATUS;
				}else{
					print "rosetta modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "rosetta modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped! Ran ($model_diff_hrs hr)\n";
					close STATUS;				
				}
			}
				
		}
		
		if($disorder_finish)
		{
			$checkfile = "$dir_output/ALL_scores/$targetname.disorder_label";
			if(-e $checkfile or $disorder_manuallystop == 1)
			{
				if(-e $checkfile)
				{
					$disorder_finish = 0;
					next;
				}
				if($disorder_manuallystop == 0)
				{
					print "disorder modeling finished!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "disorder modeling finished! ($model_diff_hrs hr)\n";
					close STATUS;
				}else{
					print "disorder modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "disorder modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped! Ran ($model_diff_hrs hr)\n";
					close STATUS;				
				}
			}
				
		}
		
		if($pssm_finish)
		{
			$checkfile = "$dir_output/ALL_scores/$targetname.pssm";
			if(-e $checkfile or $pssm_manuallystop == 1)
			{
				if(-e $checkfile)
				{
					$pssm_finish = 0;
					next;
				}
				if($pssm_manuallystop == 0)
				{
					print "pssm modeling finished!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "pssm modeling finished! ($model_diff_hrs hr)\n";
					close STATUS;
				}else{
					print "pssm modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "pssm modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped! Ran ($model_diff_hrs hr)\n";
					close STATUS;				
				}
			}
				
		}


		if($aa_ss_sa_finish)
		{
			$checkfile = "$dir_output/ALL_scores/$targetname.fea_aa_ss_sa";
			if(-e $checkfile or $aa_ss_sa_manuallystop == 1)
			{
				if(-e $checkfile)
				{
					$aa_ss_sa_finish = 0;
					next;
				}
				if($aa_ss_sa_manuallystop == 0)
				{
					print "aa_ss_sa modeling finished!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "aa_ss_sa modeling finished! ($model_diff_hrs hr)\n";
					close STATUS;
				}else{
					print "aa_ss_sa modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "aa_ss_sa modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped! Ran ($model_diff_hrs hr)\n";
					close STATUS;				
				}
			}
				
		}
		if($DeepQA_finish)
		{
			$checkfile = "$dir_output/ALL_scores/DeepQA_energy";
			if(-d $checkfile or $DeepQA_manuallystop == 1)
			{
				if(-d $checkfile)
				{
					$DeepQA_finish = 0;
					next;
				}
				if($DeepQA_manuallystop == 0)
				{
					print "DeepQA modeling finished!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "DeepQA modeling finished! ($model_diff_hrs hr)\n";
					close STATUS;
				}else{
					print "DeepQA modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped!\n";
					$finishtime = time();
					$model_diff_hrs = ($finishtime - $checktime)/3600;
					open(STATUS,">>$dir_output/modelling_status.txt")|| die "Failed to write $dir_output/modelling_status.txt \n";
					print STATUS "DeepQA modeling took >$EXEC_LIMIT_HRS hr! Automatically stopped! Ran ($model_diff_hrs hr)\n";
					close STATUS;				
				}
			}
				
		}
		
		print "\n!!!!!!! Checking method status !!!!!! \n";
		print "!!!!!! rosetta: ".$rosetta_finish."\tdisorder:".$disorder_finish."\tpssm:".$pssm_finish."\taa_ss_sa:".$aa_ss_sa_finish."\tDeepQA:".$DeepQA_finish." !!!!!! \n\n";
		
		if($rosetta_finish== 0 and $disorder_finish== 0 and $pssm_finish== 0 and $aa_ss_sa_finish== 0 and $DeepQA_finish== 0)
		{
			last;
		}
		
		sleep(2);
		$currenttime = time();
	    $model_check_hrs = ($currenttime - $checktime);
		if($model_check_hrs > $EXEC_LIMIT_HRS)
		#if($model_check_hrs > 60*3)
		{
			for ($k = 0; $k < @tools; $k++)
			{
				$tool = $tools[$k];
				$kidpid = $thread_ids[$k];
				print "<$tool> has ran more than $EXEC_LIMIT_HRS hr, skip it and kill process $kidpid !\n";
				
				#dfire,OPUS,local_global,RF_SRS,RWplus,dope,modfoldclust2,pcons,pairwise,model_check2,QApro,model_eva,voronota,DeepQA,Proq3,Proq3D

				if($tool eq 'rosetta')
				{
					$rosetta_manuallystop = 1;
				}
				if($tool eq 'disorder')
				{
					$disorder_manuallystop = 1;
				}
				if($tool eq 'pssm')
				{
					$pssm_manuallystop = 1;
				}
				if($tool eq 'aa_ss_sa')
				{
					$aa_ss_sa_manuallystop = 1;
				}
				if($tool eq 'DeepQA')
				{
					$DeepQA_manuallystop = 1;
				}
				
				
			}
			
		}	
		sleep(600);
	}

		
}
		

sleep(10);
 
 my($score_log) = $dir_output."/"."score.log";
 chdir($dir_output);
 #system("rm -rf $TMP_output");
 system("rm -rf $models_rosetta");
 #system("rm -rf $models_folder");
 system("rm -rf $models_DeepQA");
 #system("rm -rf $dir_output/LOG");
 system("chmod -R 777 $dir_output/*");



END:
print " !!!!Feature generationg finished!\n";

$HumanQA_finishtime = time();
$HumanQA_diff_hrs = ($HumanQA_finishtime - $HumanQA_starttime)/3600;
print "\n!!!!Feature generationg finished within $HumanQA_diff_hrs hrs!\n\n";


 sub filter_score($$)
 { 
    my($dir_scores,$log)=@_;
    my($IN,$line,$OUT,$file,$path_score);
    my(@tem,@files);
    my(%hash);
    my($flag)=0;
    my($total,$key,$value);
    $OUT = new FileHandle ">$log";
    opendir(DIR,"$dir_scores");
    @files = readdir(DIR);    
    foreach $file (@files)
    {
      if($file eq "." || $file eq "..")
      {
         next;
      }
      $path_score = $dir_scores."/".$file;
      $total = 0;
      %hash = ();
      $IN = new FileHandle "$path_score";
      while(defined($line=<$IN>))
      {
         chomp($line);
         @tem = split(/\s+/,$line);
         if($tem[0] eq "REMARK" || $tem[0] eq "PFRMAT" ||$tem[0] eq "TARGET" ||$tem[0] eq "AUTHOR" ||$tem[0] eq "METHOD" ||$tem[0] eq "MODEL" || $tem[0] eq "QMODE" || $tem[0] eq "END")
         {
             next;
         }
         if(looks_like_number($tem[0]) || $tem[0] eq "X")
         {
             next;
         }
		 if(@tem<2)
		 {
			 next;
		 }
         $total++;
         if(exists $hash{$tem[1]})
         {
             $hash{$tem[1]}++;
         }         
         else
         {
             $hash{$tem[1]}=1;
         }
      }
      $IN->close();
      ###### now check whether this score is reliable #######
      $total/=2;
      foreach $key (keys %hash)
      {
         if($hash{$key} > $total)
         {
            $flag = 1;
            print $OUT "!!!!! WARNING, check the score $path_score, more than half models have the same score $key, removed.\n";
			system("rm $path_score");
         }
         
      }  
      if($total==0)
      {
         $flag = 1;
         print $OUT "!!!!! WARNING, check the score $path_score, no score is generated! Removed.\n";
         system("rm $path_score");
      }
    }
    if($flag == 0)
    {
       print $OUT "All scores are generated properly, not missing any one.\n";
    }
    print $OUT "\n**********************************\n";
    $OUT->close();

 }
 


