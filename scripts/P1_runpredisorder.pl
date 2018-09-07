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
 if (@ARGV != 3)
    { # @ARGV used in scalar context = number of args
	  print("This script add chain to all server prediction pdbs, with each subfold for one target.    One input, another script add_chainID_to_pdb.pl, and one output\n");
	  print "\nFor example:\n";
	  print "perl $0 ../data_downloaded_from_CASP/data_server_prediction/casp8_server_prediction add_chainID_to_pdb.pl ../data_downloaded_from_CASP/data_server_prediction/chain_added_casp8_server_prediction\n";

	  exit(0);
	}
 
 my($path_fasta)=$ARGV[0];#chain_added_casp9_native
 my($tool)=$ARGV[1]; #bin/predict_diso.sh
 my($path_out)=$ARGV[2]; #$filename.disorder;

 -s $path_fasta || die "Cannot open input folder\n";
  -s $tool || die "Cannot open input $tool\n";
 my($return,$file,$target,$target_path,$path_in,$filename);

	 
 if(!(-e $path_fasta))
 {
	print "Failed to find $path_fasta\n";
	next;
 }	 


 $return = system("$tool  $path_fasta   $path_out");
 if($return)
 {
	 print "$tool  $path_fasta   $path_out fails !\n";
	 exit(0);
 }

