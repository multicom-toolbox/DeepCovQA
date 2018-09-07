$num = @ARGV;

if($num != 3)
{
	die "The number of parameter is not correct!\n";
}


$model_dssp_file = $ARGV[0];#$model_dssp_file = "$model_dssp_dir/${target}_models_dssp_ss.txt";
$true_ss_file = $ARGV[1]; #/home/jh7x3/DeepCov_QA/results/Features/casp_8_9_10_11_filtered.fasta.ss
$outputfolder = $ARGV[2]; #/home/jh7x3/DeepCov_QA/results/Features/SS_match

open(IN, "$true_ss_file") or print ("CANNOT open $true_ss_file\n");
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
while(<IN>)
{
	$line=$_;
	chomp $line;
	@tmp = split(/\t/,$line);
	$id = $tmp[0];
	$seq = $tmp[1];
	if(substr($id,0,1) eq '>' )
	{
		$id = substr($id,1);
	}
	$target_ss{$id} = $seq;
}
close IN;

$file_num = 0;
foreach $target (sort keys %target_ss)
{
	$true_seq = $target_ss{$target};
	
	open(IN, "$model_dssp_file") or print ("CANNOT open $model_dssp_file\n");
	open(OUT, ">$outputfolder/$target.ss_match") or print ("CANNOT open $outputfolder/$target.ss_match\n");
	
	while(<IN>)
	{
		$line=$_;
		chomp $line;
		@tmp = split(/\t/,$line);
		$id = $tmp[0];
		$seq = $tmp[1];
		if(substr($id,0,1) eq '>' )
		{
			$id = substr($id,1);
		}
		if(length($seq) != length($true_seq))
		{
			die "The ss length of $id in target $target not match\nmodel: $seq\ntrues: $true_seq\n";
		}
		
		$match = "";
		$acc=0;
		for($k=0;$k<length($seq);$k++)
		{
			$model_res = substr($seq,$k,1);
			$true_res = substr($true_seq,$k,1);
			
			if($model_res ne $true_res)
			{
				$match .=" -1";  # use -1 as different
			}else{
				$match .=" 1";  # use 1 as same
				$acc++;
			}
		}
		if(substr($match,0,1) eq ' ')
		{
			$match = substr($match,1);
		}
		@tmp2 = split(/\s/,$match);
		if(@tmp2 != length($seq))
		{
			die "The feature length not match\nmodel: $seq\ntrues: $true_seq\nmatch: $match\n";
		}
		$idx = 0;
		$feature="";
		foreach $l (@tmp2)
		{
			$idx++;
			chomp $l;
			$feature .=" $idx:".$l;
		}
		$acc = sprintf("%.3f",$acc*1.000/length($seq));
		#print "Generating $outputfolder/${target}_${id}.ss_match\n\n";
		open(OUT1, ">$outputfolder/${target}_${id}.ss_match") or print ("CANNOT open $outputfolder/${target}_${id}.ss_match\n");
		print OUT1 ">$id\n$acc$feature\n";
		print OUT ">$id\n$acc$feature\n";
		close OUT1;
		
	}
	close OUT;
	close IN;
}




