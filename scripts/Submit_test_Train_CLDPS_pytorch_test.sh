#!/bin/bash
. job_scripts/functions.sh


# Training on Different Constraint sets
# If the code works fine, please change it is name to: Submit_Train_CLDPS_pytorch_diffConstraints.sh

datasets="EthanolConcentration Libras Epilepsy BasicMotions MotorImagery FaceDetection UWaveGestureLibrary Handwriting PhonemeSpectra Heartbeat RacketSports Cricket AtrialFibrillation StandWalkJump FingerMovements NATOPS HandMovementDirection ArticularyWordRecognition"
#datasets="Heartbeat"

RootPath=/gpfsscratch/rech/udm/ukg44df

RootScriptPath=/linkhome/rech/genbtn01/ukg44df/hussein_code
scriptdir=${RootScriptPath}/scripts

scriptname=Sbatch_test_Train_CLDPS_pytorch_test.sh

dataBasePath=${RootPath}/data_hussein
dataPath=${dataBasePath}S

OutdirBasePath=${RootPath}/saved_models_hussein
Outdirname=models  #This is name of the base directory, I think we named it model, if not change it to the corret name, thanks
Outdir=${OutdirBasePath}/${Outdirname}

RootPathOut=${RootPath}/output_hussein
logBasePath=${RootPathOut}/logs
logdirname=LogDiffConstraitns
logdir=${logBasePath}/${logdirname}

mkdir -p logdir

errorBasePath=${RootPathOut}/errors
errordirname=errorDiffConstraints
errordir=${errorBasePath}/${errordirname}

mkdir -p errordir

#Parametrs
gpu=v100-32g
Alldata="--Alldata"
Imp="MUL"
fr_="0.05 0.15 0.25"
fr_="0.05"
nfr="0 1 2 3 4 5 6 7 8 9"
nfr="0"


for fr in ${fr_}; do
   for nf in ${nfr}; do   
      for dataset in $datasets; do
        label=DC_${dataset}_${fr}_${nf}
        outfile=$(find_next_run ${logdir} ${label})
        f="$(basename -- $outfile)"
        mkdir -p ${errordir}/${label}
        errorfile=${errordir}/${label}/${f}

        echo sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${fr} ${nf} ${Alldata}
        RES=$(sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${fr} ${nf} ${Alldata} )
        echo ${RES}

        [ -e ${outfile}.id ] && rm ${outfile}.id
        echo ${RES##* } > ${outfile}.id

      done
    done
done
