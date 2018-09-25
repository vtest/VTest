#

VARNISH_SRC=/home/phk/Varnish/trunk/varnish-cache

all: vtest

vtest: \
		lib/*.[ch] \
		src/*.[ch] \
		src/tbl/*.h \
		src/sequences src/gensequences \
		src/huffman_gen.py src/tbl/vhp_huffman.h
	awk -f src/gensequences src/sequences > src/teken_state.h
	python3 src/huffman_gen.py src/tbl/vhp_huffman.h > src/vtc_h2_dectbl.h
	${CC} \
		-o vtest \
		-I src \
		-I lib \
		-I /usr/local/include \
		-I ${VARNISH_SRC}/include \
		-pthread \
		src/*.c \
		lib/*.c \
		-L /usr/local/lib \
		-lm \
		-lpcre \
		-lz \
		-L${VARNISH_SRC}/lib/libvarnishapi/.libs \
		-Wl,--rpath,${VARNISH_SRC}/lib/libvarnishapi/.libs \
		-lvarnishapi

test: vtest
	env PATH=`pwd`:${PATH} vtest tests/*.vtc

clean:
	rm -f vtest
	rm -f src/teken_state.h
	rm -f src/vtc_h2_dectbl.h
