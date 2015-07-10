#!/usr/bin/perl -w

# Delta coding on images in pgm format - DECODER
# Author: Arvin Wiyono
# Student ID: 24282588
# Since: 29 May 2015
# Usage: "perl delta_decode_image.pl pathtodeltafile"

#If number of command line arguments is not equal to 1
if($#ARGV+1 != 1){
	print "Program usage: perl delta_decode_image.pl [path to delta file]\n";
	print "Example: perl delta_decode_image.pl lennagrey.pgm.delta\n";
	exit 0;
}
else{
	# Get filename from command line argument 
	$filename = shift;
	# Check if file has .pgm extension
	if($filename !~ /(.*)\.delta/){
		print "Error: File does not have .delta extension\n";
		print "Program is quitting\n";
		exit 0;
	}
	$outputname = $1;
}

#Open file and assign the file handler
open($INPUT, "<", "$filename") or die "Could not open file '$filename' - $!\n";

##### HEADER VALIDATION #####

@string = <$INPUT>;
$string = join('', @string);
if($string =~ /^(P5)\s+(#.*\n)*\s*(\d+)\s+(\d+)\s+(\d+)\s((.|\n)*)$/){
	$magicNumber = $1;
	$width = $3;
	$height = $4;
	$maxValue = $5;
	if($maxValue > 255){
		print "Error: Maximum value is greater than 255\n";
		print "Program is quitting\n";
		exit 0;
	}
	$body = $6;
}
else{
	print "Error: Invalid PGM format !\n";
	print "Program is quitting\n";
	exit 0;
}

#Open file to write
open($OUTPUT, ">", $outputname);
# Copy the header information
print $OUTPUT "$magicNumber\n$width\n$height\n$maxValue\n";

#Read first char and encode
$pred = ord(substr($body, 0, 1));
print $OUTPUT chr($pred);

# Read the rest character in the $body
for(my $i = 1; $i < length $body; $i++){
	$diff = ord(substr($body, $i, 1));
	$diff -= 128;
	$current = $diff + $pred;
	if($current < 0){
		$current += 256;
	}
	elsif($current > 255){
		$current -= 256;
	}
	print $OUTPUT chr($current);
	$pred = $current;
}


