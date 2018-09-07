#!/usr/bin/perl -w
 use FileHandle; # use FileHandles instead of open(),close()
 use Cwd;
 use Cwd 'abs_path';

######################## !!! customize settings here !!! ############################
#																					#
# Set installation directory of DeepCovQA to your unzipped DeepCovQA directory            #
     
 $install_dir = "/your_path/DeepCovQA";
######################## !!! End of customize settings !!! ##########################

if($install_dir eq "/your_path/DeepCovQA")
{# user forgets to set the default path of DeepCovQA, try to solve this problem
    $install_dir = getcwd;
    $install_dir=abs_path($install_dir);
}


if(!-s $install_dir)
{
	die "The DeepCovQA directory ($install_dir) is not existing, please revise the customize settings part inside the configure.pl, set the path as  your unzipped DeepCovQA directory\n";
}
if ( substr($install_dir, length($install_dir) - 1, 1) ne "/" )
{
        $install_dir .= "/";
}

print "checking whether the configuration file run in the installation folder ...";
$cur_dir = `pwd`;
chomp $cur_dir;
$configure_file = "$cur_dir/configure.pl";
if (! -f $configure_file || $install_dir ne "$cur_dir/")
{
        die "\nPlease check the installation directory setting and run the configure program in the installation directory of DeepCovQA.\n";
}
print " OK!\n";


################Don't Change the code below##############

if (! -d $install_dir)
{
	die "can't find installation directory.\n";
}
if ( substr($install_dir, length($install_dir) - 1, 1) ne "/" )
{
	$install_dir .= "/"; 
}


if (prompt_yn("DeepCovQA will be installed into <$install_dir> ")){

}else{
	die "The installation is cancelled!\n";
}
print "Start install DeepCovQA into <$install_dir>\n";


$files		="scripts/run_DeepCovQA.pl,scripts/P1_feature_generation_parallel.pl,scripts/run_ProQ3_model_local.sh,tools/proq3/paths.sh,tools/proq3/bin/run_all_external.pl,tools/proq3/apps/psipred25/runpsipred,tools/predisorder1.1/configure.pl";

@updatelist		=split(/,/,$files);

foreach my $file (@updatelist) {
	$file2update=$install_dir.$file;
	
	$check_log ='GLOBAL_PATH=';
	open(IN,$file2update) || die "Failed to open file $file2update\n";
	open(OUT,">$file2update.tmp") || die "Failed to open file $file2update.tmp\n";
	while(<IN>)
	{
		$line = $_;
		chomp $line;

		if(index($line,$check_log)>=0)
		{
			print $file2update."\n";
			print "Current ".$line."\n";
			print "Change to ".substr($line,0,index($line, '=')+1)." \'".$install_dir."\';\n\n\n";
			print OUT substr($line,0,index($line, '=')+1)."\'".$install_dir."\';\n";
		}else{
			print OUT $line."\n";
		}
	}
	close IN;
	close OUT;
	system("mv $file2update.tmp $file2update");
	system("chmod 755  $file2update");


}

print "#########  Setting up DeepQA \n";
$ssprodir = $install_dir.'/tools/DeepQA/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for sspro doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "\n#########  Setting up predisorder1.1 \n";
$ssprodir = $install_dir.'/tools/predisorder1.1/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for sspro doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}



print "\n#########  Setting up proq3 \n";
symlink("$install_dir/tools/DeepQA/tools/sspro4/","$install_dir/tools/proq3/apps/sspro4");
symlink("$install_dir/tools/blast-2.2.26/","$install_dir/tools/proq3/apps/blast-2.2.26");
symlink("$install_dir/tools/blast-2.2.26/bin/","$install_dir/tools/proq3/apps/sspro4/blast2.2.8");



sub prompt_yn {
  my ($query) = @_;
  my $answer = prompt("$query (Y/N): ");
  return lc($answer) eq 'y';
}
sub prompt {
  my ($query) = @_; # take a prompt string as argument
  local $| = 1; # activate autoflush to immediately show the prompt
  print $query;
  chomp(my $answer = <STDIN>);
  return $answer;
}
