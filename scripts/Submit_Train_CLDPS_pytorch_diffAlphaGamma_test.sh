#!/bin/bash
. job_scripts/functions.sh


# Training on Different AlphaGamma sets
# If the code works fine, please change it is name to: Sbatch_Train_CLDPS_pytorch_diffAlphaGamma.sh

datasets="EthanolConcentration Libras Epilepsy BasicMotions MotorImagery FaceDetection UWaveGestureLibrary Handwriting PhonemeSpectra Heartbeat RacketSports Cricket AtrialFibrillation StandWalkJump FingerMovements NATOPS HandMovementDirection ArticularyWordRecognition EigenWorms PenDigits PEMS-SF SelfRegulationSCP1 SelfRegulationSCP2 DuckDuckGeese LSST ERing"
#datasets="Heartbeat"

RootPath=/gpfsscratch/rech/udm/ukg44df

RootScriptPath=/linkhome/rech/genbtn01/ukg44df/hussein_code
scriptdir=${RootScriptPath}/scripts

scriptname=Sbatch_Train_CLDPS_pytorch_diffAlphaGamma_test.sh 

dataBasePath=${RootPath}/data_hussein
dataPath=${dataBasePath}

OutdirBasePath=${RootPath}/saved_models_hussein
Outdirname=models  #This is name of the base directory, I think we named it model, if not change it to the corret name, thanks
Outdir=${OutdirBasePath}/${Outdirname}

RootPathOut=${RootPath}/output_hussein
name=DiffAlphaGamma

logBasePath=${RootPathOut}/logs
logdir=${logBasePath}/${name}

errorBasePath=${RootPathOut}/errors
errordir=${errorBasePath}/${name}
 
mkdir -p logdir
mkdir -p errordir

#Parametrs
Alldata="--Alldata"
Imp="MUL"
gamma="0.25 0.5 0.75 1 1.25 1.5 1.75 2" 
gamma="0.25"
alpha="0.25 0.5 0.75 1 1.25 1.5 1.75 2"
alpha="0.25"
gpu=v100-32g

for a in $alpha; do
   for g in $gamma; do   
      for dataset in $datasets; do

        label=DAG_${dataset}_${a}_${g}
        outfile=$(find_next_run ${logdir} ${label})
        f="$(basename -- $outfile)"
        mkdir -p ${errordir}/${label}
        errorfile=${errordir}/${label}/${f}      

        echo sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${a} ${g} ${Alldata}
        RES=$(sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${a} ${g} ${Alldata})
        echo ${RES}
  
        [ -e ${outfile}.id ] && rm ${outfile}.id
        echo ${RES##* } > ${outfile}.id
      done
    done
done

