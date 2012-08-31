#!/usr/bin/perl
##==============================================================================#
##-------------------------------help-info-start--------------------------------#

=head1 Name

    checkSpellAndGiveSuggestions.pl --> checkSpellAndGiveSuggestions, notice: only
    give one possible word as sugesstion, maybe not the best one;

=head1 Usage

    perl  checkSpellAndGiveSuggestions.pl [options] <"words to check ">

    -help       print this help to screen
    -o          write result to a file, default print to STDOUT .

=head1 Example

    perl  checkSpellAndGiveSuggestions.pl -h
    perl  checkSpellAndGiveSuggestions.pl "quitee extravagent armchir zoomde"

=head1 Version
    Verion      :  1.0
    Created     :  2012/08/31 22时47分07秒
    Updated     :  --
    LastMod     :  --

=head1 Contact

    Author      :  QuNengrong (Qunero)
    E-mail      :  Quner612@qq.com,Quner8@gmail.cn
    Company     :  BGI

=cut
#-------------------------------help-info-end--------------------------------#
#============================================================================#
use strict;
use warnings;
use Getopt::Long;

my ($Need_help, $Out_file );
GetOptions(
    "help"      => \$Need_help,
    "o=s"       => \$Out_file,
);

die `pod2text $0` if ($Need_help);

#============================================================================#
#                              Global Variable                               #
#============================================================================#
#my $Input_file  = $ARGV[0]  if (exists $ARGV[0]);
my $Input_file = "dict.txt";
my $wordArg = $ARGV[0];
$wordArg =~ s/"//g;
$wordArg = lc $wordArg;
my @wordsToCheck = split /\s+/, $wordArg;
my %dict;                                       # store the dictionary words 
my @alphabet = 'a' .. 'z';

#============================================================================#
#                               Main process                                 #
#============================================================================#

if(defined $Input_file)
{ open(STDIN, '<', $Input_file) or die "Can't read $Input_file : $!"; }
if(defined $Out_file)
{ open(STDOUT, '>', $Out_file) or die "Can't write $Out_file : $!"; }

print STDERR "---Program\t$0\tstarts --> ".localtime()."\n";

while(<STDIN>){
    chomp;
    $dict{ $_ } = 1;
}

my($sug, $foundSim) = ('', 0);
foreach (@wordsToCheck){
    if(exists $dict{$_}){
        # correct word , just go on
        next;
    }
    elsif(
        &swapAndCheck($_) ||
        &deleteAndCheck($_) ||
        &replaceAndCheck($_) ||
        &insertAndCheck($_)
    ){
        # if found a suggestion word  , output it 
        print STDOUT "Spelling: $_ -> $sug\n";
        $sug = '';
    }
    else{
        # todo : may it happen?
    }
}


print STDERR "---Program\t$0\tends  --> ".localtime()."\n";

#============================================================================#
#                               Subroutines                                  #
#============================================================================#

sub swapAndCheck{
    # swap ajacent letter to check whether match a dictionary word
    my $word = shift @_;
    my ($nword, $l, $r);

    foreach my $i(0 .. length($word)-2){
        $l = substr($word, 0, $i);
        if( $i+2 < length($word)){
            $r = substr($word, $i+2);
        }else{
            $r = '';
        }
        $nword = $l . substr($word, $i+1, 1) . substr($word, $i, 1) . $r; 
        if(exists $dict{$nword}){
            $sug = $nword;                      # found one ,set it 
            return 1;
        }
    }

    return 0;
}

sub deleteAndCheck{
    # delete one letter and check  
    my $word = shift @_;
    my $nword;
#    my @wa = split //,$word;
    foreach my $i(0 .. length($word)-2){
        $nword = substr($word, 0, $i) . substr($word, $i+1);
        if(exists $dict{$nword}){
            $sug = $nword;
            return 1;
        }
    }
    # check the last one's deletion 
    $nword = substr($word, 0, -1);
    if(exists $dict{$nword}){
        $sug = $nword;
        return 1;
    }

    return 0;
}

sub replaceAndCheck{
    # replace one letter and check  
    my $word = shift @_;
    my $nword;
    foreach my $i(0 .. length($word)-2){
        foreach(@alphabet){                     
            # notice; checked all 26 letters, for convenience
            $nword = substr($word, 0, $i) . $_ . substr($word, $i+1);
            if(exists $dict{$nword}){
                $sug = $nword;
                return 1;
            }
        }
    }
    # check the last one's replace  
    $nword = substr($word, 0, -1);
    foreach(@alphabet){
        if(exists $dict{$nword . $_}){
            $sug = $nword . $_;
            return 1;
        }
    }

    return 0;
}

sub insertAndCheck{
    # insert one letter and check again
    my $word = shift @_;
    my ($nword, $l, $r);
#    print STDERR "check : insertAndCheck\n";

    foreach my $i(0 .. length($word)-1){
        $l = substr($word, 0, $i) ;
        $r = substr($word, $i);
        foreach(@alphabet){
            $nword = $l . $_ . $r;
            if(exists $dict{$nword}){
                $sug = $nword;
                return 1;
            }
        }
    }

    # add after last elem
    foreach(@alphabet){
        $nword = $word . $_;
        if(exists $dict{$nword}){
            $sug = $nword;
            return 1;
        }
    }

    return 0;
}

