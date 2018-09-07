###########################
#parse sequence from the model
#
#Zheng Wang
###########################

my $input = $ARGV[0];
my $name = $ARGV[1];

%amino=();
$amino{"ALA"} = 'A';
$amino{"CYS"} = 'C';
$amino{"ASP"} = 'D';
$amino{"GLU"} = 'E';
$amino{"PHE"} = 'F';
$amino{"GLY"} = 'G';
$amino{"HIS"} = 'H';
$amino{"ILE"} = 'I';
$amino{"LYS"} = 'K';
$amino{"LEU"} = 'L';
$amino{"MET"} = 'M';
$amino{"MSE"} = 'M';
$amino{"ASN"} = 'N';
$amino{"PRO"} = 'P';
$amino{"GLN"} = 'Q';
$amino{"ARG"} = 'R';
$amino{"SER"} = 'S';
$amino{"THR"} = 'T';
$amino{"VAL"} = 'V';
$amino{"TRP"} = 'W';
$amino{"TYR"} = 'Y';

        #############Parse the AA sequence############
        open(IN, "<$input") or die("cannot open");;
        while(<IN>){
                my $line = $_;
                #print $line;
                if(substr($line, 0, 4) eq "ATOM" && substr($line, 12, 4) =~ /CA/){
                        my $residue = substr($line, 17, 3);
                        $residue = uc($residue);
                        $sequence .= $amino{$residue};
                }
        }
        close(IN);
        print LOG "SEQUENCE is $sequence\n";
        open(FASTA, ">$name");
        print FASTA ">$name\n";
        print FASTA $sequence;
        close FASTA;

