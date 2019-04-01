#!/bin/bash
#
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=1024
#SBATCH --output=utility/super-computer/output/repo.txt
#SBATCH --error=utility/super-computer/error/repo.txt
#SBATCH --time=00:10:00
#SBATCH --job-name=scug-repo
#SBATCH --mail-user=youremailaddress@ouhsc.edu
#SBATCH --mail-type=ALL
#SBATCH --chdir=/home/yourusername/RAnalysisSkeleton
#
#################################################
module load Pandoc/2.5
module load R/3.5.1-intel-2016a

Rscript utility/reproduce.R > utility/super-computer/output/repo-direct.txt
