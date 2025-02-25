#!/bin/sh

target_dir="$(dirname "$0")/sentencepiece"
export target_dir

source_root_dir="$(dirname "$0")"
export source_root_dir

export target_src_dir="${target_dir}/python/src/sentencepiece"

rm -rf "${target_dir}"
mkdir -p "${target_src_dir}"

for i in \
  CMakeLists.txt LICENSE README.md \
  VERSION.txt config.h.in sentencepiece.pc.in \
  setup.py pyproject.toml MANIFEST.in uv.lock \
  src third_party cmake
do
  echo "copying ${source_root_dir}/${i} ${target_dir}/${i}"
  cp -f -R "${source_root_dir}/${i}" "${target_dir}"
done

cp -f -R ./src/sentencepiece/*.py "${target_src_dir}/"
cp -f -R ./src/sentencepiece/*.cxx "${target_src_dir}/"
cp -f -R ./src/sentencepiece/*.i "${target_src_dir}/"
(
  cd sentencepiece || exit 5
  uv run python setup.py sdist
)
