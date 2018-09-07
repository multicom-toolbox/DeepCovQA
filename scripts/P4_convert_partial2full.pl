use Carp;
our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;

$num = @ARGV;

if($num != 4)
{
	die "The number of parameter is not correct!\n";
}


$local_qa = $ARGV[0];
$model_path = $ARGV[1];
$original_fasta = $ARGV[2];
$local_qa_out = $ARGV[3];


open(OUT,">$local_qa_out") || die "Failed to find $local_qa_out\n";
open(IN,"$original_fasta") || die "Failed to find $original_fasta\n";
@content = <IN>;
close IN;
$targetid = shift @content;
$full_seq = shift @content;
chomp $targetid;
chomp $full_seq;
if(substr($targetid,0,1) eq '>')
{
	$targetid = substr($targetid,1);
}


##### found the position of residue in the domain seq  regarding to full length



open(IN,"$local_qa") || die "Failed to find $local_qa\n";
@content = <IN>;
close IN;

foreach $line (@content)
{
	chomp $line;
	if(index($line,'DeepCov')>=0)
	{
		next;
	}
	
	@tmp = split (/\s/,$line);
	$model = shift @tmp;
	$global = shift @tmp;
	
	$modelname = substr($model,length($targetid)+1);
	
	$server_model = "$model_path/$modelname";
	open(INPUTPDB, "$server_model") || die "ERROR! Could not open $server_model\n";
	%domain_seq2pos_hash=();
	%domain_ind2pos_hash=();
	$dom_index=0;
	while(<INPUTPDB>){
		next if $_ !~ m/^ATOM/;
		next unless (parse_pdb_row($_,"aname") eq "CA");
		die "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $server_model! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
		my $res = $AA3TO1{parse_pdb_row($_,"rname")};
		my $resnum = parse_pdb_row($_,"rnum");
		if(substr($full_seq,$resnum-1,1) ne $res)
		{
			die "The residue ($resnum: $res) not match full sequeunce (".substr($full_seq,$resnum-1,1).")\n\n";
		}
		$domain_seq2pos_hash{$resnum}=1;
		$dom_index++;
		$domain_ind2pos_hash{$dom_index}=$resnum;
		

	}
	close INPUTPDB;
	
	if(@tmp != $dom_index)
	{
		die "wrong local qa for model $modelname\n\n";
	}
	
	$ratio = sprintf("%.5f",$dom_index/length($full_seq));
	$global_new = $ratio * $global;
	
	## update the local score 
	for($i=1;$i<=$dom_index;$i++)
	{
		$domain_seq2pos_hash{$domain_ind2pos_hash{$i}} = $tmp[$i-1];
	}
	
	print "Processing $modelname\n";
	print OUT "$modelname $global_new";
	for($i=1;$i<=length($full_seq);$i++)
	{
		if(!exists($domain_seq2pos_hash{$i}))
		{
			print "The residue $i:".substr($full_seq,$i-1,1)." is missing\n\n";
			print OUT ' X';
		}else{
			print OUT ' '.$domain_seq2pos_hash{$i};
		}
	}
	print OUT "\n";
	
	
}
close OUT;

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