# hpc-scripts

First, get up-to-date package lists for every node in the cluster:

    $ ./script/check_common_packages.sh

Then, you can build any Ubuntu package into a fake pkgroot:

    $ ./script/build_lmod_package.sh python3.7
