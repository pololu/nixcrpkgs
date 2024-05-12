source $setup

tar -xf $src
mv xcb-util-cursor-* src

license=$(cat src/COPYING)

cat > $out <<EOF
<h2>xcb-cursor</h2>

<pre>
$license
</pre>
EOF
