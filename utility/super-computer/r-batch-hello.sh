#!/bin/bash
#
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=2G
#SBATCH --output=utility/super-computer/output/hello.txt
#SBATCH --error=utility/super-computer/error/hello.txt
#SBATCH --time=00:10:00
#SBATCH --job-name=scug-hello
#SBATCH --mail-user=whb4@ou.edu
#SBATCH --mail-type=ALL
#SBATCH --chdir=/home/wbeasley/RAnalysisSkeleton
#
#################################################
module load R/4.0.2-foss-2020a

Rscript utility/super-computer/hello-world.R > utility/super-computer/output/hello-direct.txt
