project('VTest', 'c')

incdir = include_directories(['lib', 'src'])

c = meson.get_compiler('c')
c_args = []
foreach h : ['sys/statvfs.h', 'sys/vfs.h', 'sys/mount.h']
  if c.has_header(h)
    c_args += '-DHAVE_@0@'.format(h.to_upper().underscorify())
  endif
endforeach

libs = [
	dependency('varnishapi'),
	dependency('threads'),
	dependency('libpcre'),
	c.find_library('m'),
	c.find_library('z')
	]

teken_hdrs = custom_target('teken_state',
                        input : [ 'src/gensequences', 'src/sequences'],
                        output : 'teken_state.h',
                        command : [find_program('awk'), '-f', '@INPUT@'],
			capture: true)

h2tbl_hdr = custom_target('h2_tbl',
                        input : 'src/tbl/vhp_huffman.h',
                        output : 'vtc_h2_dectbl.h',
                        command : [find_program('huffman_gen.py'), '@INPUT@'],
			capture: true)

src = [
	'lib/binary_heap.c',
	'lib/vas.c',
	'lib/vav.c',
	'lib/vct.c',
	'lib/vev.c',
	'lib/vfil.c',
	'lib/vfl.c',
	'lib/vjsn.c',
	'lib/vlu.c',
	'lib/vnum.c',
	'lib/vpf.c',
	'lib/vre.c',
	'lib/vrnd.c',
	'lib/vsa.c',
	'lib/vsb.c',
	'lib/vss.c',
	'lib/vsub.c',
	'lib/vtcp.c',
	'lib/vtim.c',
	'lib/vus.c',
	'src/teken.c',
	'src/vtc_barrier.c',
	'src/vtc.c',
	'src/vtc_client.c',
	'src/vtc_h2_hpack.c',
	'src/vtc_h2_tbl.c',
	'src/vtc_haproxy.c',
	'src/vtc_http2.c',
	'src/vtc_http.c',
	'src/vtc_log.c',
	'src/vtc_main.c',
	'src/vtc_misc.c',
	'src/vtc_process.c',
	'src/vtc_proxy.c',
	'src/vtc_server.c',
	'src/vtc_subr.c',
	'src/vtc_syslog.c',
	'src/vtc_logexp.c',
	'src/vtc_varnish.c',
	teken_hdrs,
	h2tbl_hdr
	]

executable('varnishtest',
	sources: src,
	dependencies: libs,
	include_directories: incdir,
	c_args: c_args
	)
