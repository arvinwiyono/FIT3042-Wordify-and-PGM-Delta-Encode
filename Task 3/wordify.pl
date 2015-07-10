#!/usr/bin/perl

use List::Util qw(first);

# Preprocessing data for Rice coding: wordify with LRU caching mechanism option
# This enables us to do swapping with the least recently used word in the hash if hash is full
# Author: Arvin Wiyono
# Student ID: 24282588
# Since: 27 May 2015
# Usage: "perl wordify.pl [-c]" OR "perl wordify.pl [-c] < fileinput > fileoutput"


# Declare hash maps: with word as a key and value is word number
# This will speed up the search to know whether the word is repeated or new
%wordToNumber = ();
%nonWordToNumber = ();

# Declare hash maps: with word number as a key and the value is the word
# This will speed up the search what word has a particular word number in the caching mechanism
%numberToWord = ();
%numberToNonWord = ();

#Arrays for caching mechanism
@wordCache = (0..254);
@nonWordCache = (0..254);

# Initialize the length
$length = 0;
@word = ();

# Can only accept up to one command line argument
if($#ARGV+1 > 1){
	print "Program usage: perl wordify.pl [-c]\n";
	print "-c : Run program with LRU caching mechanism\n";
	exit 0;
}

# Validate command line argument and determine whether program is executed with cache mechanism
if($#ARGV+1 == 1){
	if($ARGV[0] eq "-c"){
		$runWithCache = 1;
	}
	else{
		print "Program usage: perl wordify.pl [-c]\n";
		print "-c : Run program with LRU caching mechanism\n";
		exit 0;
	}
}
else{
	$runWitCache = 0
}




#Determine the first word mode
if(defined($char = getc(STDIN))){
	#If character is indeed word character
	if(isWordChar($char)){
		$word_mode = 1;
	}
	else{
		$word_mode = 0;
	}
	$length++;
	push(@word,$char);
}

# Keep reading char until EOF
while(defined($char = getc(STDIN))){
	
	# If current read char has the same characteristic as word_mode
	if($word_mode == isWordChar($char)){
		# Exit program if length is greater than 255
		if($length > 255){
			print "ERROR: Length of word is greater than 255 characters.\n";
			print "Program is quitting !\n";
			exit 0;
		}
		# Push current read char to the array and increase the length
		push(@word, $char);
		$length++;
	}
	else{
		$word = join('', @word);
			
		if($runWithCache){
			outputWithCache($word_mode, $word, $length);
		}
		else{
			outputNonCache($word_mode, $word, $length);
		}
		
		# Reset word array and push the new character
		@word = ();
		push(@word, $char);
		
		# Reset length of word to one
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
	$word = join ('', @word);
	if($runWithCache){
		outputWithCache($word_mode, $word, $length);
	}
	else{
		outputNonCache($word_mode, $word, $length);
	}
}

# Method which updates the cache according to the wordMode
# If in word mode, update word cache
# Else, update the non-word cache
sub updateCache{
	my($wordMode, $wordNumber) = @_;
	if($wordMode){
		# Get the index of word number in the word cache
		my $index = first { $wordCache[$_] == $wordNumber } 0..$#wordCache;
		# Delete word number from current position and push it to the back
		splice(@wordCache, $index, 1);
		push(@wordCache, $wordNumber);
	}
	else{
		my $index = first { $nonWordCache[$_] == $wordNumber } 0..$#nonWordCache;
		# Delete word number from current position and push it to the back
		splice(@nonWordCache, $index, 1);
		push(@nonWordCache, $wordNumber);
	}
}

sub outputWithCache{
	my ($wordMode, $word, $length) = @_;
	if($wordMode){
		# If word is repeated
		if(exists $wordToNumber{$word}){
			my $wordNumber = $wordToNumber{$word};
			print STDOUT chr($wordNumber);
			updateCache($wordMode, $wordNumber);
		}
		else{
			# If word is new
			$numKeys = keys %wordToNumber;
			# If hash is still enough
			if($numKeys < 255){
				print STDOUT chr($numKeys).chr($length).$word;
				
				#update the hashes by putting in new word
				$wordToNumber{$word} = $numKeys;
				$numberToWord{$numKeys} = $word;
				updateCache($wordMode, $numKeys);
			}
			# If hash is not enough
			else{
				#Re-allocate word number
				my $newWordNumber = $wordCache[0];
				
				#Get the word to be removed from the hash
				my $removeWord = $numberToWord{$newWordNumber};
				delete $wordToNumber{$removeWord};
				
				#update the hashes by putting in new word
				$wordToNumber{$word} = $newWordNumber;
				$numberToWord{$newWordNumber} = $word;
				updateCache($wordMode, $newWordNumber);
				
				#This chr(255) is to indicate that there is an update to the respective word number
				#with a new word
				print STDOUT chr(255).chr($newWordNumber).chr($length).$word;
			}		
		}
	
	}
	else{
		# If word is repeated
		if(exists $nonWordToNumber{$word}){
			my $wordNumber = $nonWordToNumber{$word};
			print STDOUT chr($wordNumber);
			updateCache($wordMode, $wordNumber);
		}
		else{
			# If word is new
			$numKeys = keys %nonWordToNumber;
			# If hash is still enough
			if($numKeys < 255){
				print STDOUT chr($numKeys).chr($length).$word;
				
				#update the hashes by putting in new word
				$nonWordToNumber{$word} = $numKeys;
				$numberToNonWord{$numKeys} = $word;
				updateCache($wordMode, $numKeys);
			}
			# If hash is not enough
			else{
				#Re-allocate word number
				my $newWordNumber = $nonWordCache[0];
				
				#Get the word to be removed from the hash
				my $removeWord = $numberToNonWord{$newWordNumber};
				delete $nonWordToNumber{$removeWord};
				
				#update the hashes by putting in new word
				$nonWordToNumber{$word} = $newWordNumber;
				$numberToNonWord{$newWordNumber} = $word;
				updateCache($wordMode, $newWordNumber);
				
				#This chr(255) is to indicate that there is an update to the respective word number
				#with a new word
				print STDOUT chr(255).chr($newWordNumber).chr($length).$word;
			}		
		}
	
	}
}

#Output and update hashes without caching mechanism
sub outputNonCache{
	my ($wordMode, $word, $length) = @_;
	if($wordMode){
		# If word exists in the hash, print only the word number
		if(exists $wordToNumber{$word}){
			my $charWordNumber = chr($wordToNumber{$word});
			print STDOUT $charWordNumber;
		}
		else{
			# If word is new, then print word number, length, and word respectively
			my $numOfKeys = keys %wordToNumber;
			# If hash table is still enough to hold
			if($numOfKeys < 255){
				my $charNumOfKeys = chr($numOfKeys);
				my $charLength = chr($length);
				print STDOUT $charNumOfKeys.$charLength.$word;
			
				#update the hash by putting in new word
				$wordToNumber{$word} = $numOfKeys;
			}
			else{
				# If hash map is full, simply print chr(255) as identification 
				# for program not remembering this new word
				print STDOUT chr(255).chr(length $word).$word;
			}
		}
	}
	else{
		# If word exists in the hash, print only the word number
		if(exists $nonWordToNumber{$word}){
			my $charWordNumber = chr($nonWordToNumber{$word});
			print STDOUT $charWordNumber;
		}
		else{
			# If word is new, then print word number, length, and word respectively
			my $numOfKeys = keys %nonWordToNumber;
			# If hash table is still enough to hold
			if($numOfKeys < 255){
				my $charNumOfKeys = chr($numOfKeys);
				my $charLength = chr($length);
				print STDOUT $charNumOfKeys.$charLength.$word;
			
				#update the hash by putting in new word
				$nonWordToNumber{$word} = $numOfKeys;
			}
			else{
				print STDOUT chr(255).chr(length $word).$word;
			}
		}
	}
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
