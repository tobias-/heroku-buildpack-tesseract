#!/bin/bash -eux

leptonica_version="1.72"
tesseract_version="3.04.00"
tesseract_languages=(swe eng dan)

if  ! wget --no-verbose -O- "https://s3.amazonaws.com/youcruit-us-cache/tesseract/tesseract_${tesseract_version}.tbz2" | tar jx -C "${BUILD_DIR}"; then
  TESS_BUILD="$(mktemp -d)"
  echo "$TESS_BUILD"
  export CPPFLAGS="-I${BUILD_DIR}/include"
  export LDFLAGS="-L${BUILD_DIR}/lib"
  cd "$TESS_BUILD"
  if ! [ -f "${BUILD_DIR}/lib/liblept.a" ]; then
  (
    curl http://www.leptonica.org/source/leptonica-${leptonica_version}.tar.gz | tar zx
    cd leptonica-${leptonica_version}
    ./configure --prefix="${BUILD_DIR}"
    make
    make install
  )
  fi

  if ! [ -f "${BUILD_DIR}/bin/tesseract" ]; then
  (
    git clone --single-branch --branch ${tesseract_version} --depth 1 https://github.com/tesseract-ocr/tesseract tesseract
    cd tesseract
    echo "$TESS_BUILD"
    export LIBLEPT_HEADERSDIR="${BUILD_DIR}/include"
    ./configure --prefix="${BUILD_DIR}"
    make
    make install
  )
  fi
fi

(
  cd "$BUILD_DIR"
  for lang in "${tesseract_languages[@]}"; do
    curl "https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.${lang}.tar.gz" | tar zx
  done
)


