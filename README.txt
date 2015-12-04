
*FIT3042 - ASSIGNMENT 2*
*Simple Text and Image Compression Using Perl *

STUDENT NAME	: ARVIN WIYONO
STUDENT ID	: 24282588
EMAIL		: awiy1@student.monash.edu
SUBMISSION DATE	: Friday, 29 May 2015

NOTE: Every task folder (Task 1, Task 2, etc.) contains at least one shell script to run
and test the perl programs. Thus, marker only needs to execute the test script to run the program
without needing to type in the compilation code. Each shell script includes commands to carry out 
the testing and comments for clarity.

Test script mignt need to be given permission by using: "chmod 755 script_name"
Execute script by using entering: "./script_name"



###### TASK 1 - Adaptive re-rank and de-rank #########

Status: Correct and tested
Test files: dickens.txt and gutenberg.txt
Program usage: adaptive_re-rank.pl [-swap_next | -swap2front] < input > output
	       adaptive_de-rank.pl [-swap_next | -swap2front] < input > output

Test scripts:
	1) swapnext_test - test the swap next algorithm of adaptive_re-rank.pl
	2) swap2front_test - test the swap to front algorithm of adaptive_re-rank.pl
	run by 	

Method used for testing:
1) Rerank both dickens.txt and gutenberg.txt by using swap next / swap to front
2) Derank the "reranked" files using the current adaptive_de-rank.pl AND the C program for de-rank
   developed in Assignment 1.
3) Compare the result by using 'diff' comment. 
   If something differs, bash will output the different lines
4) If the perl de-rank can decode and the result is the same as the C decoder gets, this means that 
   both perl re-rank and de-rank are consistent and correctly implemented.



###### TASK 2 - Wordify and De-wordify #########

Status: Correct and tested
Test files: dickens.txt and HiddenTreasures.txt (text based)
	    lennagrey.pgm (non-text based)

Program Usage: perl wordify.pl < fileinput > fileoutput
	       perl de-wordify.pl < fileinput > fileoutput

Test script: test_wordify

Method used for testing:
1) Encode all the test files by using wordify.pl and produce files with suffix "_encoded"
2) Decode all the "encoded" files using de-wordify.pl and produce files with suffix "_original"
3) Compare the original files with the decoded files by using diff LINUX command
4) Rerank all the encoded files by using adaptive_re-rank.pl -swap2front
5) Compress all the re-ranked files by using rice_compression

ANALYSIS AND DISCUSSION:
When we compressed the "encoded" files, it DOES NOT produce compressed files with big difference in
size. However, wordify.pl works well with adaptive_re-rank.pl from Task 1, which re-organizes
the most frequent ord($char) in the encoded files to have smaller ranks. This optimizes the compression
process of rice_coding, which depends on the rank of the read char.

For example, HiddenTreasures_compressed has 627.1 kB, down from 871.7 kB. This is a pretty significant
difference of 244.6 kB or 28.06%. dickens_compressed also has smaller size compared to the original file
even though the size difference is very small. 

However, this does not happen with lennagrey.pgm, which is a non-text based file. 
This might be caused by the body structure of the pgm file which is not well-structured 
compared to the text-based ones. Since wordify reads each 'word' one by one, it does make sense that
.pgm file contains a lot more different words. This results in full hash map and therefore 
wordify could not remember any new words so quickly.


 
###### TASK 3 - Wordify and De-wordify using LRU Cache Mechanism #########

Status: Correct and tested
Test files: dickens.txt and HiddenTreasures.txt

Program Usage: perl wordify.pl [-c] < fileinput > fileoutput
	       perl de-wordify.pl [-c] < fileinput > fileoutput
	       Enter -c option to turn on the caching mechanism

NOTE: wordify.pl with cache takes longer time to encode a file. Therefore running test_with_cache
      script might take 4 to 6 seconds to produce the generated files.

Test scripts:
	1) test_no_cache: Test wordify.pl with NO caching mechanism
	2) test_with_cache: Test wordify.pl with caching mechanism
	Run both scripts to compare compressed size

This time, we only focus on the HiddenTreasures.txt since it contains a lot more lines and ensures
that both programs are correctly implemented.

Method used for testing:
1) Encode HiddenTreasures.txt with wordify.pl (no cache AND with cache)
2) Decode the enocded file using de-wordify.pl
3) Put the encoded file into adaptive_re-rank -swap2front
4) Compress the reranked file with rice coder

ANALYSIS AND DISCUSSION:
As stated in the above NOTE, the wordify with caching mechanism takes longer time to encode a file.
This is because whenever a word number is referenced, it needs to invoke the updateCache() procedure,
which has complexity of O(N). 

This version of wordify with cache prints chr(255).chr(wordNumber).chr(length).word if there is
a word number rellocation. chr(255) is used by the de-wordify to know if there is a word number
re-allocation. This is a space for time tradeoff, which means that the de-wordify
doesn't need to do any caching since it knows which word number is replaced by a new word.
This might result in bigger compressed file compared to the version which only prints
chr(255).chr(length).word.

The ENCODED file with cache has relatively smaller size compared to one without cache. For example,
encoded_no_cache has size of 923.1kB and encoded_with_cache has 832.9kB. However, after 
re-ranking both encoded files and compressed them, compressed_with_cache has approx. more 50kB than
compressed_no_cache. This means that caching mechanism affects more on the "encoded" file rather than
the compressed file. This might also be affected by the fact that wordify.pl always prints the new
word number everytime word number reallocation occurs.

Besides the above fact, both compressed files achieve a quite good compression ratio compared to 
the original file. compressed_no_cache is 627.1 kB and compressed_with_cache is 674.8 kB, meanwhile
HiddenTreasures.txt is 871.7 kB. Considering this, both caching and non-caching achieve considerably
good compression ratio.



###### TASK 4 - Delta Encoding and Decoding of .pgm Image #########

Status: Correct and tested
Test files: lennagrey.pgm, shapes.pgm, mandrillgrey.pgm and ref12q5-0.pgm

Program usage: 	perl delta_encode_image.pl pathtopgmfile
		perl delta_decode_image.pl pathtodeltafile

Test scripts:
	1) test_delta_encoder  (MUST BE EXECUTED BEFORE test_delta_decoder)
	2) test_delta_decoder

Method used for testing:
1) encode the .pgm images with delta_encode_image.pl. Encoding ref12q5-0.pgm should produce error
   message since the max byte value is > 255
2) Decode the delta images with delta_decode_image.pl and see whether the original images are produced
3) Rerank the encoded files with adaptive re-rank -swap2front
4) Compressed the reranked files and the delta files using rice coder
5) Compare the compression result between rerank and no rerank.


ANALYSIS AND DISCUSSION:
After running the script we can compare the result of compression with and without rerank.
Again, the result evidences that delta encoder works very well with adaptive_re-rank since it changes
the rank of most frequent byte difference to have significantly smaller ranks. For instance,
file compressed_lennagrey_norerank is 268.3 kB and compressed_lennagrey_reranked is 168.3 kB = 100 kB
difference in size. Meanwhile, without the help of adaptive_re-rank, delta encoding does not really
affect the compression process.


CONCLUSION:
all pre-processing programs in this assignment can achieve greater result by combining them with the 
developed adaptive_re-rank. This will enable the rice coder to process char with smaller ranks and
therefore produces files with better compression ratio.
