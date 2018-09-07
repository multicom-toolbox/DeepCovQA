use Carp;
our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;

$num = @ARGV;

if($num != 2)
{
	die "The number of parameter is not correct!\n";
}


$local_qa = $ARGV[0];
$local_qa_out = $ARGV[1];


open(OUT,">$local_qa_out") || die "Failed to find $local_qa_out\n";
open(IN,"$local_qa") || die "Failed to find $local_qa\n";
@content = <IN>;
close IN;

%score_hash = ();
%score_local_hash = ();
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
	
	$score_hash{$model}=$global;
	$score_local_hash{$model}=$line;
	
}

foreach my $model (sort { $score_hash{$b} <=> $score_hash{$a} } keys %score_hash) {
    print OUT $score_local_hash{$model}."\n";
}
close OUT;
