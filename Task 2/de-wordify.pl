#!/usr/bin/perl -w

# Preprocessing data for Rice coding: de-wordify
# Author: Arvin Wiyono
# Student ID: 24282588
# Since: 26 May 2015
# Usage: "perl de-wordify.pl" OR "perl de-wordify.pl < fileinput > fileoutput"

# Validate number of command line arguments
# Program can only run without command line argument
if($#ARGV+1 != 0){
	print "Program usage: perl de-wordify.pl\n";
	print "Use < > to redirect input and output\n";
	exit 0;
}

# Declare 2 hash maps
%numberToWord = ();
%numberToNonWord = ();

# Determine the word mode by reading in the first word
$char = getc(STDIN);
if(defined($char)){
	
	$wordNumber = ord($char);
	$length = ord(getc(STDIN));
	my $word = concatenateChars($length);
	print STDOUT $word;
	
	# If current char is word char, then the next word must be non-word char
	if(isWordChar($word)){
		$numberToWord{$wordNumber} = $word;
		$word_mode = 0;
	}
	else{
		$numberToNonWord{$wordNumber} = $word;
		$word_mode = 1;
	}
}

# Keep reading char until EOF
while(defined($char = getc(STDIN))){
	$wordNumber = ord($char);
	
	# Handle the case when hash maps are full
	if($wordNumber == 255){
		$length = ord(getc(STDIN));
		# Exit program if length is greater than 255
		if($length > 255){
			print "ERROR: Length of word is greater than 255 characters.\n";
			print "Program is quitting !\n";
			exit 0;
		}
		my $word = concatenateChars($length);
		print STDOUT $word;
		
		# Toggle the word mode
		if($word_mode){
			$word_mode = 0;
		}
		else{
			$word_mode = 1;
		}
	}
	else{
		if($word_mode){
			#check whether the number exists in the hash
			if(exists $numberToWord{$wordNumber}){
				print STDOUT $numberToWord{$wordNumber};
			}
			else{
				$length = ord(getc(STDIN));
				my $word = concatenateChars($length);
				print STDOUT $word;
				$numberToWord{$wordNumber} = $word;
			}
			# Toggle the mode
			$word_mode = 0;
		}
		else{
			#check whether the number exists in the hash
			if(exists $numberToNonWord{$wordNumber}){
				print STDOUT $numberToNonWord{$wordNumber}
			}
			else{
				$length = ord(getc(STDIN));
				my $word = concatenateChars($length);
				print STDOUT $word;
				$numberToNonWord{$wordNumber} = $word;
			}
			# Toggle the mode
			$word_mode = 1;
		}
	}
}

sub concatenateChars{
	my $length = shift;
	my @word = ();
	for(my $i = 0; $i < $length; $i++){
		push(@word, getc(STDIN));
	}
	my $word = join('', @word);
	return $word;
}

# Function to check whether a character is a word character
# Return: 1, if char is word char; 0 otherwise
sub isWordChar{
	# Get the word
	my ($char) = @_;
	# If char is a “word” character (alphanumeric or “_”)
	if($char =~ /\w*/){
		return 1;
	}
	else{
		return 0;
	}
}
