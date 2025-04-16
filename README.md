# Genome Assembly

## Description
Do you have long or short reads, (Illumina, PacBio, ONT) but have no idea what to do with them? You came to the right place. 
This guide will cover what to do with short & long reads depending on what you want to gain.

## Short reads: Illumina
Short reads are generally used as an add-on to an already assembled genome. They can be used if you have a good reference genome already.



# Long reads: PacBio, ONT
With long reads, you can generally assemble a genome (depending on the quality of the reads). There are multiple programs that can be used for genome assembly, each with their advantages and disadvantages. I will go over some programs I ahve used and when to use each one.
Luckily, most programs work with both ONT and PacBio data, you just need to specify which of the two you have.


## Genome Assembly
With genome assembly, there is often not 'one' golden rule for what assembly to choose, which parameters to tweak, or which program to use. Most of it is personal preference, or depends on what is important for your project.
Often, there are two ways to assemble a new genome. One uses an already established reference genome to build off of. The advantage here is that your reads can be incomplete, and you will still get a good assembly because the reference 'fills in' the potential gaps in your reads. The disadvantage here is that you inherently create a 'Reference bias'. If you want to do variant calling for example, you will inherently miss variation since your assemblies will be 'pulled' to your reference.
The second is called a _de novo_ assembly. This means you do not use a previous reference, and is preferred when trying to compare genetic variation between assemblies.

## Basecalling & QC
When you get your raw sequencing data, they are possibly in .pod5 format. This means they are not basecalled yet. You can do this using Guppy or Dorabo basecaller. Luckily when using a minION of a Flongle, usually you get opd5 files, but also fastq files already.
If you have fastq-files as well, proceed to the next steps. This fastq format gives the sequence as well as the quality for each base. Usually, quality below Q = 10 (10% chance of basecall being wrong) are not used, Q = 40 is seen as very good (0.01% chance of basecall being wrong)
For the assembly itself, you don't need the fastq files, fasta is enough. However, generating the fastq files is a good way to quality check the data you generated.
You can use Nanoplot to visualize the quality using your fastq files (https://github.com/wdecoster/NanoPlot).

Use Quality_check.sl to generate a table of commonly used quality scores for each barcode.

## Cleanup of data
If you have the luxury, discarding the shortest reads is a good idea. for the minION, reads below 1000 bp are automatically discarded. 
No need to go over 50x coverage. If you are over 50x, you can discard shorter reads until you have 50x. Higher coverage just leads to longer processing times without improved quality.
When you have several fastq, fasta, etc files of the same barcode or sample, you can concatenate them for easier processing.

If there are barcodes, adaptor sequences, etc present in your data, you need to use Porechop before further processing the reads. 
Use the Merge_Porechop.sl script to concatenate all files of a single barcode (or sample) and cut off the barcode from each.

## Haplotype phasing
If you have a diploid (or higher n) genome, you can do haplotype phasing beforehand. This guide will not go over that specifically since I work with haploid sequences.

### Assemblies using a reference


## _De novo_ assemblies
### Flye
Flye is a _de novo_ genome assembler, which means there is no reference sequence required. It works well with genomes that have a lot of repeats, which makes it a good choice to work with plant genomes. 
Run Flye.sl to make a genome assembly. You can adjust the expected genome size, the max coverage, and should indicate which type of data you have (ONT vs PacBio).

### Hifiasm
Hifiasm is used for PacBio reads, and should not be used for ONT. ONT has a higher error-rate, which is not something Hifiasm is tailored to do. 
Run Hifiasm.sl to make a genome assembly.

### Miniasm
Miniasm is a lot like hifiasm, but this one is tailored to work with ONT. 


