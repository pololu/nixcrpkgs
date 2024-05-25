source $setup

tar -xf $src
mv systemd-* systemd

cd systemd
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done

# These have compiler errors and we don't seem to need them.
rm src/basic/{arphrd-util,cap-list,capability-util,compress,filesystems,path-lookup,uid-alloc-range,unit-def,unit-file,unit-name}.{c,h}
rm $(find src/libsystemd/ -name test-*.c)

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

echo "Compiling libudev..."
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
echo "Compiling libsystemd..."
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
  ../systemd/src/libsystemd/sd-device/*.c \
  ../systemd/src/libsystemd/sd-id128/*.c \
  ../systemd/src/libsystemd/sd-netlink/*.c \
  ../systemd/src/libsystemd/sd-daemon/*.c \
  ../systemd/src/libsystemd/sd-event/*.c
echo "Compiling helpers..."
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
  ../systemd/src/basic/*.c \
  ../systemd/src/fundamental/*.c
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
