#!/bin/bash

OUTDIR=packagelists
OUTFILE=$OUTDIR/common.package.list
NODELIST=$(sinfo -lN | tail -n +3 | awk '{print $1}')

# Get the packages installed on every node

mkdir -p $OUTDIR

for node in $NODELIST; do
    echo Getting packages for node $node...

    # Package list filename.
    packagelist=$OUTDIR/node.${node}.package.list

    # Check if node is fully allocated before submitting the job to get the
    # packagelist, so the job doesn't sit in the queue.
    nodestate=$(sinfo -lN | grep $node | awk '{print $4}')
    if [ "$nodestate" = "allocated" ]; then
        echo $node is fully allocated and will not respond to getting the \
            packagelist if we request now.
        if [ -f $packagelist ]; then
            echo There is an old package list for $node in \
                ${node}.package.list, using that instead.
        else
            echo No old packagelist found, will skip this node when computing \
                the common packagelist.
        fi
    else
        # Use minimum resources to get the packagelist from the node
        srun -c 1 --mem=1G --nodelist=$node -J pkglist \
            dpkg --get-selections 2>/dev/null | awk '{print $1}' | \
            awk -F":" '{print $1}' > $packagelist
    fi
done

# Compute the common packagelist

echo Computing the common package list as the intersection of the packages \
    installed on all nodes...

common_tmp=`mktemp`
cat $OUTDIR/node.*.package.list | sort -u > $common_tmp

for packagelist in $OUTDIR/node.*.package.list; do
    common_tmp_new=`mktemp`

    sort $packagelist $common_tmp | uniq -d > $common_tmp_new

    rm $common_tmp
    common_tmp=$common_tmp_new
done

mv $common_tmp $OUTFILE

NUM_COMMON_PACKAGES=`wc -l < $OUTFILE`
echo We detected $NUM_COMMON_PACKAGES packages which were installed on all \
    nodes in the cluster. When installing packages for lmod, these \
    dependencies can be safely ignored.
echo Common package list is available in $OUTFILE
