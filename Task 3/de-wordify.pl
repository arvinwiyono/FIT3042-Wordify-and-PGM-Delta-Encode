#!/usr/bin/perl -w

# Preprocessing data for Rice coding: de-wordify with LRU caching mechanism option
# Author: Arvin Wiyono
# Student ID: 24282588
# Since: 27 May 2015
# Usage: "perl de-wordify.pl [-c]" OR "perl de-wordify.pl [-c] < fileinput > fileoutput"

# Declare 2 hash maps
%numberToWord = ();
%numberToNonWord = ();

# Can only accept up to one command line argument
if($#ARGV+1 > 1){
	print "Program usage: perl de-wordify.pl [-c]\n";
	print "-c : Run program with LRU caching mechanism\n";
	exit 0;
}


# Validate command line argument and determine whether program is executed with cache mechanism
if($#ARGV+1 == 1){
	if($ARGV[0] eq "-c"){
		$runWithCache = 1;
	}
	else{
		print "Program usage: perl de-wordify.pl [-c]\n";
		print "-c : Run program with LRU caching mechanism\n";
		exit 0;
	}
}
else{
	$runWithCache = 0
}

# Determine the word mode by reading in the first word
$char = getc(STDIN);
if(defined($char)){
	
	$wordNumber = ord($char);
	$length = ord(getc(STDIN));
	my $word = concatenateChars($length);
	print STDOUT $word;
	
	
	if(isWordChar($word)){
		
		$numberToWord{$wordNumber} = $word;
		# If current char is word char, then the next word must be non-word char
		$word_mode = 0;
		
	}
	else{
		$numberToNonWord{$wordNumber} = $word;
		$word_mode = 1;
	}
}

# Keep reading char until EOF
while (defined ($char = getc(STDIN))){
	#Get the word number
	$number = ord($char);
	
	# Process with cache mechanism
	if($runWithCache){
		#255 is a sign that there is an update to existing word number
		if($number == 255){
			$wordNumber = ord(getc(STDIN));
			$length = ord(getc(STDIN));
			my $word = concatenateChars($length);
			#Update the word in the hash
			if($word_mode){
				$numberToWord{$wordNumber} = $word;
				#Toggle the mode
				$word_mode = 0;
			}
			else{
				$numberToNonWord{$wordNumber} = $word;
				#Toggle the mode
				$word_mode = 1;
			}
			print STDOUT $word;
		}
		else{
			#Assign number to word number
			$wordNumber = $number;
			normalProcedure($wordNumber);
		}		
	}
	# Process without cache mechanism - This is exactly the same as task 2
	else{
		# Handle the case when hash maps are full
		$wordNumber = $number;
		if($wordNumber == 255){
			$length = ord(getc(STDIN));
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
			normalProcedure($wordNumber);
		}
	}
}

#The shared procedure for both caching and non-caching mechanism. This reduces code duplication
sub normalProcedure{
	my $wordNumber = shift;
	if($word_mode){
		#check whether the number exists in the hash
		if(exists $numberToWord{$wordNumber}){
			print STDOUT $numberToWord{$wordNumber};
		}
		else{
			my $length = ord(getc(STDIN));
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
			my $length = ord(getc(STDIN));
			my $word = concatenateChars($length);
			print STDOUT $word;
			$numberToNonWord{$wordNumber} = $word;
		}
		# Toggle the mode
		$word_mode = 1;
	}
}

#Function which concatenates read character for $length times and return it as a word
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
	# Get the word/char
	my ($char) = @_;
	# If char is a “word” character (alphanumeric or “_”)
	if($char =~ /\w*/){
		return 1;
	}
	else{
		return 0;
	}
}
