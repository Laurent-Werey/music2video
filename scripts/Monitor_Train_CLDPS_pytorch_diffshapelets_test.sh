#!/bin/bash
. job_scripts/functions.sh

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
logdirname=DiffShapelets
logdir=${logBasePath}/${logdirname}

mkdir -p logdir

errorBasePath=${RootPathOut}/errors
errordirname=DiffShapelets
errordir=${errorBasePath}/${errordirname}

mkdir -p errordir

typeoftrain=DiffShapelets

Imp=MUL
Alldata="--Alldata"
gpu=v100-32g

module purge
module load tensorflow-gpu/py3/2.5.0

echo Monitoring diffConstraints started at $(date) \(press \'q\' to quit, or \'p\' to pause\)

cd ${scriptdir}
min_shapelet_length=0.15

while true; do
	jobs=($(find ${logdir} -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
	#echo ${jobs[@]}

	for label in "${jobs[@]}"; do
	        echo ${label}
	        highestrunoutfile=$(find_current_run ${logdir} ${label})
	        if [ -n "${highestrunoutfile}" ]
	         then
	                
	            #echo ${highestrunoutfile}
	            jobid="$(< ${highestrunoutfile}.id)"
	            #echo ${jobid}

	            curqueue="$(squeue -o "%i" --user ${USER} | grep ${jobid} | wc -l)"
	            #echo ${curqueue}

	            echo python Check_Finished_Training.py ${Outdir} ${label} ${Imp} ${typeoftrain} ${Alldata}
	            python Check_Finished_Training.py ${Outdir} ${label} ${Imp} ${typeoftrain} ${Alldata}
	            finishedtraining=$?

	            echo Finshed Training Flag:  ${finishedtraining}

	            if [[ ${curqueue} -eq 0 ]] && [ ${finishedtraining} -eq 0 ]
	            then

	                    outfile=$(find_next_run ${logdir} ${label})
	                    labelsplit=(${label//_/ })
	                    dataset=${labelsplit[1]}
	                    ratio_n_shapelets=${labelsplit[2]}
	                    shapelet_max_scale=${labelsplit[3]}
                        f="$(basename -- $outfile)"
	    	    		mkdir -p ${errordir}/${label}
    	    			errorfile=${errordir}/${label}/${f}

	                    echo sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${min_shapelet_length} ${ratio_n_shapelets} ${shapelet_max_scale} ${Alldata} 
	                    RES=$(sbatch --job-name=${label} --output=${outfile}.out --error=${errorfile}.out -C${gpu} ${scriptdir}/${scriptname} ${label} ${dataset} ${Outdir} ${dataPath} ${logdir} ${Imp} ${min_shapelet_length} ${ratio_n_shapelets} ${shapelet_max_scale} ${Alldata})
	                    echo ${RES}
	                    [ -e ${outfile}.id ] && rm ${outfile}.id
	                    echo ${RES##* } > ${outfile}.id

	                echo Restarted job ${label} at $(date)
	                wait $!

	            fi

	        fi
	done
	
    read -t 60 -N 1 input
    if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
        echo
        echo Monitoring stopped at $(date)
        break
    fi
    if [[ $input = "p" ]] || [[ $input = "P" ]]; then
        pausetime=$(date)
        while [[ ! $input = "c" ]]
        do
            echo
            read -p "Monitoring paused at ${pausetime} - waiting until 'c' is pressed... " -N 1 input
        done
        echo
        echo Monitoring resumed at $(date)
    fi

done