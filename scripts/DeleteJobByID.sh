#!/bin/bash
. job_scripts/functions.sh


RootPath=/gpfsscratch/rech/udm/ukg44df
RootPathOut=${RootPath}/output_hussein
logBasePath=${RootPathOut}/logs

logdirname=LogDiffConstraitns
logdir=${logBasePath}/${logdirname}

RootScriptPath=/linkhome/rech/genbtn01/ukg44df/hussein_code
scriptdir=${RootScriptPath}/scripts
cd  ${scriptdir}

jobs=($(find ${logdir} -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))

state=P #or R

for label in "${jobs[@]}"; do
	
	echo ${label}
	highestrunoutfile=$(find_current_run ${logdir} ${label})
	if [ -n "${highestrunoutfile}" ]
	then
		curqueue="$(squeue -o "%i %T" --jobs ${jobid} | grep ${state} | wc -l)"
		if [ ${curqueue} -eq 1]
		then
			echo Deleting: "$(squeue -o "%i %j %T %k" --jobs ${jobid} | grep ${jobid})"
			jobid="$(< ${highestrunoutfile}.id)"
			scancel ${jobid}
		fi
	fi
done
