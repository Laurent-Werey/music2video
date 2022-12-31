import os
import sys
import numpy as np
import argparse
from glob import glob


parser = argparse.ArgumentParser(prog='Cehck if model finished training')
parser.add_argument('Outdir',help='Outputdirectory where the model is saved and tests', type=str)
parser.add_argument('label',help='Label specifying the type of the training and the paramters', type=str)
parser.add_argument('Imp',help='Python implementation type MUL or SING', type=str)
parser.add_argument('typeoftrain',help='with or without constraints')
parser.add_argument('--Alldata', dest='Alldata', help='Use test and train for training', default=False, action='store_true')

args=parser.parse_args()

if args.typeoftrain == "DiffConstraints":
	#DCon_GunPoint_{fr}_{nfr}
	label  = args.label.split('_')
	DataName=label[1]
	alpha,gamma=2.5,2.5
	fr, nfr = float(label[2]), int(label[3])
	min_shapelet_length, shapelet_max_scale, ratio_n_shapelets = 0.15, 3, 10
	Outdir = f'{args.Outdir}/{args.Imp}/{DataName}/alpha_{alpha}_gamma_{gamma}_fr_{fr:.2f}_nfr_{nfr}/lmin_{min_shapelet_length}_shapelet_max_scale_{shapelet_max_scale}_ratio_n_shapelets_{ratio_n_shapelets}'
	if not os.path.exists(f'{Outdir}'):
		print(f"specified directory doesn't exit, are you sure of the parameters.\n{Outdir}")
		sys.exit(0)
	elif not os.path.exists(f'{Outdir}/Model'):
		print("Model Dir does not exist. Need to start training from scratch")
		sys.exit(0)
	else:
		#FinalModel=f'{Outdir}/Model/Final_model_cuda_False_Alldata_{args.Alldata}.model'
		FinalModel=glob(f'{Outdir}/Model/F*')
		if len(FinalModel) != 0:
			if os.path.exists(FinalModel[0]):
				print(f'The final model exist skipping training')
				sys.exit(1)
		else:
			print(f"Final Model does't exist relauch training")
			print(f'{DataName} DiffConstraints {fr} {nfr}')
			sys.exit(0)

elif args.typeoftrain == "NoConstraitns":
	label  = args.label.split('_')
	DataName=label[1]
	min_shapelet_length, shapelet_max_scale, ratio_n_shapelets = 0.15, 3, 10
	Outdir = f'{args.Outdir}/{args.Imp}/{DataName}/Noconstraints/lmin_{min_shapelet_length}_shapelet_max_scale_{shapelet_max_scale}_ratio_n_shapelets_{ratio_n_shapelets}'
	if not os.path.exists(f'{Outdir}'):
		print(f"specified directory doesn't exit, are you sure of the parameters.\n{Outdir}")
		sys.exit(0)
	elif not os.path.exists(f'{Outdir}/Model'):
		print("Model Dir does not exist. Need to start training from scratch")
		sys.exit(0)
	else:
		#FinalModel=f'{Outdir}/Model/Final_model_cuda_False_Alldata_{args.Alldata}.model'
		FinalModel=glob(f'{Outdir}/Model/F*')
		if len(FinalModel) != 0:
			if os.path.exists(FinalModel[0]):
				print(f'The final model exist skipping training')
				sys.exit(1)
		else:
			print(f"Final Model does't exist relauch training")
			print(f'{DataName} with NoConstraints')
			sys.exit(0)


elif args.typeoftrain == "DiffAlphaGamma":
	#label=DAG_${dataset}_${alpha}_${gamma}
	label  = args.label.split('_')
	DataName=label[1]
	alpha=label[2]
	gamma=label[3]
	fr, nfr = 0.25, 0
	min_shapelet_length, shapelet_max_scale, ratio_n_shapelets = 0.15, 3, 10
	Outdir = f'{args.Outdir}/{args.Imp}/{DataName}/alpha_{alpha}_gamma_{gamma}_fr_{fr:.2f}_nfr_{nfr}/lmin_{min_shapelet_length}_shapelet_max_scale_{shapelet_max_scale}_ratio_n_shapelets_{ratio_n_shapelets}'
	if not os.path.exists(f'{Outdir}'):
		print(f"specified directory doesn't exit, are you sure of the parameters.\n{Outdir}")
		sys.exit(0)
	elif not os.path.exists(f'{Outdir}/Model'):
		print("Model Dir does not exist. Need to start training from scratch")
		sys.exit(0)
	else:
		#FinalModel=f'{Outdir}/Model/Final_model_cuda_False_Alldata_{args.Alldata}.model'
		FinalModel=glob(f'{Outdir}/Model/F*')
		if len(FinalModel) != 0:
			if os.path.exists(FinalModel[0]):
				print(f'The final model exist skipping training')
				sys.exit(1)
		else:
			print(f"Final Model does't exist relauch training")
			print(f'{DataName} with DiffAlphaGamma {alpha} {gamma}')
			sys.exit(0)
elif args.typeoftrain == "DiffShapelets":
	#label=DAG_${dataset}_${alpha}_${gamma}
	label  = args.label.split('_')
	DataName=label[1]
	ratio_n_shapelets=label[2]
	shapelet_max_scale=label[3]
	fr, nfr = 0.25, 0
	min_shapelet_length, alpha, gamma = 0.15, 2.5, 2.5
	Outdir = f'{args.Outdir}/{args.Imp}/{DataName}/alpha_{alpha}_gamma_{gamma}_fr_{fr:.2f}_nfr_{nfr}/lmin_{min_shapelet_length}_shapelet_max_scale_{shapelet_max_scale}_ratio_n_shapelets_{ratio_n_shapelets}'
	if not os.path.exists(f'{Outdir}'):
		print(f"specified directory doesn't exit, are you sure of the parameters.\n{Outdir}")
		sys.exit(0)
	elif not os.path.exists(f'{Outdir}/Model'):
		print("Model Dir does not exist. Need to start training from scratch")
		sys.exit(0)
	else:
		#FinalModel=f'{Outdir}/Model/Final_model_cuda_False_Alldata_{args.Alldata}.model'
		FinalModel=glob(f'{Outdir}/Model/F*')
		if len(FinalModel) != 0:
			if os.path.exists(FinalModel[0]):
				print(f'The final model exist skipping training')
				sys.exit(1)
		else:
			print(f"Final Model does't exist relauch training")
			print(f'{DataName} with DiffShapelets {ratio_n_shapelets} {shapelet_max_scale}')
			sys.exit(0)
