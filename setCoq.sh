#!/bin/sh

# The help menu
function print_short_help {
    echo "usage: setCoq.sh [-s directory] [-h]"
    echo "use --help or -h option for more details"
}

function print_help {
    echo "usage: setCoq.sh [-s directory] [-u] [-h]"
    echo "Description:"
    echo "  --set directory, -s directory"
    echo "    Set Coq to the given directory."
    echo "  --help, -h \n"
    echo "    To print this help."
}

# Parse input
# if no argument is specified print help
if [ $# == 0 ]; then
    print_short_help
    exit 0
fi

#initializing the options
ISSET=0
PTH=

# see if the requested operation is to set Coq or unset it
while [[ $# > 0 ]]; do
    key=$1
    case ${key} in
	--set|-s)
	    ISSET=1
	    PTH=$2
	    shift;;
	--help|-h)
	    print_help
	    exit 0;;
	*)
	    echo "Don't know what to do with $1"
	    print_short_help
	    exit 1;;
    esac
    shift
done

# We remove the last / if the argument ends in a /
if [ ${PTH: -1} == "/" ]; then
    COQP=${PTH:0:`expr ${#PTH} - 1`}
else
    COQP=${PTH}
fi

function setCoq {
    # Check if the given path is indeed a Coq directory
    if [ -d $1 ]; then
	if ! [ -x $1/bin/coqc ]; then
	    echo "Can't find the $1/bin/coqc file!"
	    exit 1
	fi
    else
	echo "The given apth $1 is not a directory!"
	exit 1
    fi

    for f in $1/bin/*; do
	if [ -f $f ]; then
	    targ=/usr/local/$(echo $f | sed "s|$1/||g")
	    if [ -f ${targ} ]; then
		if ! [ -L ${targ} ]; then
		    echo "Coq is permanently installed! Please remove first."
		    exit 1
		else
		    rm ${targ}
		fi
	    fi
	    ln -s ${f} ${targ}
	fi
    done
}


# if the request is to set Coq we set it.
if [ ${ISSET} == 1 ]; then
    setCoq ${COQP}
fi
