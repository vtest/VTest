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

find src lib -name '*.[ch]' -print |
while read f
do
	sed -i '' '
	s/"verrno.h"/<errno.h>/
	/typedef double vtim_/d
	s/vtim_mono	/double		/
	s/vtim_mono/double/g
	s/vtim_real	/double		/
	s/vtim_real/double/g
	s/vtim_dur	/double		/
	s/vtim_dur/double/g
	' $f
done


mkdir -p tests
for i in ${T}/a*.vtc
do
	sed -e 's/varnishtest/vtest/g' $i > tests/`basename $i`
done

# sed -i is not portable
sed -e 's/vgz.h/zlib.h/' src/vtc_http.c > src/vtc_http.c_
cat src/vtc_http.c_ > src/vtc_http.c
rm -f src/vtc_http.c_

gsrc '^' | wc -l
make
make test
make clean
gsrc '^' | wc -l
