#!/bin/sh

set -eax

build_sdist() {
  source_root_dir="$(cd "$(dirname "$0")" 2>/dev/null; pwd)"
  export source_root_dir

  target_dir="${source_root_dir}/build/sdist"
  export target_dir

  export target_src_dir="${target_dir}/python/src/sentencepiece"

  rm -rf "${target_dir}"
  mkdir -p "${target_src_dir}"

  for i in \
    CMakeLists.txt LICENSE README.md \
    VERSION.txt config.h.in sentencepiece.pc.in \
    build_bundled.sh build_sdist.sh \
    setup.py pyproject.toml MANIFEST.in uv.lock \
    src data third_party cmake; do
    echo "copying ${source_root_dir}/${i} ${target_dir}/${i}"
    cp -f -R "${source_root_dir}/${i}" "${target_dir}"
  done

  cp -f -R \
    "${source_root_dir}/python/src/sentencepiece/"*.py \
    "${target_src_dir}/"
  cp -f -R \
    "${source_root_dir}/python/src/sentencepiece/"*.cxx \
    "${target_src_dir}/"
  cp -f -R \
    "${source_root_dir}/python/src/sentencepiece/"*.i \
    "${target_src_dir}/"

  (
    cd "$target_dir"
    uv sync \
      --python-preference only-managed \
      --locked --no-install-project
    uv run \
      --python-preference only-managed \
      --locked --no-reinstall --no-sync \
      python -m build --sdist
  )
}

build_sdist
