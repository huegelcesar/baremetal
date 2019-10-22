#!/usr/bin/env bash
# This script uses BASH3 Boilerplate
#   BASH3 Boilerplate: https://github.com/kvz/bash3boilerplate

read -r -d '' __usage <<-'EOF' || true
  -b --binutils [arg]     GNU Binutils version. Required.
  -g --gcc      [arg]     GCC version. Required.
  -p --gmp      [arg]     GNU MP Bignum Library version. Required.
  -f --mpfr     [arg]     GNU MPFR Library version. Required.
  -n --newlib   [arg]     Newlib version. Required.
  -m --mpc      [arg]     GNU MPC. Required.

  -t --target   [arg]     Target. Required.
  -x --prefix   [arg]     Toolchain prefix. Default="${target%%-*}"
  -o --output   [arg]     Output directory. Default="/usr/local/"

  --make        [arg]     Makefile parameters (applied to all)

  -v                      Enable verbose mode, print script as it is executed
  -d --debug              Enables debug mode
  -c --no-color           Disable color output
  -h --help               This page
EOF
read -r -d '' __helptext <<-'EOF' || true
EOF

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/external/b3bp.sh"

### Signal trapping and backtracing (based on b3bp)
##############################################################################
__cleanup_before_exit ()
{
    kill $(jobs -p) > /dev/null 2>&1 || true # Move this to a better place
}

__err_report() # requires `set -o errtrace`
{
    local error_code
    error_code=${?}
    error "Error in ${__file} in function ${1} on line ${2}"
    __cleanup_before_exit
    exit ${error_code}
}
trap '__err_report "${FUNCNAME:-.}" ${LINENO}' ERR

__progress_bar()
{
  local now=$((${1}>${2}?${2}:${1}))
  local max=${2}
  local size=${3}
  local hat=$(("(${now}*${size})/${max}"))
  local head='>'
  printf -v 'prog' "%${hat}s${head:0:$((${size}-${hat}))}"
  printf -v 'bar' "[${prog// /=}%$((${size}-${#prog}))s] %3s%%" '' $(("(${now}*100)/${max}"))
  echo -n  "${bar}" && echo -ne " ${bar//?/\\b}\\b"
}
export -f __progress_bar;
__progress_bar_size=30

### Command-line argument switches (based on b3bp)
##############################################################################
# debug mode
if [[ "${arg_d:?}" = "1" ]]; then
  set -o xtrace
  LOG_LEVEL="7"
fi

# verbose mode
if [[ "${arg_v:?}" = "1" ]]; then
  set -o verbose
fi

# no color mode
if [[ "${arg_n:?}" = "1" ]]; then
  NO_COLOR="true"
fi

# help mode
if [[ "${arg_h:?}" = "1" ]]; then
  # Help exists with code 1
  help "Help using ${0} [options]"
fi

### Validation. Error out if the things required for your script are not present
##############################################################################

### Signal trapping on EXIT
trap __cleanup_before_exit EXIT

### Toolchain generation
##############################################################################
binutils=${arg_b}
gcc=${arg_g}
gmp=${arg_p}
mpfr=${arg_f}
newlib=${arg_n}
mpc=${arg_m}

target=${arg_t}
output_dir="$(cd "${arg_o}" && pwd)/${target%%-*}/gcc-${gcc}"
prefix=$(eval echo "${arg_x}-")

make=(${arg_make})

build_dir="${__dir}/build/toolchain-build-${target}"
stuff_bag="${__dir}/stuff_bag"

info "__file: ${__file}"
info "__dir: ${__dir}"
info "__base: ${__base}"
info "OSTYPE: ${OSTYPE}"

__print_setup()
{
  info "Toolchain setup:"
  info "   binutils: ${binutils}"
  info "   gcc: ${gcc}"
  info "   gmp: ${gmp}"
  info "   mpfr: ${mpfr}"
  info "   newlib: ${newlib}"
  info "   mpc: ${mpc}"
  info "   target: ${target}"
  info "   prefix: ${prefix}"
  info "   make: ${make[@]}"
  info "Output directory: ${output_dir}"
}
__print_setup

mkdir -p ${build_dir}
mkdir -p ${stuff_bag}

#set -m # Enable Job Control

url_binutils="http://ftp.gnu.org/gnu/binutils/binutils-${binutils}.tar.bz2"   # The GNU Binutils is a collection of binary tools (GNU linker, GNU assembler, ...)
url_gmp="http://ftp.gnu.org/gnu/gmp/gmp-${gmp}.tar.bz2"                       # GMP is the GNU Multiple-Precision Arithmetic Library
url_mpfr="http://ftp.gnu.org/gnu/mpfr/mpfr-${mpfr}.tar.bz2"                   # MPFR is the GNU Multiple-Precision Floating-Point Rounding Library. Depends on GMP
url_mpc="http://ftp.gnu.org/gnu/mpc/mpc-${mpc}.tar.gz"                        # MPC is the GNU Multiple-Precision C library. Depends on GMP and MPFR
url_gcc="http://ftp.gnu.org/gnu/gcc/gcc-${gcc}/gcc-${gcc}.tar.gz"             # GCC is the GNU Compiler Collection. Depends on GMP, MPFR and MPC.
url_newlib="http://www.sourceware.org/pub/newlib/newlib-${newlib}.tar.gz"     # Newlib is a C library intended for use on embedded systems.

### Download tools
##############################################################################

__download()
{
  local url=${1}
  local filename=${url##*/}
  info "Download [${filename}] {start} from <${url}>"
  wget -c ${url} && info "Download [${filename}] {success}" \
                 || ( error "Download [${filename}] {failed}" && exit 1 )
}

pushd ${stuff_bag} > /dev/null
__download ${url_binutils}
__download ${url_gcc}
__download ${url_gmp}
__download ${url_mpfr}
__download ${url_mpc}
__download ${url_newlib}
popd > /dev/null

### Extract tools
##############################################################################
__extract()
{
  # __extract <filter> <path>
  local opts=( --skip-old-files ${1} -x -f )
  local files=$(tar "${1}" -tvf ${2} | sed 's/ \+/ /g')
  local decompressed=$(($(echo "${files}" | cut -f3 -d' ' | sed '2,$s/^/+ /' | paste -sd' ' | bc)/1024))

  info "Extract [${2##*/}]"
  info ---n "  "
  tar --record-size=1K --checkpoint=$((${decompressed}/40)) --checkpoint-action=exec=" __progress_bar \$TAR_CHECKPOINT ${decompressed} ${__progress_bar_size}" "${opts[@]}" ${2} \
    && echo "" || (error "Extract [${2##*/}] failed" && exit 1)

  if [[ ${3:-} ]]; then
    eval $"${3}"=$(pwd)/$(echo "${files}" | cut -f6 -d' ' | sed 's@/.*@@' | uniq)
  fi
}

common_config_flags=( --target=${target} --prefix=${output_dir} --program-prefix=${prefix} )

pushd ${build_dir} > /dev/null

__extract -j ${stuff_bag}/${url_binutils##*/} src_binutils
__extract -z ${stuff_bag}/${url_gcc##*/}      src_gcc
__extract -j ${stuff_bag}/${url_gmp##*/}      src_gmp
__extract -j ${stuff_bag}/${url_mpfr##*/}     src_mpfr
__extract -z ${stuff_bag}/${url_mpc##*/}      src_mpc
__extract -z ${stuff_bag}/${url_newlib##*/}   src_newlib

### Build stuff
##############################################################################
__mkdirpush () {
  mkdir -p "$@" && eval pushd "\"\$$#\"" > /dev/null
}

# Creating soft link to include desired libraries
ln -s ../${src_gmp##*/} ${src_gcc}/gmp   || true
ln -s ../${src_mpfr##*/} ${src_gcc}/mpfr || true
ln -s ../${src_mpc##*/} ${src_gcc}/mpc   || true

# Building binutils
__mkdirpush build-${src_binutils##*/}
${src_binutils}/configure "${common_config_flags[@]}"
make "${make[@]}" && make check && make install
ln -s ${output_dir}/bin/${prefix}""ar ${output_dir}/bin/${target}-ar || true
ln -s ${output_dir}/bin/${prefix}""as ${output_dir}/bin/${target}-as || true
ln -s ${output_dir}/bin/${prefix}""ld ${output_dir}/bin/${target}-ld || true
ln -s ${output_dir}/bin/${prefix}""ranlib ${output_dir}/bin/${target}-ranlib || true
popd > /dev/null

export PATH=${PATH}:${output_dir}/bin

# Building gcc
__mkdirpush build-${src_gcc##*/}
${src_gcc}/configure "${common_config_flags[@]}" \
                    --enable-languages=c \
                    --disable-libssp
make "${make[@]}" && make check && make install
ln -s ${output_dir}/bin/${prefix}""gcc ${output_dir}/bin/${target}-cc || true
popd > /dev/null

# Building newlib
pushd ${src_newlib} > /dev/null
./configure "${common_config_flags[@]}"
make "${make[@]}" && make check && make install
popd > /dev/null

# Building g++
__mkdirpush build-${src_gcc##*/}++
${src_gcc}/configure "${common_config_flags[@]}" \
                    --enable-languages=c,c++ \
                    --disable-nls \
                    --disable-multilib \
                    --disable-libssp \
                    --disable-shared \
                    --disable-threads \
                    --enable-target-optspace \
                    --without-headers \
                    --with-newlib \
                    --with-gnu-as \
                    --with-gnu-ld
make "${make[@]}" && make check && make install
ln -s ${output_dir}/bin/${prefix}""gcc ${output_dir}/bin/${target}-cc || true
popd > /dev/null


popd > /dev/null #${build_dir}
__print_setup