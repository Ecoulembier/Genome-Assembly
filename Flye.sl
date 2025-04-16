#!/bin/bash -l

#SBATCH --job-name=assembly_flye
#SBATCH --clusters=gallade
###  SBATCH --ntasks=18
#SBATCH --nodes=1
#SBATCH --time=72:0:0
#SBATCH --mem=140G
#SBATCH --mail-user=Your@email.be
#SBATCH --mail-type=FAIL,END
#SBATCH --output assembly_flye_%j.txt
#SBATCH --error assembly_flye_%j.err

module load Flye/2.9.3-GCC-10.3.0
module load minimap2/2.24-GCCcore-11.3.0

module list

nano=$1 #Path/to/fasta/reads
base=`basename $nano .fasta`
outDir='FLYE_output_'${base}'_'${SLURM_JOB_ID}

cmd="flye --asm-coverage 50 --genome-size 100M --debug --threads $SLURM_CPUS_PER_TASK --iterations 4 --nano-raw $nano --out-dir $outDir "
echo $cmd
eval $cmd
