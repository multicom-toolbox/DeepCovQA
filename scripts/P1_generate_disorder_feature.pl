$num = @ARGV;

if($num != 3)
{
	die "The number of parameter is not correct!\n";
}


$model_disorder_file = $ARGV[0];#$model_disorder_dir/${idnew}.disorder
$fasta_file = $ARGV[1]; #/home/jh7x3/DeepCov_QA/data/casp_8_9_10_11_filtered.fasta
$outputfolder = $ARGV[2]; #/home/jh7x3/DeepCov_QA/results/Features/SS_match

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


%target_ss = ();
open(IN, "$outputfolder/tmp.txt") or print ("CANNOT open tmp.txt\n");
$file_num=0;
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

	
	
	
	open(IN1, "$model_disorder_file") || die ("CANNOT open $model_disorder_file\n");
	@content = <IN1>;
	close IN1;
	
	shift @content;
	$disorder_label= shift @content;
	$disorder_prob= shift @content;
	chomp $disorder_label;
	chomp $disorder_prob;
	
	
	
	if(length($disorder_label) != length($seq))
	{
		die "The disorder label not match the fasta sequence\nfasta: $seq\ndisor: $disorder_label\n";
	}
	$label_fea = "";
	for($k=0;$k<length($disorder_label);$k++)
	{
		$model_res = substr($disorder_label,$k,1);
		
		if($model_res ne 'D')
		{
			$label_fea .=" 0";  # use 0 as different
		}else{
			$label_fea .=" 1";  # use 1 as same
		}
	}
	if(substr($label_fea,0,1) eq ' ')
	{
		$label_fea = substr($label_fea,1);
	}
	@tmp2 = split(/\s/,$label_fea);
	if(@tmp2 != length($seq))
	{
		die "The feature length not match\nmodel: $seq\ntrues: $true_seq\nmatch: $label_fea\n";
	}
	$idx = 0;
	$feature="";
	foreach $l (@tmp2)
	{
		$idx++;
		chomp $l;
		$feature .=" $idx:".$l;
	}
	
	#print "write to $outputfolder/$idnew.disorder_label\n";
	open(OUT, ">$outputfolder/$idnew.disorder_label") || die ("CANNOT open $outputfolder/$idnew.disorder_label\n");
	print OUT ">$idnew\n0$feature\n";
	close OUT;
	
	
	# output prob 
	@tmp2 = split(/\s/,$disorder_prob);
	if(@tmp2 != length($seq))
	{
		die "The feature length not match\nmodel: $seq\ntrues: $true_seq\nmatch: $disorder_prob\n";
	}
	$idx = 0;
	$feature="";
	foreach $l (@tmp2)
	{
		$idx++;
		chomp $l;
		$feature .=" $idx:".$l;
	}
	open(OUT, ">$outputfolder/$idnew.disorder_prob") || die ("CANNOT open $outputfolder/$idnew.disorder_prob\n");
	print OUT ">$idnew\n0$feature\n";
	close OUT;
	

}
close IN;




