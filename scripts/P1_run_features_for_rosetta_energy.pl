#! /usr/bin/perl -w
=pod
You may freely copy and distribute this document so long as the copyright is left intact. You may freely copy and post unaltered versions of this document in HTML and Postscript formats on a web site or ftp site. Lastly, if you do something injurious or stupid
because of this document, I don't want to know about it. Unless it's amusing.
=cut
 require 5.003; # need this version of Perl or newer
 use English; # use English names, not cryptic ones
 use FileHandle; # use FileHandles instead of open(),close()
 use Carp; # get standard error / warning messages
 use strict; # force disciplined use of variables
 if (@ARGV != 4)
    { # @ARGV used in scalar context = number of args
	  print("This script add chain to all server prediction pdbs, with each subfold for one target.    One input, another script add_chainID_to_pdb.pl, and one output\n");
	  print "\nFor example:\n";
	  print "perl $0 ../data_downloaded_from_CASP/data_server_prediction/casp8_server_prediction add_chainID_to_pdb.pl ../data_downloaded_from_CASP/data_server_prediction/chain_added_casp8_server_prediction\n";

	  exit(0);
	}
 
 my($target_path)=$ARGV[0]; #T0859
 my($tool)=$ARGV[1]; #
 my($target_id)=$ARGV[2];
 my($path_out)=$ARGV[3];

 -s $target_path || die "Cannot open input folder\n";
  -s $tool || die "Cannot open input $tool\n";
-s $path_out || system("mkdir -p $path_out");
 my($return,$file,$target,$path_in,$path_out2);
 my(@files,@targets);
 my ($prepare_file_ss,$prepare_file_acc,$prepare_file_fasta,$prepare_file_mtx,$prepare_file_psi);
 open(LOG,">$path_out/run.log") || die "Failed to open $path_out/run.log\n";

 
 opendir(DIR,"$target_path");
 @targets = readdir(DIR);
 closedir(DIR);
 
 foreach $target  (@targets)
 {
	 if($target eq '.' || $target eq '..')
	 {
		 next;
	 }



	 $prepare_file_ss =  $path_out."/".$target_id.".ss2";
	 $prepare_file_acc =  $path_out."/".$target_id.".acc";
	 $prepare_file_fasta =  $path_out."/".$target_id.".fasta";
	 $prepare_file_mtx =  $path_out."/".$target_id.".mtx";
	 $prepare_file_psi =  $path_out."/".$target_id.".psi";
	 

	 $path_out2=$path_out."/".$target_id."/".$target;
	 -s $path_out2 || system("mkdir -p $path_out2");
	 
	 if(-e $prepare_file_ss and -e $prepare_file_acc and -e $prepare_file_fasta and -e $prepare_file_mtx and -e $prepare_file_psi)
	 {
		print "\n\n---------- found the preparation files for $target\n\n";
		
		 if(substr($target,length($target)-4) eq '.pdb')
		 {
			`cp $prepare_file_ss  $path_out2/$target.ss2`;
			`cp $prepare_file_acc  $path_out2/$target.acc`;
			`cp $prepare_file_fasta  $path_out2/$target.fasta`;
			`cp $prepare_file_mtx  $path_out2/$target.mtx`;
			`cp $prepare_file_psi  $path_out2/$target.psi`;
		 }else{
			`cp $prepare_file_ss  $path_out2/$target.pdb.ss2`;
			`cp $prepare_file_acc  $path_out2/$target.pdb.acc`;
			`cp $prepare_file_fasta  $path_out2/$target.pdb.fasta`;
			`cp $prepare_file_mtx  $path_out2/$target.pdb.mtx`;
			`cp $prepare_file_psi  $path_out2/$target.pdb.psi`; 
			
		 }
	 
	 }  
	 
	 chdir($path_out2);
	 print "\t$tool $target  $target_path $path_out2\n";
	 print LOG "\t$tool $target  $target_path $path_out2\n";
	 $return = system("$tool $target  $target_path $path_out2");
	 if($return)
	 {
		 print "$tool $target  $target_path $path_out2 fails !\n";
		 exit(0);
	 }
	 $prepare_file_ss =  $path_out."/".$target_id.".ss2";
	 $prepare_file_acc =  $path_out."/".$target_id.".acc";
	 $prepare_file_fasta =  $path_out."/".$target_id.".fasta";
	 $prepare_file_mtx =  $path_out."/".$target_id.".mtx";
	 $prepare_file_psi =  $path_out."/".$target_id.".psi";
	 

	 $path_out2=$path_out."/".$target_id."/".$target;
	 -s $path_out2 || system("mkdir -p $path_out2");
	 
	 if(!(-e $prepare_file_ss) and !(-e $prepare_file_acc) and !(-e $prepare_file_fasta) and !(-e $prepare_file_mtx) and !(-e $prepare_file_psi))
	 {
		print "\n\n---------- copy to the preparation files for $target\n\n";
		
		 if(substr($target,length($target)-4) eq '.pdb')
		 {
			`cp $path_out2/$target.ss2 $prepare_file_ss `;
			`cp $path_out2/$target.acc $prepare_file_acc ` ;
			`cp $path_out2/$target.fasta $prepare_file_fasta`;
			`cp $path_out2/$target.mtx $prepare_file_mtx`;
			`cp $path_out2/$target.psi $prepare_file_psi`;
			
			print " $path_out2/$target.ss2 $prepare_file_ss | ";
			print " $path_out2/$target.acc $prepare_file_acc | " ;
			print " $path_out2/$target.fasta $prepare_file_fasta | ";
			print " $path_out2/$target.mtx $prepare_file_mtx | ";
			print " $path_out2/$target.psi $prepare_file_psi | ";
		 }else{
			`cp $path_out2/$target.pdb.ss2 $prepare_file_ss `;
			`cp $path_out2/$target.pdb.acc $prepare_file_acc ` ;
			`cp $path_out2/$target.pdb.fasta $prepare_file_fasta`;
			`cp $path_out2/$target.pdb.mtx $prepare_file_mtx`;
			`cp $path_out2/$target.pdb.psi $prepare_file_psi`;	
			
			print " $path_out2/$target.pdb.ss2 $prepare_file_ss | ";
			print " $path_out2/$target.pdb.acc $prepare_file_acc | " ;
			print " $path_out2/$target.pdb.fasta $prepare_file_fasta | ";
			print " $path_out2/$target.pdb.mtx $prepare_file_mtx | ";
			print " $path_out2/$target.pdb.psi $prepare_file_psi | ";
		 }
	 
	 }		 
	 
	if(-e "$path_out2.zip")
	{
		`rm -rf $path_out2`;
	}
	 
 }

 close LOG;
