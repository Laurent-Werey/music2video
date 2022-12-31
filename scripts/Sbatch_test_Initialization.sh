#!/bin/bash
##SBATCH --ntasks=1
##SBATCH --cpus-per-task=4
##SBATCH -t 96:00:00
##SBATCH --gres=gpu:2
##SBATCH --constraint="gpua100|gpurtx6000|gpurtx5000|gpuv100|gpu1080|gpup100"
##SBATCH -p grantgpu
##SBATCH  -p publicgpu
##SBATCH -A g2021a270g


#SBATCH --cpus-per-task=40
#SBATCH --qos=qos_gpu-t4
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH -A udm@v100
module purge

module load pytorch-gpu/py3/1.2.0

conda activate cdps_new


label=$1
dataset=$2
Outdir=$3
dataPath=$4
logdir=$5
min_shapelet_length=0.15
ratio_n_shapelets=10
shapelet_max_scale=3
Imp=$6
Alldata=$7
disable_cuda="" #"--disable_cuda "
cuda_ID=""
zNormalize="--zNormalize"

CodeRootPath=/linkhome/rech/genbtn01/ukg44df/hussein_code

cd ${CodeRootPath}/bin/

echo python3 ${CodeRootPath}/bin/Train_CLDPS_pytorch.py ${Outdir} ${dataset} ${dataPath} --InitShapeletsBeta --Imp ${Imp} --min_shapelet_length ${min_shapelet_length} --ratio_n_shapelets ${ratio_n_shapelets} --shapelet_max_scale ${shapelet_max_scale} ${Alldata} ${disable_cuda} ${Savescore}

python3 ${CodeRootPath}/bin/Train_CLDPS_pytorch.py ${Outdir} ${dataset} ${dataPath} --InitShapeletsBeta \
--Imp ${Imp} \
--min_shapelet_length ${min_shapelet_length} --ratio_n_shapelets ${ratio_n_shapelets} --shapelet_max_scale ${shapelet_max_scale} \
${Alldata} ${disable_cuda} ${Savescore} ${zNormalize}

 #>> ${logdir}/${label}/I_${dataset}.log  2>&1

cd ..