#!/bin/sh
# Run this to generate all the initial makefiles, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

ORIGDIR=`pwd`
cd $srcdir
PROJECT=realmd
TEST_TYPE=-f
FILE=service/realm-daemon.c

# Some boiler plate to get git setup as expected
if test -d .git; then
	if test -f .git/hooks/pre-commit.sample && \
	   test ! -f .git/hooks/pre-commit; then
		cp -pv .git/hooks/pre-commit.sample .git/hooks/pre-commit
	fi
fi

(autoreconf --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "You must have autoconf installed to compile $PROJECT."
	echo "Install the appropriate package for your distribution,"
	echo "or get the source tarball at http://ftp.gnu.org/gnu/autoconf/"
	exit 1
}

test $TEST_TYPE $FILE || {
	echo "You must run this script in the top-level $PROJECT directory"
	exit 1
}

# NOCONFIGURE is used by gnome-common; support both
if ! test -z "$AUTOGEN_SUBDIR_MODE"; then
    NOCONFIGURE=1
fi

if test -z "$NOCONFIGURE"; then
        if test -z "$*"; then
                echo "I am going to run ./configure with no arguments - if you wish "
                echo "to pass any to it, please specify them on the $0 command line."
        fi
fi

rm -rf autom4te.cache

# README and INSTALL are required by automake, but may be deleted by clean
# up rules. to get automake to work, simply touch these here, they will be
# regenerated from their corresponding *.in files by ./configure anyway.
touch README INSTALL

autoreconf --verbose --force --install || exit $?

cd $ORIGDIR || exit $?

if test -z "$NOCONFIGURE"; then
        $srcdir/configure --enable-maintainer-mode $AUTOGEN_CONFIGURE_ARGS "$@" || exit $?

        echo 
        echo "Now type 'make' to compile $PROJECT."
fi
