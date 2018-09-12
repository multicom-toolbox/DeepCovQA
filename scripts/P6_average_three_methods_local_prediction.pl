use FileHandle; # use FileHandles instead of open(),close()
use Carp; # get standard error / warning messages
use Scalar::Util qw(looks_like_number);

$num = @ARGV;

if($num != 4)
{
	die "The number of parameters ($num) is not correct!\n";
}
$prediction_file1 = $ARGV[0];#
$prediction_file2 = $ARGV[1];#
$prediction_file3 = $ARGV[2];#
$prediction_out = $ARGV[3];#


open(TMP,"$prediction_file1") || die "Failed to open file $prediction_file1\n";
%interested_model2score = ();
while(<TMP>)
{
	$line=$_;
	chomp($line);
	$line=~s/\s+$//;  # remove the windows character
	@tem_split=split(/\s+/,$line);
	if(@tem_split==0)
	{# empty line
		next;
	}
	if($tem_split[0] eq "Method" || $tem_split[0] eq "METHOD" || $tem_split[0] eq "AUTHOR" || $tem_split[0] eq "END" || $tem_split[0] eq "QMODE" || $tem_split[0] eq "MODEL" || $tem_split[0] eq "TARGET" || $tem_split[0] eq "PFRMAT")
	{
		next;
	}

	if( ($tem_split[0] ne "") && ($tem_split[0] ne "X") && (! looks_like_number($tem_split[0]) ))
	{
		# this line has the model name and global score and 15*local scores
		$model_name=$tem_split[0];  # get the model name
		if(exists($interested_model2score{$model_name}))
		{
			die "!!!!! Duplicate model name $model_name\n\n";
		}
		$global_score=$tem_split[1];  # get the model name
		$model2score{$model_name} = $global_score;
		for($i=2;$i<@tem_split;$i++)
		{
       if($tem_split[$i]>15)
       {
         $tem_split[$i] = 15;
       }
			$interested_model2score{$model_name} .= " ".$tem_split[$i];
		}
	}
	else
	{# this line only has local score
		$i=0;
          if($tem_split[0] eq "")
	    {# for pcons, some prediction score will have a space at the first column, very wierd !!!!
              $i=1;
	    }
		for(;$i<@tem_split;$i++)
		{
       if($tem_split[$i]>15)
       {
         $tem_split[$i] = 15;
       }
			$interested_model2score{$model_name} .= " ".$tem_split[$i]; #T0903_PhyreTopoAlpha_TS3
		}
	}
}# end while
close TMP;
 


open(TMP,"$prediction_file2") || die "Failed to open file $prediction_file2\n";
%interested_model2score2 = ();
while(<TMP>)
{
	$line=$_;
	chomp($line);
	$line=~s/\s+$//;  # remove the windows character
	@tem_split=split(/\s+/,$line);
	if(@tem_split==0)
	{# empty line
		next;
	}
	if($tem_split[0] eq "Method" || $tem_split[0] eq "METHOD" || $tem_split[0] eq "AUTHOR" || $tem_split[0] eq "END" || $tem_split[0] eq "QMODE" || $tem_split[0] eq "MODEL" || $tem_split[0] eq "TARGET" || $tem_split[0] eq "PFRMAT")
	{
		next;
	}

	if( ($tem_split[0] ne "") && ($tem_split[0] ne "X") && (! looks_like_number($tem_split[0]) ))
	{
		# this line has the model name and global score and 15*local scores
		$model_name=$tem_split[0];  # get the model name
		if(exists($interested_model2score2{$model_name}))
		{
			die "!!!!! Duplicate model name $model_name\n\n";
		}
		$global_score=$tem_split[1];  # get the model name
		$model2score{$model_name} = $global_score;
		for($i=2;$i<@tem_split;$i++)
		{
       if($tem_split[$i]>15)
       {
         $tem_split[$i] = 15;
       }
			$interested_model2score2{$model_name} .= " ".$tem_split[$i];
		}
	}
	else
	{# this line only has local score
		$i=0;
          if($tem_split[0] eq "")
	    {# for pcons, some prediction score will have a space at the first column, very wierd !!!!
              $i=1;
	    }
		for(;$i<@tem_split;$i++)
		{
       if($tem_split[$i]>15)
       {
         $tem_split[$i] = 15;
       }
			$interested_model2score2{$model_name} .= " ".$tem_split[$i]; #T0903_PhyreTopoAlpha_TS3
		}
	}
}# end while
close TMP;


open(TMP,"$prediction_file3") || die "Failed to open file $prediction_file3\n";
%interested_model2score3 = ();
while(<TMP>)
{
	$line=$_;
	chomp($line);
	$line=~s/\s+$//;  # remove the windows character
	@tem_split=split(/\s+/,$line);
	if(@tem_split==0)
	{# empty line
		next;
	}
	if($tem_split[0] eq "Method" || $tem_split[0] eq "METHOD" || $tem_split[0] eq "AUTHOR" || $tem_split[0] eq "END" || $tem_split[0] eq "QMODE" || $tem_split[0] eq "MODEL" || $tem_split[0] eq "TARGET" || $tem_split[0] eq "PFRMAT")
	{
		next;
	}

	if( ($tem_split[0] ne "") && ($tem_split[0] ne "X") && (! looks_like_number($tem_split[0]) ))
	{
		# this line has the model name and global score and 15*local scores
		$model_name=$tem_split[0];  # get the model name
		if(exists($interested_model2score3{$model_name}))
		{
			die "!!!!! Duplicate model name $model_name\n\n";
		}
		$global_score=$tem_split[1];  # get the model name
		$model2score{$model_name} = $global_score;
		for($i=2;$i<@tem_split;$i++)
		{
       if($tem_split[$i]>15)
       {
         $tem_split[$i] = 15;
       }
			$interested_model2score3{$model_name} .= " ".$tem_split[$i];
		}
	}
	else
	{# this line only has local score
		$i=0;
          if($tem_split[0] eq "")
	    {# for pcons, some prediction score will have a space at the first column, very wierd !!!!
              $i=1;
	    }
		for(;$i<@tem_split;$i++)
		{
       if($tem_split[$i]>15)
       {
         $tem_split[$i] = 15;
       }
			$interested_model2score3{$model_name} .= " ".$tem_split[$i]; #T0903_PhyreTopoAlpha_TS3
		}
	}
}# end while
close TMP;


open(OUT,">$prediction_out") || die "Failed to open file $prediction_out\n\n";
foreach $model (sort keys %interested_model2score)
{
  $score1 = $interested_model2score{$model};
  if(!exists($interested_model2score2{$model}))
  {
    die "Failed to find score for $model in $prediction_file2\n\n";
  }
  if(!exists($interested_model2score3{$model}))
  {
    die "Failed to find score for $model in $prediction_file3\n\n";
  }
  $score2 = $interested_model2score2{$model};
  $score3 = $interested_model2score3{$model};
  
  @score1_tmp = split(/\s/,$score1);
  @score2_tmp = split(/\s/,$score2);
  @score3_tmp = split(/\s/,$score3);
  if(@score1_tmp != @score2_tmp or @score1_tmp != @score3_tmp)
  {
    die "The prediction is not equal\n\n";
  }
  
  $score_new = sprintf("%.5f",($score1_tmp[0] + $score2_tmp[0] + $score3_tmp[0])/3);
  for($i=1;$i<@score1_tmp;$i++)
  {
    $score = sprintf("%.5f",($score1_tmp[$i] + $score2_tmp[$i] + $score3_tmp[$i])/3);
    $score_new .= " $score";
    
  }
  @tem_split= split(/\s/,$score_new);
  shift @tem_split;
  $global_score_from_local = 0;
	for($i=0;$i<@tem_split;$i++)
	{
		if($tem_split[$i]>15) ### if local score is too large, set to uplimit
		{
		  $tem_split[$i] = 15;
		}
		$score_real_s =sprintf("%.3f",1/(1+($tem_split[$i]/3)*($tem_split[$i]/3)));
		$global_score_from_local += $score_real_s;
	}
	
	$global_score_from_local /= (@tem_split);
	$score_new2 = join(' ',@tem_split);
  print OUT "$model $global_score_from_local $score_new2\n";
}
close OUT;