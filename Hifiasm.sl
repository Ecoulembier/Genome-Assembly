#!/bin/bash -l

#SBATCH --job-name=assembly_hifiasm
#SBATCH --clusters=gallade
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --time=36:00:00
#SBATCH --mem=140G
#SBATCH --mail-user=Your@email.be
#SBATCH --mail-type=FAIL,END
#SBATCH --output=assembly_hifiasm_%j.txt
#SBATCH --error=assembly_hifiasm_%j.err

module purge
module load Hifiasm/0.18.5-GCCcore-11.3.0 #Or load correct version
module list

# === Input ===
reads="$1"
base=$(basename "$reads" .fastq)
base=$(basename "$base" .fasta)
outDir="HIFIASM_output_${base}_${SLURM_JOB_ID}"
mkdir -p "$outDir"

# === Run Hifiasm in default mode ===
cmd="hifiasm -t $SLURM_CPUS_PER_TASK -o $outDir/${base} $reads"
echo "Running command:"
echo "$cmd"
eval "$cmd"

# === Extract primary contigs (for haploid assembly) ===
if [ -f "$outDir/${base}.p_ctg.gfa" ]; then
    awk '/^S/{print ">"$2"\n"$3}' "$outDir/${base}.p_ctg.gfa" > "$outDir/${base}.fasta"
    echo "Primary contigs written to: $outDir/${base}.fasta"
fi
