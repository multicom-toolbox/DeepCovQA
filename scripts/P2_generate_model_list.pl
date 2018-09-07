 #! /usr/bin/perl -w
 if(@ARGV != 4)
 {
   die "The number of parameter is not correct!\n";
 }
 
 $targetname = $ARGV[0];
 $seqfile = $ARGV[1];
 $dir_models = $ARGV[2];
 $outputfile = $ARGV[3];
 
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
 
 $len = length($sequence);
 open(OUT, ">$outputfile") || die "Failed to open file $outputfile\n\n";# test\tT0859\tMULTICOM_TS1
 opendir(DIR,$dir_models) || die "Failed to open directory $dir_models\n\n";
 @files = readdir(DIR);
 closedir(DIR);
 
 foreach $file (@files)
 {
	chomp $file;
	if($file eq '.' or $file eq '..')
	{
		next;
	}
	
	print OUT "test\t$targetname\t$file\t$len\t$len\n";
	
 }
 
 close OUT;
 