#!/bin/bash

#SBATCH --job-name=Quality_check
#SBATCH --clusters=doduo
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=2:0:0
#SBATCH --mem=4G
#SBATCH --mail-user=Your@email.be
#SBATCH --mail-type=FAIL,END
#SBATCH --error=Quality_%j.err
#SBATCH --output=Quality_%j.out
# Usage: sbatch Quality_check.sl /path/to/demuxed_folder

if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/demuxed_folder"
  exit 1
fi

# Check if seqkit is available
if ! command -v seqkit &> /dev/null; then
  echo "Error: seqkit not found in PATH. Please install or load it first."
  exit 1
fi

DEMUX_DIR="$1"

echo -e "Barcode\tReads\tMean_Length\tN50\tMean_Q"

for barcode_dir in "$DEMUX_DIR"/barcode*/; do
  # Proper use of find with -o requires parentheses
  fastq_file=$(find "$barcode_dir" \( -name "*.fastq" -o -name "*.fastq.gz" \) | head -n 1)

  [ -z "$fastq_file" ] && continue

  # Get stats using seqkit
  stats=$(seqkit stats "$fastq_file" | awk 'NR==2 {print $4, $5, $6}')
  read_count=$(echo "$stats" | cut -d' ' -f1)
  mean_len=$(echo "$stats" | cut -d' ' -f2)
  n50=$(echo "$stats" | cut -d' ' -f3)

  # Estimate mean Q-score
  mean_q=$(awk '
    NR % 4 == 0 {
      for (i = 1; i <= length($0); i++) {
        sum += ord(substr($0, i, 1)) - 33;
        count++;
      }
    }
    END {
      if (count > 0) printf "%.2f", sum / count;
      else print "0";
    }
    function ord(c) {
      return index(" !\"#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", c)
    }
  ' "$fastq_file")

  barcode_name=$(basename "$barcode_dir")
  echo -e "${barcode_name}\t${read_count}\t${mean_len}\t${n50}\t${mean_q}"
done
