#!/bin/sh

set -e

S=${S:-/home/phk/Varnish/trunk/varnish-cache}
T=${T:-/home/phk/Varnish/trunk/varnish-cache/bin/varnishtest/tests}

mkdir -p lib
cp \
	${S}/include/vdef.h \
	${S}/include/miniobj.h \
	${S}/include/vqueue.h \
	${S}/include/vend.h \
	${S}/include/vcli.h \
	${S}/include/binary_heap.h	${S}/lib/libvarnish/binary_heap.c \
	${S}/include/vas.h		${S}/lib/libvarnish/vas.c \
	${S}/include/vav.h		${S}/lib/libvarnish/vav.c \
	${S}/include/vct.h		${S}/lib/libvarnish/vct.c \
	${S}/include/vev.h		${S}/lib/libvarnish/vev.c \
	${S}/include/vfil.h		${S}/lib/libvarnish/vfil.c \
	${S}/include/vfl.h		${S}/lib/libvarnish/vfl.c \
	${S}/include/vjsn.h		${S}/lib/libvarnish/vjsn.c \
	${S}/include/vlu.h		${S}/lib/libvarnish/vlu.c \
	${S}/include/vnum.h		${S}/lib/libvarnish/vnum.c \
	${S}/include/vpf.h		${S}/lib/libvarnish/vpf.c \
	${S}/include/vre.h		${S}/lib/libvarnish/vre.c \
	${S}/include/vrnd.h		${S}/lib/libvarnish/vrnd.c \
	${S}/include/vsa.h		${S}/lib/libvarnish/vsa.c \
	${S}/include/vsb.h		${S}/lib/libvarnish/vsb.c \
	${S}/include/vss.h		${S}/lib/libvarnish/vss.c \
	${S}/include/vsub.h		${S}/lib/libvarnish/vsub.c \
	${S}/include/vtcp.h		${S}/lib/libvarnish/vtcp.c \
	${S}/include/vtim.h		${S}/lib/libvarnish/vtim.c \
	${S}/include/vus.h		${S}/lib/libvarnish/vus.c \
	lib

mkdir -p src
cp \
	${S}/bin/varnishtest/*.[ch] \
	${S}/bin/varnishtest/gensequences \
	${S}/bin/varnishtest/sequences \
	${S}/bin/varnishtest/huffman_input \
	${S}/bin/varnishtest/huffman_gen.py \
	src

rm -f src/teken_state.h
rm -f src/vtc_h2_dectbl.h

mkdir -p src/tbl
cp \
	${S}/include/tbl/h2*.h \
	${S}/include/tbl/vhp_huffman.h \
	${S}/include/tbl/vsl_tags.h \
	${S}/include/tbl/vsl_tags_http.h \
	src/tbl


mkdir -p tests
for i in ${T}/a*.vtc
do
	sed -e 's/varnishtest/vtest/g' $i > tests/`basename $i`
done

# sed -i is not portable
sed -e 's/vgz.h/zlib.h/' src/vtc_http.c > src/vtc_http.c_
cat src/vtc_http.c_ > src/vtc_http.c
rm -f src/vtc_http.c_

echo '
#define HAVE_CLOCK_GETTIME 1
#define HAVE_NANOSLEEP 1
#define HAVE_STATVFS_H 1
#define HAVE_SYS_MOUNT_H 1
' > src/config.h

(
	echo '#'
	echo ''
	echo "VARNISH_SRC=${S}"
	echo ''
	echo 'all: vtest'
	echo ''
	echo 'vtest: \'
	echo '		lib/*.[ch] \'
	echo '		src/*.[ch] \'
	echo '		src/tbl/*.h \'
	echo '		src/sequences src/gensequences \'
	echo '		src/huffman_gen.py src/tbl/vhp_huffman.h'
	echo '	awk -f src/gensequences src/sequences > src/teken_state.h'
	echo '	python3 src/huffman_gen.py src/tbl/vhp_huffman.h > src/vtc_h2_dectbl.h'
	echo '	${CC} \'
	echo '		-o vtest \'
	echo '		-I src \'
	echo '		-I lib \'
	echo '		-I /usr/local/include \'
	echo '		-I ${VARNISH_SRC}/include \'
	echo '		-pthread \'
	echo '		src/*.c \'
	echo '		lib/*.c \'
	echo '		-L /usr/local/lib \'
	echo '		-lm \'
	echo '		-lpcre \'
	echo '		-lz \'
	echo '		-L${VARNISH_SRC}/lib/libvarnishapi/.libs \'
	echo '		-Wl,--rpath,${VARNISH_SRC}/lib/libvarnishapi/.libs \'
	echo '		-lvarnishapi'
	echo ''
	echo 'test: vtest'
	echo '	env PATH=`pwd`:${PATH} vtest tests/*.vtc'
	echo ''
	echo 'clean:'
	echo '	rm -f vtest'
	echo '	rm -f src/teken_state.h'
	echo '	rm -f src/vtc_h2_dectbl.h'
) > Makefile

gsrc '^' | wc -l
make
make test
make clean
gsrc '^' | wc -l
