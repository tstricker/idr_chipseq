#!/usr/bin/perl
#use strict;
use warnings;
use Data::Dumper;

unless ($#ARGV == 0) {print "Usage: chipseq.pl < path >\n";exit;}

my $data_dir = $ARGV[0];
my $scripts_dir = "/home/strickt2/scripts/shell/";
my $run_spp = "/home/strickt2/SEQanalysis/phantompeakqualtools/run_spp.R";

my %chip;
my %zcat;
my $file = "/home/strickt2/filelists/luigi.sample.list.txt";
open(AA, "$file")||die "Can't open $file!";
while(<AA>){
    chomp $_;
 
    my @temp = split(/\t/, $_);
    my $condition = join '', $temp[2], $temp[3],$temp[4];
    $chip{$temp[0]}{COND}=$condition;
    $chip{$temp[0]}{INPUT}=$temp[5];
    $chip{$temp[0]}{NAME}=$temp[1];
    push @{$zcat{$condition}}, $temp[0];
}

print Dumper \%zcat;

my @files = `find $ARGV[0] -name '*bam.tagAlign.gz'`;
#print Dumper \@files;


my %fin;
foreach my $i (0..$#files){
    chomp $files[$i];
    if ($files[$i]=~/TPS/){
	my @temp = split(/\//,$files[$i]);
	my @name = split('\.', $temp[$#temp]);

	$fin{$name[0]} = $files[$i];
    }
}
print Dumper \%fin;


#`mkdir $data_dir/filter/`;
foreach my $foo (keys %zcat){
    my $output_script = $scripts_dir.$foo.".spp.sh";
    open (OUT, ">$output_script")||die "Can't open $output_script!";
    my $email = "thomas.stricker\@vanderbilt.edu";
    print OUT "\#\!\/bin\/bash\n\#SBATCH --mail-user=$email\n\#SBATCH --mail-type=ALL\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=8\n\#SBATCH --mem=120000mb\n\#SBATCH --time=48:00:00\n\#SBATCH -o /home/strickt2/log/$foo.clip.log\n";
    my $out = $data_dir."/".$foo;
    #`mkdir $out`;
    my $pool = $out."/".$foo.".pooled.tagAlign.gz";
    print OUT "setpkgs -a R\n";
    print OUT "zcat $fin{$zcat{$foo}[0]} $fin{$zcat{$foo}[1]} | gzip -c > $pool\n";
    print "zcat $fin{$zcat{$foo}[0]} $fin{$zcat{$foo}[1]} | gzip -c > $pool\n";
    print OUT "Rscript $run_spp -c=$pool -i=$chip{$zcat{$foo}[0]}{INPUT} -npeak=300000 -odir=$out -savr -savp -rf\n";  
    print "Rscript $run_spp -c=$pool -i=$chip{$zcat{$foo}[0]}{INPUT} -npeak=300000 -odir=$out -savr -savp -rf\n";  

  `sbatch $output_script`;
}



