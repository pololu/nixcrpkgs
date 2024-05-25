source $setup

tar -xf $src
mv systemd-* systemd

cd systemd
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done

# These files are difficult to compile, so we remove them
# and patch out anything depending on them.
rm src/basic/{filesystems,unit-name}.{c,h}

cd ..

$host-g++ -x c -c $size_flags - -o test.o <<EOF
#include <assert.h>
#include <string.h>
#include <sys/timex.h>
#include <sys/types.h>
#include <sys/resource.h>
static_assert(sizeof(pid_t) == SIZEOF_PID_T, "pid_t");
static_assert(sizeof(uid_t) == SIZEOF_UID_T, "uid_t");
static_assert(sizeof(gid_t) == SIZEOF_GID_T, "gid_t");
static_assert(sizeof(time_t) == SIZEOF_TIME_T, "time_t");
static_assert(sizeof(rlim_t) == SIZEOF_RLIM_T, "rlim_t");
static_assert(sizeof(dev_t) == SIZEOF_DEV_T, "dev_t");
static_assert(sizeof(ino_t) == SIZEOF_INO_T, "ino_t");
struct timex tmx;
static_assert(sizeof(tmx.freq) == SIZEOF_TIMEX_MEMBER);
const char * in_word_set(const char *, GPERF_LEN_TYPE);
EOF

rm test.o

mkdir build
cd build

mkdir include
cat > include/version.h <<END
#define GIT_VERSION "v$version"
END

cp -r $fill fill

$host-gcc -c -Werror -Ifill fill/*.c
$host-gcc -c $CFLAGS \
  -DRELATIVE_SOURCE_PATH=\"../systemd/\" \
  -Iinclude \
  -Ifill \
  -I../systemd/src/libudev \
  -I../systemd/src/basic \
  -I../systemd/src/fundamental \
  -I../systemd/src/libsystemd/sd-device \
  -I../systemd/src/libsystemd/sd-hwdb \
  -I../systemd/src/shared \
  -I../systemd/src/systemd \
  ../systemd/src/libudev/*.c
$host-gcc -c $CFLAGS \
  -DRELATIVE_SOURCE_PATH=\"../systemd/\" \
  -Iinclude \
  -Ifill \
  -I../systemd/src/libsystemd/sd-device \
  -I../systemd/src/libsystemd/sd-id128 \
  -I../systemd/src/libsystemd/sd-netlink \
  -I../systemd/src/basic \
  -I../systemd/src/systemd \
  -I../systemd/src/fundamental \
  ../systemd/src/libsystemd/sd-device/{device-enumerator,device-filter,device-private,sd-device}.c
$host-gcc -c $CFLAGS \
  -DRELATIVE_SOURCE_PATH=\"../systemd/\" \
  -DDEFAULT_USER_SHELL=\"/nonexistent/bin/bash\" \
  -DNOBODY_USER_NAME=\"nobody\" \
  -DNOBODY_GROUP_NAME=\"nobody\" \
  -DNOLOGIN=\"/nonexistent/nologin\" \
  -DPACKAGE_STRING="\"libudev $version\"" \
  -DFALLBACK_HOSTNAME="\"localhost\"" \
  -DDEFAULT_HIERARCHY_NAME="\"hybrid\"" \
  -DDEFAULT_HIERARCHY=CGROUP_UNIFIED_SYSTEMD \
  -Iinclude \
  -Ifill \
  -I../systemd/src/basic \
  -I../systemd/src/systemd \
  -I../systemd/src/fundamental \
  ../systemd/src/basic/{alloc-util,architecture,btrfs,bus-label,cgroup-util,chase,devnum-util,dirent-util,env-file,env-util,escape,extract-word,fd-util,fileio,format-util,fs-util,gunicode,glob-util,glyph-util,hashmap,hash-funcs,hexdecoct,hostname-util,inotify-util,io-util,label,locale-util,lock-util,log,login-util,os-util,memory-util,mempool,memstream-util,mkdir,mountpoint-util,namespace-util,nulstr-util,path-util,pidref,proc-cmdline,parse-util,prioq,process-util,random-util,ratelimit,signal-util,siphash24,socket-util,sort-util,stat-util,string-table,string-util,strv,strxcpyx,sync-util,syslog-util,terminal-util,time-util,tmpfile-util,user-util,utf8,virt,xattr-util,MurmurHash2}.c \
  ../systemd/src/fundamental/{sha256,string-util-fundamental}.c
$host-ar cr libudev.a *.o

mkdir -p $out/lib/pkgconfig $out/include
cp libudev.a $out/lib/
cp ../systemd/src/libudev/libudev.h $out/include/

cat > $out/lib/pkgconfig/libudev.pc <<EOF
prefix=$out
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libudev
Version: $version
Libs: -L\${libdir} -ludev
Cflags: -I\${includedir}
EOF
