#!/usr/bin/env bash

unset CDPATH

# http://www.praveen.life/2016/06/26/compile-ffmpeg-for-raspberry-pi-3/

function logout1
{
    :
    # echo $*
}

function getSourceDirectoryPath
{
    ScriptPath="${BASH_SOURCE[0]}"
    while [ -L "${ScriptPath}" ]; do # resolve ${ScriptPath} until the file is no longer a symlink
      TARGET="$(readlink "${ScriptPath}")"
      if [[ ${TARGET} == /* ]]; then
        logout1 "ScriptPath '${ScriptPath}' is an absolute symlink to '${TARGET}'"
        ScriptPath="${TARGET}"
      else
        DirectoryPathOfScript="$( dirname "${ScriptPath}" )"
        logout1 "ScriptPath '${ScriptPath}' is a relative symlink to '${TARGET}' (relative to '${DirectoryPathOfScript}')"
        ScriptPath="${DirectoryPathOfScript}/${TARGET}" # if ${ScriptPath} was a relative symlink, we need to resolve it relative to the path where the symlink file was located
      fi
    done
    logout1 "ScriptPath is '${ScriptPath}'"
    RelativeDirectoryPathOfScript="$( dirname "${ScriptPath}" )"
    DirectoryPathOfScript="$( cd -P "$( dirname "${ScriptPath}" )" >/dev/null 2>&1 && pwd )"
    if [ "${DirectoryPathOfScript}" != "${RelativeDirectoryPathOfScript}" ]; then
      logout1 "DirectoryPathOfScript '${RelativeDirectoryPathOfScript}' resolves to '${DirectoryPathOfScript}'"
    fi
    logout1 "DirectoryPathOfScript is '${DirectoryPathOfScript}'"

    if [ -z "${ScriptPath}" ]; then
        printf "Couldn't get ScriptPath: %s\n" "${ScriptPath}"
    fi
    if [ -z "${DirectoryPathOfScript}" ]; then
        printf "Couldn't get DirectoryPathOfScript: %s\n" "${DirectoryPathOfScript}"
    fi
}

function installlibX264
{
    cd "${DirectoryPathOfScript}/${DependencyDirectory}"
    if [ -d "x264" ]; then
        git clone http://git.videolan.org/git/x264.git
        cd "${DirectoryPathOfScript}/${DependencyDirectory}/x264"
    else
        cd "${DirectoryPathOfScript}/${DependencyDirectory}/x264"
        git pull
        make clean
    fi
    ./configure --enable-static --prefix="${ScriptPath}/ffmpeg/${DependencyDirectory}/${DependencyOutputDirectory}/"
    make -j4
    make install
    cd "${DirectoryPathOfScript}/${DependencyDirectory}"
}

function installALSA
{
    cd "${DirectoryPathOfScript}/${DependencyDirectory}"
    if [ -d alsa-lib-1.1.1 ]; then
        wget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.1.tar.bz2
        tar xjf alsa-lib-1.1.1.tar.bz2
        cd "${DirectoryPathOfScript}/${DependencyDirectory}/alsa-lib-1.1.1/"
        ./configure --prefix=/home/pi/ffmpeg/dependencies/output
        make -j4
        make install
        cd "${DirectoryPathOfScript}/${DependencyDirectory}"
    fi
}

function installFDKAAC
{
    cd "${DirectoryPathOfScript}/${DependencyDirectory}"
    if [ -d "fdk-aac" ]; then
        git clone https://github.com/mstorsjo/fdk-aac.git
        cd "${DirectoryPathOfScript}/${DependencyDirectory}/fdk-aac"
    else
        cd "${DirectoryPathOfScript}/${DependencyDirectory}/fdk-aac"
        git pull
        make clean
    fi
    ./autogen.sh
    ./configure --enable-shared --enable-static
    make -j4
    make install
    ldconfig
    cd "${DirectoryPathOfScript}/${DependencyDirectory}"
}

function installFFmpeg
{
    cd "${DirectoryPathOfScript}"
    cd ..
    ./configure \
        --prefix="${ScriptPath}/ffmpeg/${DependencyDirectory}/${DependencyOutputDirectory}" \
        --enable-gpl --enable-libx264 --enable-nonfree --enable-libfdk_aac \
        --enable-omx --enable-omx-rpi \
        --extra-cflags="-I${ScriptPath}/ffmpeg/${DependencyDirectory}/${DependencyOutputDirectory}/include" \
        --extra-ldflags="-L${ScriptPath}/ffmpeg/${DependencyDirectory}/${DependencyOutputDirectory}/lib" \
        --extra-libs="-lx264 -lpthread -lm -ldl" \
    make -j4
    make install
}

DirectoryPathOfScript=""
ScriptPath=""
getSourceDirectoryPath

DependencyDirectory="dependencies"
DependencyOutputDirectory="output"

function createDirectoryIfNotExists
{
    if [ -d "$1" ]; then
        mkdir "${ScriptPath}/$1"
    fi
}

if [ -d "./ffmpeg" ]; then
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
fi
cd ffmpeg
createDirectoryIfNotExists "${DependencyDirectory}"
cd "${DependencyOutputDirectory}"
createDirectoryIfNotExists "${DependencyOutputDirectory}"

installlibX264

installALSA

installFDKAAC

apt-get -y install pkg-config autoconf automake libtool

installFFmpeg
