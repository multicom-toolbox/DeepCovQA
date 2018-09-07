#####################################################
#generate features for SVM training.
#
#Zheng Wang, March 3rd, 2011.
#Revised by Renzhi Cao, 11/22/2013
#####################################################
$num = @ARGV;

if($num != 7)
{
	die "The number of parameters is not correct!\n";
}

my $model_dir = $ARGV[0];	#/storage/homes/zwyw6/abs_local_quality/casp8/temp/
my $interm_dir = $ARGV[1];	#/storage/homes/zwyw6/abs_local_quality/casp8/interm/
my $dssp_exe = $ARGV[2];	#/storage/homes/zwyw6/abs_local_quality/scripts/dsspcmbi
my $dssp_parser_exe = $ARGV[3];	#/storage/homes/zwyw6/abs_local_quality/scripts/dssp2dataset.pl
my $seq_file = $ARGV[4];	#
my $outputfile = $ARGV[5];	#the output file containing the features
my $model2seq_exe = $ARGV[6];

########Open the output file############

if(!(-d $interm_dir))
{
	`mkdir $interm_dir`;
}
############Amino acid orders######################
my @aa_table = ("A", "R", "N", "D", "C", "E", "Q", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V");


##########Generate features#####################
opendir(MODEL, "$model_dir");
my @models = readdir(MODEL);
closedir(MODEL);
###############Get the reference model##########
########only the model exactly the same#########
########as the reference model will be used#####
my $ref_seq;
open(IN, "<$seq_file");
while(<IN>){
	my $line = $_;
	if($line =~ />/){
		next;
	}
	$line =~ s/\n//;
	$line =~ s/\s+$//;
	$ref_seq = $line;
}
close(IN);
#print "Ref seq: $ref_seq\n";
my $ref_seq_length = length($ref_seq);
open(OUT, ">$outputfile");
#################Evaluate each model############
foreach my $model (@models){
	if($model eq '.' || $model eq '..'){
		next;
	}
	if($model ne "MULTICOM-REFINE_TS2"){
		#next;
	}
	print "\t\t$model\n";
	
	#############Parse the sequence out from the model################
	#print "perl $model2seq_exe $model_dir/$model $interm_dir/$model.fasta\n";
	`perl $model2seq_exe $model_dir/$model $interm_dir/$model.fasta`;
	open(IN, "<$interm_dir/$model.fasta");
	my $seq;
	while(<IN>){
		my $line = $_;
		if($line =~ />/){
				next;
		}
		$line =~ s/\n//;
		$seq = $line;
	}
	close(IN);
	################If the sequence is not the same as the ref seq#######
	###############next##################################################
	#print "$ref_seq\n$seq\n\n";
	if($seq ne $ref_seq){
		print "next, partial model\n$seq\n$ref_seq\n";
		next;
	}
	#print "$model\n";
	###############Run dssp on the model to generate#####################
	###########other half of features, parse result######################
	#print "$dssp_exe $model_dir/$target/$model $interm_dir/$target/$model.dsspout\n";
	`$dssp_exe $model_dir/$model $interm_dir/$model.dsspout >  /dev/null 2>&1`;
	#print "$dssp_parser_exe $interm_dir/$target/$model.dsspout $interm_dir/$target/$model.dsspout.parsed\n";
	`$dssp_parser_exe $interm_dir/$model.dsspout $interm_dir/$model.dsspout.parsed`;
	my $ss_model;
	my $line_counter_dssp = 0;
	open(IN, "<$interm_dir/$model.dsspout.parsed");
	while(<IN>)
	{
		my $line = $_;
		$line =~ s/\n//;
		
		if($line_counter_dssp == 2){
			@aa_array = split(/\s+/, $line); # add by jie in order dssp miss some residues in pdb
		}
		
		if($line_counter_dssp == 4){
			my @items = split(/\s+/, $line);
			$idx_dssp=0;
			$idx_model=0;
			$match_aa=0;
			foreach my $item (@items){
				while(1)
				{
					$dssp_aa = $aa_array[$idx_dssp]; # dssp sequence will be equal or less than model sequence
					$model_aa = substr($seq,$idx_model,1);
					if($dssp_aa ne $model_aa) # means dssp miss this residue, mark  sa in residue as '-'
					{
						$ss_model .= "C"; 
						print "!!!Warning: aa $model_aa in model on index $idx_model is missing in dssp\n\n ";
						$idx_model++;
						
					}else{
						$match_aa=1;
					}
					 
					if($match_aa==1)
					{
						$match_aa=0;
						last;
					}
				}
				$idx_dssp++;
				$idx_model++;
				if($item eq 'G' || $item eq 'H' || $item eq 'I'){
					$ss_model .= "H";
					next;
				}
				#if($item eq 'E' ){ # previous version has problem
				if($item eq 'E'  || $ss_str eq 'B'){
					$ss_model .= "E";
					next;
				}
				$ss_model .= "C";
			}
			
			if(length($ss_model) != length($ref_seq)) # means the last residues are missing 
			{
				for($m=0;$m<length($ref_seq)-length($ss_model);$m++)
				{
					$model_aa =substr($seq,$idx_model,1);
					print "!!!Warning: aa $model_aa in model on index $idx_model is missing in dssp\n\n ";
					$ss_model .= "C";
					$idx_model++;
				}
			}
		}
		
		$line_counter_dssp++;
	}
	
	close(IN);		
	if(length($ss_model)   != length($ref_seq))
	{
		die "The length not match for $model and native $seq_file\nmodel : $ss_model\nnative: $ref_seq\n\n";
	}
	print OUT ">$model\t$ss_model\n";
	
	#last;

}
close(OUT);
