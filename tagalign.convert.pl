#!/usr/bin/perl                                                                                                                                                                           
use strict;
use warnings;
use Data::Dumper;

unless ($#ARGV == 0) {print "Usage: fastqc.pl < path >\n";exit;}

my $data_dir = $ARGV[0];
my $scripts_dir = "/home/strickt2/scripts/shell/";

my @files = `find $ARGV[0] -name '*.bam'`;
print Dumper \@files;

my %fin;
foreach my $i (0..$#files){
    chomp $files[$i];
    my @temp = split(/\//,$files[$i]);
    my @name = split('\_', $temp[$#temp]);
    print Dumper \@name;
    $fin{$name[0]} = $files[$i];
}
print Dumper \%fin;


`mkdir $data_dir/tagalign/`;
foreach my $foo (keys %fin){
    my $output_script = $scripts_dir.$foo.".tagalign.sh";
    open (OUT, ">$output_script")||die "Can't open $output_script!";
    my $email = "thomas.stricker\@vanderbilt.edu";
    print OUT "\#\!\/bin\/bash\n\#SBATCH --mail-user=$email\n\#SBATCH --mail-type=ALL\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=1\n\#SBATCH --mem=10000mb\n\#SBATCH --time=3:00:00\n\#SBATCH -o /home/strickt2/log/$foo.clip.log\n";
    my $out = $data_dir."/tagalign/".$foo.".tagAlign.gz";
    print OUT "samtools view -b -F 1548 -q 30 $fin{$foo} | bamToBed -i stdin | awk 'BREGIN{FS=\"\\t\";OFS=\"\\t\"}{\$4=\"N\";print \$0}' | gzip -c >  $out\n";
    print "samtools view -b -F 1548 -q 30 $fin{$foo} | bamToBed -i stdin | awk 'BEGIN{FS=\"\\t\";OFS=\"\\t\"}{\$4=\"N\";print \$0}' | gzip -c >  $out\n";

    `sbatch $output_script`;
}



