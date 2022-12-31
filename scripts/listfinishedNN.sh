#!/bin/bash
dpath=~/CDPS/TestingRunTrainData/MUL
type=alph*
datasets="Adiac BME Beef BirdChicken CBF Car Coffee CricketX CricketY CricketZ ECG200 MoteStrain FaceFour FiftyWords Fish Fungi GunPoint GunPointAgeSpan Herring Lightning2 Lightning7 Meat OSULeaf Plane PowerCons Symbols SyntheticControl Trace TwoPatterns ShapesAll SwedishLeaf ECG5000 ElectricDevices FaceAll FordA FordB Crop Mallat FacesUCR Wafer Rock ScreenType UWaveGestureLibraryX Phoneme"
for dataset in $datasets; do
        a=$(ls $dpath/$dataset/$type/**/Model/Final* |wc)
        echo $dataset $a
done
