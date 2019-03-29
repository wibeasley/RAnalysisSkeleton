#!/bin/bash
#
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=1024
#SBATCH --output=utility/super-computer/r-output.txt
#SBATCH --error=utility/super-computer/r-error.txt
#SBATCH --time=12:00:00
#SBATCH --job-name=scug_hello_world
#SBATCH --mail-user=youremailaddress@ouhsc.edu
#SBATCH --mail-type=ALL
#SBATCH --chdir=/home/yourusername/RAnalysisSkeleton
#
#################################################
module load R/3.5.1-intel-2016a
Rscript utility/super-computer/hello-world.R > utility/super-computer/output.txt
