#!/bin/bash

# This runs a small test "suite" against Slurm GPU allocation with the goal of
# preventing regressions in resource allocation.

TEST_NODE=ricreategpup1  # specify the node name here
N=2  # number of GPUs requested for the tests

#############################################################
# Test 1: if no GPUs are allocated, none should be visible. #
#############################################################

num_alloc=`srun -c 1 --mem=1G --nodelist=$TEST_NODE python3 -c \
               "import torch; print(torch.cuda.device_count())" | head -1`

if [ "$num_alloc" -eq "0" ]; then
    echo [PASS] Number of visible GPUs was 0, as expected.
else
    echo [FAIL] Expected number of GPUs allocated to be 0, but was $num_alloc!
fi

###########################################################
# Test 2: if $N GPUs are allocated, $N should be visible. #
###########################################################

num_alloc=`srun -c 1 --mem=1G --gres=gpu:$N --nodelist=$TEST_NODE python3 -c \
               "import torch; print(torch.cuda.device_count())" | head -1`

if [ $num_alloc -eq $N ]; then
    echo [PASS] Number of visible GPUs was $N, as expected.
else
    echo [FAIL] Expected number of GPUs allocated to be $N, but was $num_alloc!
fi
