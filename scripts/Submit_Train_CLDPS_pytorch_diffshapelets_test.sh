#!/bin/bash
. job_scripts/functions.sh



# Training on different shapelets sets
# If the code works fine, please change it is name to: Submit_Train_CLDPS_pytorch_diffshapelets.sh

datasets="EthanolConcentration Libras Epilepsy BasicMotions MotorImagery FaceDetection UWaveGestureLibrary Handwriting PhonemeSpectra Heartbeat RacketSports Cricket AtrialFibrillation StandWalkJump FingerMovements NATOPS HandMovementDirection ArticularyWordRecognition EigenWorms PenDigits PEMS-SF SelfRegulationSCP1 SelfRegulationSCP2 DuckDuckGeese LSST ERing"
#datasets="Heartbeat"

RootPath=/gpfsscratch/rech/udm/ukg44df  

RootScriptPath=/linkhome/rech/genbtn01/ukg44df/hussein_code
scriptdir=${RootScriptPath}/scripts

scriptname=Sbatch_Train_CLDPS_pytorch_diffshapelets_test.sh 

dataBasePath=${RootPath}/data_hussein
dataPath=${dataBasePath}

OutdirBasePath=${RootPath}/saved_models_hussein
Outdirname=models  #This is name of the base directory, I think we named it model, if not change it to the corret name, thanks
Outdir=${OutdirBasePath}/${Outdirname}

RootPathOut=${RootPath}/output_hussein
logBasePath=${RootPathOut}/logs
name=DiffShapelets
logdirname=Log${name}
logdir=${logBasePath}/${logdirname}

mkdir -p logdir

errorBasePath=${RootPathOut}/errors
errordirname=error${name}
errordir=${errorBasePath}/${errordirname}
 
mkdir -p errordir

#Parametrs
Alldata="--Alldata"
Imp="MUL"
min_shapelet_length=0.15
ratio_n_shapelets="1 2 4 6 8 10"
shapelet_max_scale="2 3 4"
gpu=v100-32g

for rns in $ratio_n_shapelets; do     
   for sms in $shapelet_max_scale; do   
      for dataset in $datasets; do
        label=DS_${dataset}_${rns}_${sms}
        outfile=$(find_next_run ${logdir} ${label})
        f="$(basename -- $outfile)"
        mkdir -p ${errordir}/${label}
        errorfile=${errordir}/${label}/${f} 

        echo sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${min_shapelet_length} ${rns} ${sms} ${Alldata}
        RES=$(sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${min_shapelet_length} ${rns} ${sms} ${Alldata})
        echo ${RES}

        [ -e ${outfile}.id ] && rm ${outfile}.id
        echo ${RES##* } > ${outfile}.id
      done
    done
done

