#

PYTHON2	?=	python2
PYTHON3	?=	python3
PYTHON	?=	python

VARNISH_SRC ?= /home/phk/Varnish/trunk/varnish-cache

AWK	?=	awk

SRCS=	src/*.c \
	lib/*.c

DEPS=	${SRCS} \
	lib/*.h \
	src/*.h \
	src/tbl/*.h \
	src/teken_state.h \
	src/vtc_h2_dectbl.h

FLAGS=	-O2 -s -Wall -Werror

INCS=	-Isrc \
	-Ilib \
	-I/usr/local/include \
	-pthread

LIBS=	-L/usr/local/lib \
	-lm \
	-lpcre2-8 \
	-lz

#######################################################################
# If you want to build vtest without varnish support, use this part:

vtest: ${DEPS}
	${CC} \
		${FLAGS} \
		-o vtest \
		${INCS} \
		${SRCS} \
		${LIBS}

test: vtest
	env PATH=`pwd`:${PATH} vtest tests/*.vtc

#######################################################################
# ... other point to varnish source tree and use this part:

varnishtest:	${DEPS}
	${CC} \
		${FLAGS} \
		-o varnishtest \
		-DVTEST_WITH_VTC_VARNISH \
		-DVTEST_WITH_VTC_LOGEXPECT \
		${INCS} \
		-I${VARNISH_SRC}/include \
		${SRCS} \
		${LIBS} \
		-L${VARNISH_SRC}/lib/libvarnishapi/.libs \
		-Wl,--rpath,${VARNISH_SRC}/lib/libvarnishapi/.libs \
		-lvarnishapi

#######################################################################

src/vtc_h2_dectbl.h:	src/huffman_gen.py src/tbl/vhp_huffman.h
	@( echo trying python3 && \
	${PYTHON3} src/huffman_gen.py src/tbl/vhp_huffman.h > $@ ) || \
	( echo trying python2 instead && \
	${PYTHON2} src/huffman_gen.py src/tbl/vhp_huffman.h > $@ ) || \
	( echo trying python instead && \
	${PYTHON} src/huffman_gen.py src/tbl/vhp_huffman.h > $@ ) || \
	( echo failed && exit 1 )

#######################################################################

src/teken_state.h:	src/gensequences src/sequences
	${AWK} -f src/gensequences src/sequences > src/teken_state.h

#######################################################################

clean:
	rm -f vtest varnishtest
	rm -f src/teken_state.h
	rm -f src/vtc_h2_dectbl.h
