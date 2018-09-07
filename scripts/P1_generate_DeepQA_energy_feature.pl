use Carp;
our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;



$num = @ARGV;

if($num != 3)
{
	die "The number of parameter is not correct!\n";
}


$DeepQA_dir = $ARGV[0];#
$fasta_file = $ARGV[1]; #
$outputfolder = $ARGV[2]; #

=pod
1. get local quality file, extract sequence, and local score
2. check if the extracted sequence should match native seq, if not, which means the residue lost in LGA, ignore 
3. read from original fasta sequence, if not in native structure, local score marked as 10000, need filter when training


=cut


open(IN, "$fasta_file") or print ("CANNOT open $fasta_file\n");
open(TMP, ">$outputfolder/tmp.txt") or print ("CANNOT open tmp.txt\n"); 

while(<IN>)
{
	$line=$_;
	chomp $line;
	if(substr($line,0,1) eq '>')
	{
		print TMP $line."\t";
	}else{
		print TMP $line."\n";
	}
}
close IN;
close TMP;


open(IN, "$outputfolder/tmp.txt") or print ("CANNOT open tmp.txt\n");
$file_num=0;
while(<IN>)
{
	$line=$_;
	chomp $line;
	@tmp = split(/\t/,$line);
	
	$id = $tmp[0];
	#$origin_seq = $tmp[1];
	
	@tmp2 = split(/\s/,$id);#>T0851 CalS8, Micromonospora echinospora, 456 residues 
	$idnew = $tmp2[0];
	if(substr($idnew,0,1) eq '>' )
	{
		$idnew = substr($idnew,1);
	}
	
	$DeepQAfile = "$DeepQA_dir/DeepQA_predictions.txt";
	$DeepQA1_feature0_surface = "$DeepQA_dir/f/feature_0_surface/DeepQA.feature0_surface";
	$DeepQA2_feature2_dope = "$DeepQA_dir/f/feature_1_dope/DeepQA.feature2_dope";
	$DeepQA3_feature3_GOAP = "$DeepQA_dir/f/feature_2_GOAP/DeepQA.feature3_GOAP_final";
	$DeepQA4_feature5_RWplus = "$DeepQA_dir/f/feature_4_RWplus/DeepQA.feature5_RWplus_final";
	$DeepQA5_feature6_ModEva = "$DeepQA_dir/f/feature_5_ModEva/DeepQA.feature6_ModEva_final";
	$DeepQA6_Qprob_score = "$DeepQA_dir/f/f_8_Qp/DeepQA.Qprob_score";
	
	
	if(!(-e $DeepQAfile) or  !(-e $DeepQA1_feature0_surface) or  !(-e $DeepQA2_feature2_dope) or  !(-e $DeepQA3_feature3_GOAP) or  !(-e $DeepQA4_feature5_RWplus) or  !(-e $DeepQA5_feature6_ModEva) or  !(-e $DeepQA6_Qprob_score))
	{
		print  "The feature file of target $idnew not complete! please check!\n\n";
		next;
	}else{
		$file_num++;
		print "$file_num: Processing $DeepQAfile\n";
	}
	
	### start read features , DeepQA as target score
	open(IN1, "$DeepQAfile") || die ("CANNOT open $DeepQAfile\n");
	@content = <IN1>;
	close IN1;
	foreach $l (@content)
	{
		chomp $l;
		@tmp = split(/\t/,$l);
		$mod = $tmp[0];
		$score = $tmp[1];
		
		$modnew = "${idnew}_$mod";
		$all_energy_feature{$modnew} = $score;
		
	}
	
	
	### read DeepQA1_feature0_surface
	
	open(IN1, "$DeepQA1_feature0_surface") || die ("CANNOT open $DeepQA1_feature0_surface\n");
	@content = <IN1>;
	close IN1;
	foreach $l (@content)
	{
		chomp $l;
		@tmp = split(/\t/,$l);
		$mod = $tmp[0];
		$score = $tmp[1];
		
		$modnew = "${idnew}_$mod";
		if(!exists($all_energy_feature{$modnew}))
		{
			print "Warning: $modnew has feature in $DeepQA1_feature0_surface\n";
			$all_energy_feature{$modnew} .= " 1:0";
		}else{
			$all_energy_feature{$modnew} .= " 1:".$score;
		}
	}
	
	### read DeepQA2_feature2_dope
	
	open(IN1, "$DeepQA2_feature2_dope") || die ("CANNOT open $DeepQA2_feature2_dope\n");
	@content = <IN1>;
	close IN1;
	foreach $l (@content)
	{
		chomp $l;
		@tmp = split(/\t/,$l);
		$mod = $tmp[0];
		$score = $tmp[1];
		
		$modnew = "${idnew}_$mod";
		if(!exists($all_energy_feature{$modnew}))
		{
			print "Warning: $modnew has feature in $DeepQA2_feature2_dope\n";
			$all_energy_feature{$modnew} .= " 2:0";
		}else{
			$all_energy_feature{$modnew} .= " 2:".$score;
		}
	}

	### read DeepQA3_feature3_GOAP
	
	open(IN1, "$DeepQA3_feature3_GOAP") || die ("CANNOT open $DeepQA3_feature3_GOAP\n");
	@content = <IN1>;
	close IN1;
	foreach $l (@content)
	{
		chomp $l;
		@tmp = split(/\t/,$l);
		$mod = $tmp[0];
		$score = $tmp[1];
		
		$modnew = "${idnew}_$mod";
		if(!exists($all_energy_feature{$modnew}))
		{
			print "Warning: $modnew has feature in $DeepQA3_feature3_GOAP\n";
			$all_energy_feature{$modnew} .= " 3:0";
		}else{
			$all_energy_feature{$modnew} .= " 3:".$score;
		}
	}
	### read DeepQA4_feature5_RWplus
	
	open(IN1, "$DeepQA4_feature5_RWplus") || die ("CANNOT open $DeepQA4_feature5_RWplus\n");
	@content = <IN1>;
	close IN1;
	foreach $l (@content)
	{
		chomp $l;
		@tmp = split(/\t/,$l);
		$mod = $tmp[0];
		$score = $tmp[1];
		$modnew = "${idnew}_$mod";
		if(!exists($all_energy_feature{$modnew}))
		{
			print "Warning: $modnew has feature in $DeepQA4_feature5_RWplus\n";
			$all_energy_feature{$modnew} .= " 4:0";
		}else{
			$all_energy_feature{$modnew} .= " 4:".$score;
		}
	}
	### read DeepQA5_feature6_ModEva
	
	open(IN1, "$DeepQA5_feature6_ModEva") || die ("CANNOT open $DeepQA5_feature6_ModEva\n");
	@content = <IN1>;
	close IN1;
	### double check the feature, sometime modeleva will fail
	@tmp_check = ();
	foreach $l (@content)
	{
		chomp $l;
		@tmp = split(/\t/,$l);
		$mod = $tmp[0];
		$score = $tmp[1];
		
		$modnew = "${idnew}_$mod";
		$tmp_check{$modnew} = $score;
	}
	foreach $modnew (keys %all_energy_feature)
	{
		if(!(exists($tmp_check{$modnew})))
		{
			print "Failed to generate mdoeleva score in deepqa for model $modnew, setting to 0\n\n";
			$tmp_check{$modnew} = 0;
		}
	}
	
	foreach $modnew (sort keys %tmp_check)
	{
		#chomp $l;
		#@tmp = split(/\t/,$l);
		#$mod = $tmp[0];
		$score = $tmp_check{$modnew};
		
		#$modnew = "${idnew}_$mod";
		if(!exists($all_energy_feature{$modnew}))
		{
			print "Warning: $modnew has feature in $DeepQA5_feature6_ModEva\n";
			$all_energy_feature{$modnew} .= " 5:0";
		}else{
			$all_energy_feature{$modnew} .= " 5:".$score;
		}
	}
	
	
	### read DeepQA6_Qprob_score
	
	open(IN1, "$DeepQA6_Qprob_score") || die ("CANNOT open $DeepQA6_Qprob_score\n");
	@content = <IN1>;
	close IN1;
	foreach $l (@content)
	{
		chomp $l;
		@tmp = split(/\t/,$l);
		$mod = $tmp[0];
		$score = $tmp[1];
		
		$modnew = "${idnew}_$mod";
		if(!exists($all_energy_feature{$modnew}))
		{
			print "Warning: $modnew has feature in $DeepQA6_Qprob_score\n";
			$all_energy_feature{$modnew} .= " 6:0";
		}else{
			$all_energy_feature{$modnew} .= " 6:".$score;
		}
	}
	
	
	foreach $mod (sort keys %all_energy_feature)
	{
		open(OUT,">$outputfolder/$mod.DeepQAenergy") || die "Failed to open file $outputfolder/$mod.DeepQAenergy\n";
		print $all_energy_feature{$mod}."\n";
		print OUT $all_energy_feature{$mod}."\n";
		close OUT;
	}
}
close IN;

