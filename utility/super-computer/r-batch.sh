#!/bin/bash
#
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=1024
#SBATCH --output=r_output.txt
#SBATCH --error=r_error.txt
#SBATCH --time=12:00:00
#SBATCH --job-name=jobname
#SBATCH --mail-user=youremailaddress@yourinstitution.edu
#SBATCH --mail-type=ALL
#SBATCH --chdir=/home/yourusername/directory_to_run_in
#
#################################################
module load R
Rscript helloworld.r > output.txt
