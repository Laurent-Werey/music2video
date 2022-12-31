#!/bin/bash
# bash code to run the sensitivity tests

# source ~/home/anaconda3/bin/activate
# conda activate py38
source /home/elamouri/.conda/envs/pytorch_cdps/bin/activate pytorch_cdps

#To limit the number of scripts running in parallel
n_proc=1 # Number of processes to execute in parallel, -1 unlimited
trap "trap - SIGTERM && kill -- -$$ && exit" SIGINT SIGTERM EXIT
function limitjobs {
        if [ "${n_proc}" != "-1" ]
        then
        echo `jobs -rp`         
                while [ `jobs -rp | wc -l` -ge ${n_proc} ]
                do
                        sleep 10
                done
        fi
}

echo -e "\nGenerating constraints set from ground truth information\n\n"

Alldata="--Alldata"
overwrite="" #"--overwrite" to overwrite existing constraint files, "" to skip existing ones
fr_='--fr 0.05 --fr 0.15 --fr 0.25'
nfr=10

RootPath=/gpfsscratch/rech/udm/ukg44df
dataBasePath=${RootPath}/data_hussein
dataPath=${dataBasePath}/Multivariate_ts
Outdir=${dataBasePath}/NN_Constraints

Outdir=/shared/CDPS/NN_Constraints
dataPath=/shared/CDPS/Multivariate_ts

datasets=($(ls $dataPath))

datasets='ArticularyWordRecognition AtrialFibrillation BasicMotions Cricket Epilepsy ERing EthanolConcentration FaceDetection FingerMovements HandMovementDirection Handwriting Heartbeat Libras NATOPS PenDigits RacketSports SelfRegulationSCP1 SelfRegulationSCP2 StandWalkJump UWaveGestureLibrary'


CodeRootPath=/linkhome/rech/genbtn01/ukg44df/hussein_code
CodeRootPath=/shared/CDPS

cd ${CodeRootPath}/bin/ 
for dataName in ${datasets[@]}; do
        echo "Running on $dataName" 
        limitjobs
        { 
        python  ${CodeRootPath}/bin/GenerateConstraints.py ${Outdir} ${dataName} ${dataPath} ${fr_} ${Alldata} --nfr ${nfr} ${overwrite}
        } 
done


for j in `jobs -rp`; do
    wait $j
done

cd ..
