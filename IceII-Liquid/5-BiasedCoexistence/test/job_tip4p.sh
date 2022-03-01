#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1      # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --time=0:30:00         # total run time limit (HH:MM:SS)
#SBATCH --partition=debug
#SBATCH --job-name="COEX-ICEII" 
#SBATCH -A SLC103
set -e


export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export PLUMED_NUM_THREADS=$SLURM_CPUS_PER_TASK

pwd; hostname; date
module load fftw openmpi


############################################################################
# Variables definition
############################################################################
export LAMMPS_EXE=/home/sbore/software/mbx_lammps_plumed/lammps/src/lmp_mpi_mbx

cycles=2
threads_per_partition=2
############################################################################
 
############################################################################
# Run
############################################################################

pwd


for NMPI in 1 2 4 8 16 32
do
    let OMP=32/$NMPI
    export OMP_NUM_THREADS=$OMP
    export PLUMED_NUM_THREADS=$OMP
    let NMPI_TOT=4*$NMPI
    srun -n $NMPI_TOT $LAMMPS_EXE -sf omp -partition 4x$NMPI -in start.lmp
    cp log.lammps.0 log2_${NMPI}_${OMP}
done
# cycles=1
# partitions=1
# ############################################################################

# ############################################################################
# # Run
# ############################################################################
# if [ -e runno ] ; then
#    #########################################################################
#    # Restart runs
#    #########################################################################
#    nn=`tail -n 1 runno | awk '{print $1}'`
#    srun $LAMMPS_EXE -sf omp -partition 4x32 -in Restart.lmp
#    #########################################################################
# else
#    #########################################################################
#    # First run
#    #########################################################################
#    nn=1
#    # Number of partitions
#    srun $LAMMPS_EXE -sf omp -partition 4x32 -in start.lmp
#    #########################################################################
# fi
# ############################################################################

# ############################################################################
# # Prepare next run
# ############################################################################
# # Back up
# ############################################################################
# for j in $(seq 0 3)
# do
#         cp log.lammps.${j} log.lammps.${j}.${nn}
#         cp restart2.lmp.${j} restart2.lmp.${j}.${nn}
#         cp restart.lmp.${j} restart.lmp.${j}.${nn}
#         cp data.final.${j} data.final.${j}.${nn}
# done
# ############################################################################

# ############################################################################
# # Check number of cycles
# ############################################################################
# mm=$((nn+1))
# echo ${mm} > runno
# #cheking number of cycles
# if [ ${nn} -ge ${cycles} ]; then
#   exit
# fi
# ############################################################################
