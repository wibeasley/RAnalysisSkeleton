#!/bin/bash
#
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=1024
#SBATCH --output=utility/super-computer/output/hello.txt
#SBATCH --error=utility/super-computer/error/hello.txt
#SBATCH --time=00:10:00
#SBATCH --job-name=scug-hello
#SBATCH --mail-user=youremailaddress@ouhsc.edu
#SBATCH --mail-type=ALL
#SBATCH --chdir=/home/yourusername/RAnalysisSkeleton
#
#################################################
module load R/3.5.1-intel-2016a
Rscript utility/super-computer/hello-world.R > utility/super-computer/output/hello-direct.txt
