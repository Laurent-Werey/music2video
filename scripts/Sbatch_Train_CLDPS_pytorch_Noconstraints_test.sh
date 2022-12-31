#!/bin/bash
#SBATCH --cpus-per-task=40
#SBATCH --qos=qos_gpu-t4
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH -A udm@v100

# Training on Noconstraints set
# If the code works fine, please change it is name to: Sbatch_Train_CLDPS_pytorch_Noconstraints.sh

module purge

module load pytorch-gpu/py3/1.2.0

conda activate cdps_new

label=$1
dataset=$2
Outdir=$3
dataPath=$4
logdir=$5
Imp=$6
Alldata=$7
bsize=32
bCsize=8
learning_rate=0.01
min_shapelet_length=0.15
ratio_n_shapelets=10
shapelet_max_scale=3
citer="" 
Savescore="--Savescore" #"" if you don't want to save clustering tests
disable_cuda="" #"--disable_cuda " #"" if you don't want cuda
cuda_ID=0
nkiter=500
ple=5
checkptsaveEach=50
zNormalize="--zNormalize"
LoadInitShapeletsBeta=$(echo ${Outdir}/${Imp}/${dataset}/InitialzationModel)

#Constraintsdir=${dataPath}/NN_Constraints
dataPath=${dataPath}/Multivariate_ts

CodeRootPath=/linkhome/rech/genbtn01/ukg44df/hussein_code
cd ${CodeRootPath}/bin/ 

echo python3 ${CodeRootPath}/bin/Train_CLDPS_pytorch.py ${Outdir} ${dataset} ${dataPath} --Imp ${Imp} --ple ${ple} --min_shapelet_length ${min_shapelet_length} --ratio_n_shapelets ${ratio_n_shapelets} --shapelet_max_scale ${shapelet_max_scale} --nkiter ${nkiter} --bsize ${bsize} --learning_rate ${learning_rate} --LoadInitShapeletsBet ${LoadInitShapeletsBeta} --checkptsaveEach ${checkptsaveEach}  ${Savescore} ${Alldata} ${disable_cuda} ${citer}

python3 ${CodeRootPath}/bin/Train_CLDPS_pytorch.py ${Outdir} ${dataset} ${dataPath} \
--Imp ${Imp} --ple ${ple} --min_shapelet_length ${min_shapelet_length} --ratio_n_shapelets ${ratio_n_shapelets} \
--shapelet_max_scale ${shapelet_max_scale} --nkiter ${nkiter} --bsize ${bsize} --learning_rate ${learning_rate} \
--LoadInitShapeletsBet ${LoadInitShapeletsBeta} --checkptsaveEach ${checkptsaveEach} \
 ${Savescore} ${ReSavescore} ${Alldata} ${disable_cuda} ${citer} ${zNormalize}\

cd ..