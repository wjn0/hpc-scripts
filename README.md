# hpc-scripts

## lmod-related

### building packages

First, get up-to-date package lists for every node in the cluster:

    $ ./script/check_common_packages.sh

Then, you can build any Ubuntu package into a fake pkgroot:

    $ ./script/build_lmod_package.sh python3.7

## validation-related

### gpu allocation

This tests whether GPUs are properly (in)visible:

    $ ./script/test_gpu.sh

Note: currently test 1 fails - cgroups needs to be implemented.
