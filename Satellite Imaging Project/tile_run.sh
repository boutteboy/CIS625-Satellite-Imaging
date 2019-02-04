#!/bin/bash

module load R

Rscript parallel_bfast.r $1 $2 20
