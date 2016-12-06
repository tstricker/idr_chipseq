#!/usr/bin/perl
use warnings;
use Data::Dumper;

unless ($#ARGV == 0) {print "Usage: bwa.pl < path >\n";exit;}

my $data_dir = $ARGV[0];
my $scripts_dir = "/home/strickt2/scripts/shell/";

my %peak;
my $ext_file = "/home/strickt2/filelists/byl.phantompeaks.txt";
open(CC, "$ext_file")||die "Can't open $ext_file!";
while(<CC>){
    chomp $_;
    my @temp = split(/\t/, $_);
    my @name = split(/\./, $temp[0]);
    my @peak = split(/\,/, $temp[2]);
    $peak{$name[0]}=$peak[0];
}
print Dumper \%peak;

my %sample;
my $sample_file = "/home/strickt2/filelists/byl.samplelist.txt";
open(AA, "$sample_file")||die "Can't find $sample_file!";
while(<AA>){
    chomp $_;
    my @temp = split(/\t/, $_);
    #my @sample = split(/\_/, $temp[1]);
    my $type=$temp[1]."_".$temp[3];
    if($temp[2]=~/ESR1/){
	$sample{$type}{ER}=$temp[0];
    }
    

    if($temp[2]=~/INPUT/){
	$sample{$type}{INPUT}=$temp[0];
    }
}

my @files = `find $ARGV[0] -name '*bam'`;

my %fin;
foreach my $i (0..$#files){
    chomp $files[$i];
    my @name = split('\/', $files[$i]);
    my @sample = split('\.', $name[$#name]);
    $fin{$sample[0]} = $files[$i];
}

print Dumper \%fin;
print Dumper \%sample;

foreach my $foo (keys %sample){
    	my $output_script = $scripts_dir.$foo."macs.sh";
	my $erout_file = $data_dir.$foo.".ER";
	my $ername = $foo.".ER14nm";
	#my $fgfrname = $foo.".H3K4_2";
	#`mkdir $ername`;
	#`mkdir $fgfrname`;
	#my $fgfrout_file = $data_dir.$foo.".H3K4";
	open (OUT, ">$output_script")||die "Can't open $output_script!";
	my $email = "thomas.stricker\@vanderbilt.edu";
	print OUT "\#\!\/bin\/bash\n\#SBATCH --mail-user=$email\n\#SBATCH --mail-type=ALL\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=8\n\#SBATCH --mem=120000mb\n\#SBATCH --time=2:00:00\n\#SBATCH -o /home/strickt2/log/$foo.macs2.log\n";

	#print OUT "setpkgs -a java\n";
	#print OUT  "python /home/strickt2/bin/macs2 callpeak -t $fin{$sample{$foo}{ER}} -c $fin{$sample{$foo}{INPUT}} -n $ername --outdir $erout_file --nomodel --extsize $peak{$sample{$foo}{ER}} --to-large -q 0.05\n";
        #print  "python /home/strickt2/bin/macs2 callpeak -t $fin{$sample{$foo}{ER}} -c $fin{$sample{$foo}{INPUT}} -n $ername --outdir $erout_file --nomodel --extsize $peak{$sample{$foo}{ER}} -to-large -q 0.05\n";
        
	
       #print OUT  "macs14 -t $fin{$sample{$foo}{ER}} -c $fin{$sample{$foo}{INPUT}} -n $ername -f BAM  --keep-dup 1 \n";
       #print OUT  "macs14 -t $fin{$sample{$foo}{H3K4}} -c $fin{$sample{$foo}{INPUT}} -n $fgfrname -f BAM  --keep-dup 1 \n";
        #print  "macs14 -t $fin{$sample{$foo}{ER}} -c $fin{$sample{$foo}{INPUT}} -n $ername -f BAM  --keep-dup 1 \n";
        #print "macs14 -t $fin{$sample{$foo}{H3K4}} -c $fin{$sample{$foo}{INPUT}} -n $fgfrname -f BAM  --keep-dup 1 \n";  

	print OUT  "macs14 -t $fin{$sample{$foo}{ER}} -c $fin{$sample{$foo}{INPUT}} -n $ername -f BAM  --keep-dup 1 -p 0.0005 --nomodel --shiftsize 200\n";
        #print OUT  "macs14 -t $fin{$sample{$foo}{H3K4}} -c $fin{$sample{$foo}{INPUT}} -n $fgfrname -f BAM  --keep-dup 1 -p 0.0005   --nomodel --shiftsize 200\n";
	print  "macs14 -t $fin{$sample{$foo}{ER}} -c $fin{$sample{$foo}{INPUT}} -n $ername -f BAM  --keep-dup 1 -p 0.0005 --nomodel --shiftsize 200\n";
        #print  "macs14 -t $fin{$sample{$foo}{H3K4}} -c $fin{$sample{$foo}{INPUT}} -n $fgfrname -f BAM  --keep-dup 1 -p 0.0005   --nomodel --shiftsize 200\n";
      

       #`sbatch $output_script`;

}


