#!/bin/bash

# Compile the resume into a PDF.
# All output (including intermediate LaTeX files) goes in the build directory,
# and a copy of the final PDF is placed in build/site to be deployed.

readonly THIS_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd | xargs realpath)"
readonly ROOT_DIR="${THIS_DIR}/.."
readonly BUILD_DIR="${ROOT_DIR}/build"
readonly SITE_BUILD_DIR="${BUILD_DIR}/site"

readonly TEX_FILENAME='resume.tex'
readonly PDF_FILENAME='resume.pdf'

function check_requirements() {
    if ! command -v pdflatex >/dev/null 2>&1 ; then
        echo "ERROR: Could not find pdflatex." >&2
        exit 10
    fi
}

function compile() {
    pdflatex -interaction=nonstopmode -halt-on-error -output-directory="${BUILD_DIR}" "${TEX_FILENAME}"
}

function main() {
    if [[ $# -ne 0 ]]; then
        echo "USAGE: $0"
        exit 1
    fi

    set -e
    trap exit SIGINT

    check_requirements

    cd "${ROOT_DIR}"

    # Remove any existing output.
    rm -rf "${BUILD_DIR}"
    mkdir -p "${SITE_BUILD_DIR}"

    # Compile twice so that any references resolve.
    compile
    compile

    cp "${BUILD_DIR}/${PDF_FILENAME}" "${SITE_BUILD_DIR}/${PDF_FILENAME}"
    echo "Resume compiled to '${SITE_BUILD_DIR}/${PDF_FILENAME}'."

    return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
