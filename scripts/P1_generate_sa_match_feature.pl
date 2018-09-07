use Carp;
our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;


$num = @ARGV;

if($num != 5)
{
	die "The number of parameter is not correct!\n";
}


$model_dir = $ARGV[0];#/home/jh7x3/DeepCov_QA/data/casp11_scwrl_all_predictions_final
$target_fasta_file = $ARGV[1];#/home/jh7x3/DeepCov_QA/data/casp11_original_seq
$model_dssp_file = $ARGV[2];#$model_dssp_file = "$model_dssp_dir/${target}_models_dssp_sa.txt";
$true_sa_file = $ARGV[3]; #/home/jh7x3/DeepCov_QA/results/Features/SCRATCH/casp_8_9_10_11_12_original.fasta.sa
$outputfolder = $ARGV[4]; #/home/jh7x3/DeepCov_QA/results/Features/SA_match


=pod

idea:

1. read the model
2. get the aa based on index of CA, check if same as in fasta file, if yes, get secondary structure in model and sequence
3. compare if ss same or not, yes mark 1, otherwise -1


=cut 

open(IN, "$true_sa_file") or print ("CANNOT open $true_sa_file\n");
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


%target_sa = ();
open(IN, "$outputfolder/tmp.txt") or print ("CANNOT open tmp.txt\n");
while(<IN>)
{
	$line=$_;
	chomp $line;
	@tmp = split(/\t/,$line);
	
	$id = $tmp[0];
	$seq = $tmp[1];
	
	@tmp2 = split(/\s/,$id);#>T0851 CalS8, Micromonospora echinospora, 456 residues 
	$idnew = $tmp2[0];
	if(substr($idnew,0,1) eq '>' ) 
	{
		$idnew = substr($idnew,1);
	}
	$target_sa{$idnew} = $seq;
}
close IN;

$file_num = 0;
foreach $target (sort keys %target_sa)
{
	
	print "Processing $target\n";
	open(IN, "$target_fasta_file") or print ("CANNOT open $target_fasta_file\n"); 
	@content = <IN>;
	close IN;
	shift @content;
	$orig_seq = shift @content;
	chomp $orig_seq;
	
	#### get the target's ss from original sequence
	$predicted_sa = $target_sa{$target}; # the original sequence
	
	if(length($predicted_sa) != length($orig_seq)) # 
	{
		die "The origin ss length and fasta sequence of target $target not match\sa: $predicted_sa\ntrues: $orig_seq\n";
	}
	
	
	
	#### get the dssp file based on models
	
	open(IN, "$model_dssp_file") or print ("CANNOT open $model_dssp_file\n"); #>FALCON_MANUAL_TS3      CCCCCCCCCHHHHHH
	open(OUT, ">$outputfolder/$target.sa_match") or print ("CANNOT open $outputfolder/$target.sa_match\n");
	
	while(<IN>)
	{
		$line=$_;
		chomp $line;
		@tmp = split(/\t/,$line); #>FALCON_MANUAL_TS3      CCCCCCCCCHHHHHH  ###
		$id = $tmp[0];
		$dssp_seq = $tmp[1];
		if(substr($id,0,1) eq '>' )
		{
			$id = substr($id,1);
		}
		
		### get the model's pdb
		$modelpdb = "$model_dir/$id";
		if(!(-e $modelpdb))
		{
			die "Couldn't find $modelpdb\n";
		}
		
		
		### get the sequence from model
		my $model_seq = "";
		open(INPUTPDB, "$modelpdb") || die "ERROR! Could not open $modelpdb\n";
		while(<INPUTPDB>){
			next if $_ !~ m/^ATOM/;
			next unless (parse_pdb_row($_,"aname") eq "CA");
			confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $modelpdb! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
			my $res = $AA3TO1{parse_pdb_row($_,"rname")};
			$model_seq .= $res;
		}
		close INPUTPDB;		
		
		
		if(length($dssp_seq) != length($model_seq)) # 
		{
			die "The dssp ss length and model sequence of $id in target $target not match\nmodel: $dssp_seq\ntrues: $model_seq\n";
		}
		
		
		##### read through the model and get feature match
		open(INPUTPDB, "$modelpdb") || die "ERROR! Could not open $modelpdb\n";
		$r_index=0;
		$match = "";
		$acc=0;
		while(<INPUTPDB>){
			next if $_ !~ m/^ATOM/;
			next unless (parse_pdb_row($_,"aname") eq "CA");
			confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $modelpdb! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
			my $res = $AA3TO1{parse_pdb_row($_,"rname")};
			$r_index++;
			my $r_num =parse_pdb_row($_,"rnum");
			
			$curr_aa_in_modelseq = substr($model_seq,$r_index-1,1);
			$curr_sa_in_modelseq = substr($dssp_seq,$r_index-1,1);
			
			$curr_aa_in_originseq = substr($orig_seq,$r_num-1,1);
			$curr_sa_in_originseq = substr($predicted_sa,$r_num-1,1);
			
			if($curr_aa_in_modelseq ne $curr_aa_in_originseq)
			{
				die "Be careful, the residue not match at location $r_num\nmodel:$curr_aa_in_modelseq\nseq:  $curr_aa_in_originseq\n";
			}
			
			# now can compare if ss match or not 
			if($curr_sa_in_originseq ne $curr_sa_in_modelseq)
			{
				$match .=" -1";  # use -1 as different
			}else{
				$match .=" 1";  # use 1 as same
				$acc++;
			}
		}
		close INPUTPDB;	
		
		if(substr($match,0,1) eq ' ')
		{
			$match = substr($match,1);
		}
		
		
		@tmp2 = split(/\s/,$match);
		if(@tmp2 != length($orig_seq))  ## the length should match the original sequence length
		{
			die "The feature length not match\nmodel: $model_seq\ntrues: $orig_seq\nmatch: $match\n";
		}
		$idx = 0;
		$feature="";
		foreach $l (@tmp2)
		{
			$idx++;
			chomp $l;
			$feature .=" $idx:".$l;
		}
		$acc = sprintf("%.3f",$acc*1.000/length($model_seq));
		open(OUT1, ">$outputfolder/${target}_${id}.sa_match") or print ("CANNOT open $outputfolder/${target}_${id}.sa_match\n");
		print OUT1 ">$id\n$acc$feature\n";
		print OUT ">$id\n$acc$feature\n";
		close OUT1;
		
	}
	close OUT;
	close IN;
}




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
