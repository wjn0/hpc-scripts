#!/bin/bash

# Validate arguments
if [ -z $1 ]; then
    echo "Usage:"
    echo "    $0 <package_name_or_names> [path_to_custom_package_list]"
    exit 1
else
    PACKAGENAME=$1
fi

if [ -z $2 ]; then
    COMMON_PACKAGELIST=packagelists/common.package.list
    if [ ! -f $COMMON_PACKAGELIST ]; then
        echo No common packagelist found at $COMMON_PACKAGELIST. You should \
            pass the path of one as an argument or put one there.
        exit 1
    fi
else
    COMMON_PACKAGE_LIST=$2
fi

# Make sure we can make a clean build directory
BUILDDIR=build_$PACKAGENAME

mkdir -p $BUILDDIR
if [ -d $BUILDDIR ]; then
    if [ ! -z "$(ls -A $BUILDDIR)" ]; then
        echo $BUILDDIR already exists and is non-empty, exiting...
        exit 1
    fi
fi
cd $BUILDDIR

# Fetch the dependency list

srun -c 1 --mem=1G --nodelist=lambda-server \
    apt-rdepends $PACKAGENAME 2>/dev/null | grep -v "^ " | \
    sort -u > all_dependencies

# "debconf-2.0" is always installed, it's just called "debconf"
comm -23 all_dependencies ../$COMMON_PACKAGELIST | \
    grep -v "debconf-2.0" > necessary_dependencies

echo Identified the following $(wc -l < necessary_dependencies) necessary \
    dependencies:

for depname in `cat necessary_dependencies`; do
    echo "    $depname"
done

# Download the .deb packages

read -p "Will now attempt to download all dependencies. Continue [y/N]? " -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo OK, leaving build directory $build_dir in place.
    exit 0 
fi

mkdir dependencies && cd dependencies

for depname in `cat ../necessary_dependencies`; do
    apt download $depname
done

cd ..

# Install the package and its dependencies to a local directory

mkdir pkgroot

for debfile in `ls dependencies`; do
    dpkg-deb -x dependencies/$debfile pkgroot || exit 2
done

cd ..

echo Built package. Root is $BUILDDIR/pkgroot
