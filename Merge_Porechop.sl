#!/bin/bash -l

#SBATCH --job-name=concat_porechop
#SBATCH --clusters=doduo
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=12:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --mail-user=Your@email.be
#SBATCH --mail-type=FAIL,END
#SBATCH --output=concat_porechop_%j.txt
#SBATCH --error=concat_porechop_%j.err

module purge
module load Perl/5.36.0-GCCcore-12.2.0
module load Porechop/0.2.4-GCCcore-11.3.0

# === Input: Parent directory containing barcode folders ===
INPUT_DIR="$1"

if [ -z "$INPUT_DIR" ]; then
  echo "Usage: $0 /path/to/demuxed_fastq/"
  exit 1
fi

# === Loop through each barcode directory ===
for barcode_dir in "$INPUT_DIR"/barcode*/; do
  barcode=$(basename "$barcode_dir")
  combined_fastq="${barcode_dir}/${barcode}.combined.fastq.gz"
  trimmed_fastq="${barcode_dir}/${barcode}.porechopped.fastq.gz"

  echo "Processing $barcode..."

  # === Concatenate all fastq.gz files into one ===
  echo "Merging FASTQ.GZ files for $barcode into $combined_fastq"
  zcat "$barcode_dir"*.fastq.gz | gzip > "$combined_fastq"

  # === Delete original fastq.gz files (except the combined one) ===
  echo "Deleting original FASTQ.GZ files for $barcode"
  find "$barcode_dir" -type f -name "*.fastq.gz" ! -name "$(basename "$combined_fastq")" -delete

  # === Run Porechop on the combined file ===
  echo "Running Porechop for $barcode"
  porechop -t $SLURM_CPUS_PER_TASK -i "$combined_fastq" -o "$trimmed_fastq"

  echo "Finished processing $barcode"
  echo "--------------------------------------"
done
