#!/usr/bin/perl -w

# Preprocessing data for Rice coding: wordify
# Author: Arvin Wiyono
# Student ID: 24282588
# Since: 26 May 2015
# Usage: "perl wordify.pl" OR "perl wordify.pl < fileinput > fileoutput"

# Validate number of command line arguments
# Program can only run without command line argument
if($#ARGV+1 != 0){
	print "Program usage: perl wordify.pl\n";
	print "Use < > to redirect input and output\n";
	exit 0;
}

# Declare STDIN and STDOUT
$INPUT = STDIN;
$OUTPUT = STDOUT;

# Declare hash maps: with word as a key and value is word number
# This will speed up the search to know whether the word is repeated or new
%wordToNumber = ();
%nonWordToNumber = ();

# Initialize necessary global variables
$length = 0;
@word = ();
@non_word = ();

# Determine the first word mode
if(defined ($char = getc($INPUT))){
	if(isWordChar($char)){
		$word_mode = 1;
		push(@word, $char);
	}
	else{
		$word_mode = 0;
		push(@non_word, $char);
	}
	$length++;
}


# Keep reading characters until EOF
while(defined($char = getc($INPUT))){
	if($word_mode == isWordChar($char)){
		
		# Exit program if length is greater than 255
		if($length > 255){
			print "ERROR: Length of word is greater than 255 characters.\n";
			print "Program is quitting !\n";
			exit 0;
		}
	
		if($word_mode){
			push (@word, $char);
		}
		else{
			push (@non_word, $char);
		}
		$length++;
	}
	else{
		if($word_mode){
			$word = join ('', @word);
			# Reset the OPPOSITE array and push the character
			# When the mode is word, then this means the current char is non-word
			@non_word = ();
			push (@non_word, $char);
		}
		else{
			$word = join ('', @non_word);
			# Reset the array and push the character
			@word = ();
			push (@word, $char);
		}
		output($word_mode, $word, $length);
		$length = 1;
		# Toggle the mode
		if($word_mode){
			$word_mode = 0;
		}
		else{
			$word_mode = 1;
		}
	}
}

# Output the last word
if($length != 0){
	if($word_mode){
		$word = join ('', @word);
	}
	else{
		$word = join ('', @non_word);
	}
	output($word_mode, $word, $length);
}

# Function to check whether a character is a word character
# Return: 1, if char is word char; 0 otherwise
sub isWordChar{
	# Get the word
	my ($char) = @_;
	# If char is a “word” character (alphanumeric or “_”)
	if($char =~ /\w/){
		return 1;
	}
	else{
		return 0;
	}
}

sub output{
	my($wordMode, $word, $length) = @_;
	
	if($wordMode){
		# If word exists in the hash, print only the word number
		if(exists $wordToNumber{$word}){
			$charWordNumber = chr($wordToNumber{$word});
			print $OUTPUT $charWordNumber;
		}
		else{
			# If word is new, then print word number, length, and word respectively
			my $numOfKeys = keys %wordToNumber;
			# If hash table is still enough to hold
			if($numOfKeys < 255){
				my $charNumOfKeys = chr($numOfKeys);
				my $charLength = chr($length);
				print $OUTPUT $charNumOfKeys.$charLength.$word;
			
				#update the hash by putting in new word
				$wordToNumber{$word} = $numOfKeys;
			}
			else{
				print $OUTPUT chr(255).chr(length $word).$word;
			}
		}
	}
	else{
		# If word exists in the hash, print only the word number
		if(exists $nonWordToNumber{$word}){
			$charWordNumber = chr($nonWordToNumber{$word});
			print $OUTPUT $charWordNumber;
		}
		else{
			# If word is new, then print word number, length, and word respectively
			my $numOfKeys = keys %nonWordToNumber;
			# If hash table is still enough to hold
			if($numOfKeys < 255){
				my $charNumOfKeys = chr($numOfKeys);
				my $charLength = chr($length);
				print $OUTPUT $charNumOfKeys.$charLength.$word;
			
				#update the hash by putting in new word
				$nonWordToNumber{$word} = $numOfKeys;
			}
			else{
				print $OUTPUT chr(255).chr(length $word).$word;
			}
		}
	}
}

