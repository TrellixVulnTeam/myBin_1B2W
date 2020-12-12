#!/usr/bin/perl -w
## this is the version more accurate than previous one. it report every invidual location in red location
use 5.010;
use Cwd;

my $file = shift;
my @array=();

open (FILE, $file) or die "cannot open file $file";
    @file = <FILE>;
close FILE;



my @header= split("\t", shift @file);
shift @header;
for (my $i=0; $i<@file; $i++){
    my @line=split("\t", $file[$i]);
    my $sampleName=shift @line;
    print "$sampleName ";
    for (my $j=0; $j<@line; $j++){        
        my @elem=split(">", $line[$j]);
        for (my $idx=0; $idx<@elem; $idx++){
            if ($elem[$idx] !~ m/^$/ && $elem[$idx] !~ m/rs\d*/){
                my $info="$header[$j]"."$elem[$idx]";
                if($idx==0){print "$info\n";}
                elsif($j>0) {print "$sampleName\t$info\n";}                
            }

        }
        # if ($line[$j] !~ m/^$/ && $line[$j] !~ m/rs\d*/){
        #     my $info="$header[$j]"."$line[$j]";
        #     print "$info\t";
        # }
    }
    print "\n";
}

print "################################################\n";

for (my $i=0; $i<@file; $i++){
    my @line=split("\t", $file[$i]);
    my $sampleName=shift @line;
    # print "$sampleName\t";
    for (my $j=0; $j<@line; $j++){        
        my @elem=split(">", $line[$j]);
        for (my $idx=0; $idx<@elem; $idx++){
            if ($elem[$idx] =~ m/rs\d*/ ){
                my $info="$header[$j]"."$elem[$idx]";
                if ($j==0){print "$info\n";}
                else{print "$sampleName\t$info\n";}                    
            }    
        }
        # if ($line[$j] =~ m/rs\d*/ ){
        #     my $info="$header[$j]"."$line[$j]";
        #     if ($j==0){print "$info\n";}
        #     else{print "$sampleName\t$info\n";}            
        # }
    }
    print "\n";
}

