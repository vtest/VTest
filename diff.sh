
VT=/home/phk/Varnish/trunk/varnish-cache

for i in `find lib src -type f -print`
do
	b=`basename $i`
	d=false
	for j in \
		${VT}/include/$b \
		${VT}/include/tbl/$b \
		${VT}/lib/libvarnish/$b \
		${VT}/bin/varnishtest/$b
	do
		if [ -f $j ] ; then
			diff -u $i $j
			d=true
			break
		fi
	done
	if ! $d ; then
		echo "MISSING $i"
	fi
done
