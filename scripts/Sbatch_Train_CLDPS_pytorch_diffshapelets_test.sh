#!/bin/bash
#SBATCH --cpus-per-task=40
#SBATCH --qos=qos_gpu-t4
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH -A udm@v100

# Training on Different Shapelets sets
# If the code works fine, please change it is name to: Sbatch_Train_CLDPS_pytorch_diffshapelets.sh


module purge

module load pytorch-gpu/py3/1.2.0

conda activate cdps_new

label=$1
dataset=$2
Outdir=$3
dataPath=$4
logdir=$5
Imp=$6
Alldata=${10}
min_shapelet_length=$(expr $7)
ratio_n_shapelets=$(expr $8)
shapelet_max_scale=$(expr $9)
echo min_shapelet_length ${min_shapelet_length} ratio_n_shapelets ${ratio_n_shapelets} shapelet_max_scale ${shapelet_max_scale} label ${label}
fr_=0.25
nfr=0
gamma=2.5
alpha=2.5
bsize=32
bCsize=8
learning_rate=0.01
citer="" 
Savescore="--Savescore" #"" if you don't want to save clustering tests
disable_cuda="" #--disable_cuda " #"" if you don't want cuda
cuda_ID=""
nkiter=500
ple=5
checkptsaveEach=10
zNormalize="--zNormalize"

#dataBasePath=${RootPath}/data_hussein
Constraintsdir=${dataPath}/NN_Constraints
dataPath=${dataPath}/Multivariate_ts

LoadInitShapeletsBeta="" #$(echo ${Outdir}/${Imp}/${dataset}/InitialzationModel)

CodeRootPath=/linkhome/rech/genbtn01/ukg44df/hussein_code
cd ${CodeRootPath}/bin/ 

python3 -c "import torch; print(f'torch version {torch.__version__}  ')"

echo python3 ${CodeRootPath}/bin/Train_CLDPS_pytorch.py ${Outdir} ${dataset} ${dataPath} --LoadInitShapeletsBeta ${LoadInitShapeletsBeta} --Imp ${Imp} --ple ${ple} --checkptsaveEach ${checkptsaveEach} --fr ${fr_} --nfr ${nfr} --gamma ${gamma} --alpha ${alpha}  --Constraints ${Constraintsdir} --min_shapelet_length ${min_shapelet_length} --ratio_n_shapelets ${ratio_n_shapelets} --shapelet_max_scale ${shapelet_max_scale} --bsize ${bsize} --bCsize ${bCsize} --nkiter ${nkiter} --learning_rate ${learning_rate} --cuda_ID ${cuda_ID} ${disable_cuda} ${Alldata} ${disable_cuda} ${Savescore} ${citer}

python3 ${CodeRootPath}/bin/Train_CLDPS_pytorch.py ${Outdir} ${dataset} ${dataPath} \
--LoadInitShapeletsBeta ${LoadInitShapeletsBeta} \
--Imp ${Imp} --ple ${ple} --checkptsaveEach ${checkptsaveEach} \
--fr ${fr_} --nfr ${nfr} --gamma ${gamma} --alpha ${alpha}  --Constraints ${Constraintsdir} \
--min_shapelet_length ${min_shapelet_length} --ratio_n_shapelets ${ratio_n_shapelets} --shapelet_max_scale ${shapelet_max_scale} \
--bsize ${bsize} --bCsize ${bCsize} \
--nkiter ${nkiter} --learning_rate ${learning_rate} \
${disable_cuda} \
${Alldata} ${disable_cuda} ${Savescore} ${ReSavescore} ${citer} ${zNormalize}\

cd ..