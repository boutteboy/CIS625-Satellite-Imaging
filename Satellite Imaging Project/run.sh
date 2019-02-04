#!/bin/bash

#Prompt before setting up the environment
echo "About to setup R environment (Press Enter to continue)"
read -s

#Setup the R environment with the required packages
./env_setup.sh

#Prompt before deleting old data
echo "About to delete the old results (Press Enter to continue)"
read -s

#Clear out previous results so the new results we be the only 
rm Output/*
rm Results/*
rm Rplots.pdf

#Prompt before creating submit script
echo "About to create the submit script (Press Enter to continue)"
read -s

#Compile C program for good measure and to apply any changes
gcc -o setup setup.c

#Run the program to generate the job submit script
./setup Data

#Prompt before submitting the jobs
echo "About to submit jobs to Beocat (Press Enter to continue)"
read -s

#Run the created job submit script to submit the jobs
./ndvi_sbatch.sh