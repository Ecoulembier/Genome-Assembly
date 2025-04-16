#!/bin/bash -l

#SBATCH --job-name=assembly_miniasm
#SBATCH --clusters=gallade
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=36:0:0
#SBATCH --mem=140G
#SBATCH --mail-user=emcou@psb.ugent.be
#SBATCH --mail-type=FAIL,END
#SBATCH --output assembly_miniasm_%j.txt
#SBATCH --error assembly_miniasm_%j.err

module purge
module load miniasm/0.3-20191007-GCCcore-12.3.0
module load minimap2/2.26-GCCcore-12.3.0

module list

nano=$1 
base=`basename $nano .fastq`
outDir='MINIASM_output_'${base}'_'${SLURM_JOB_ID}


mkdir -p $outDir

cmd="minimap2 -x ava-ont -t 16 $nano $nano > overlaps.paf
cmd="miniasm -f $nano overlaps.paf > miniasm.${SLURM_JOB_ID}.gfa "
echo $cmd
eval $cmd

awk '/^S/{print ">"$2"\n"$3}' $outDir/${base}.gfa > $outDir/${base}.fasta
assembly-stats ./$outDir/${base}.fasta


