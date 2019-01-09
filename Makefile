#

SRCS=	src/*.c \
	lib/*.c

DEPS=	${SRCS} \
	lib/*.h \
	src/*.h \
	src/tbl/*.h \
	src/sequences src/gensequences \
	src/huffman_gen.py src/tbl/vhp_huffman.h

INCS=	-Isrc \
	-Ilib \
	-I/usr/local/include \
	-pthread

LIBS=	-L/usr/local/lib \
	-lm \
	-lpcre \
	-lz

#######################################################################
# If you want to build vtest without varnish support, use this part:

vtest: ${DEPS}
	awk -f src/gensequences src/sequences > src/teken_state.h
	python3 src/huffman_gen.py src/tbl/vhp_huffman.h > src/vtc_h2_dectbl.h
	${CC} \
		-o vtest \
		${INCS} \
		${SRCS} \
		${LIBS}

test: vtest
	env PATH=`pwd`:${PATH} vtest tests/*.vtc


#######################################################################
# ... other point to varnish source tree and use this part:

VARNISH_SRC=/home/phk/Varnish/trunk/varnish-cache

varnishtest:	${DEPS}
	awk -f src/gensequences src/sequences > src/teken_state.h
	python3 src/huffman_gen.py src/tbl/vhp_huffman.h > src/vtc_h2_dectbl.h
	${CC} \
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

clean:
	rm -f vtest varnishtest
	rm -f src/teken_state.h
	rm -f src/vtc_h2_dectbl.h
