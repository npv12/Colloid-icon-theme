#!/usr/bin/env bash

set -eo pipefail

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Colloid
COLOR_VARIANTS=('-light' '-dark' '')
SCHEME_VARIANTS=('' '-nord' '-dracula')
THEME_VARIANTS=('' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-teal' '-grey')

usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -s, --scheme TYPES      Specify folder color scheme variant(s) [default|nord|dracula|all]
    -t, --theme VARIANTS    Specify folder color theme variant(s) [default|purple|pink|red|orange|yellow|green|teal|grey|all] (Default: blue)
    -notint, --notint       Disable Follow ColorSheme for folders on KDE Plasma
    -h, --help              Show help
EOF
}

install() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local scheme=${4}
  local color=${5}

  local THEME_DIR=${1}/${2}${3}${4}${5}

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                                   ${THEME_DIR}
  cp -r "${SRC_DIR}"/src/index.theme                                                         ${THEME_DIR}
  sed -i "s/Colloid/${2}${3}${4}${5}/g"                                                      ${THEME_DIR}/index.theme

  if [[ "${color}" == '-light' ]]; then
    cp -r "${SRC_DIR}"/src/{actions,apps,categories,devices,emblems,mimetypes,places,status} ${THEME_DIR}
    cp -r "${SRC_DIR}"/links/*                                                               ${THEME_DIR}

    if [[ "${theme}" != '' ]]; then
      cp -r "${SRC_DIR}"/colors/color${theme}${scheme}/*.svg                                 ${THEME_DIR}/places/scalable
    elif [[ ${scheme} != '' ]]; then
      cp -r "${SRC_DIR}"/colors/color-blue${scheme}/*.svg                                    ${THEME_DIR}/places/scalable
    fi

    if [[ "${theme}" == '' && "${scheme}" == '' && "${notint}" == 'true' ]]; then
      cp -r "${SRC_DIR}"/notint/*.svg                                                        ${THEME_DIR}/places/scalable
    fi
  fi

  if [[ "${color}" == '-dark' ]]; then
    mkdir -p                                                                                 ${THEME_DIR}/{apps,categories,devices,emblems,mimetypes,places,status}
    cp -r "${SRC_DIR}"/src/actions                                                           ${THEME_DIR}
    cp -r "${SRC_DIR}"/src/apps/symbolic                                                     ${THEME_DIR}/apps
    cp -r "${SRC_DIR}"/src/categories/symbolic                                               ${THEME_DIR}/categories
    cp -r "${SRC_DIR}"/src/emblems/symbolic                                                  ${THEME_DIR}/emblems
    cp -r "${SRC_DIR}"/src/mimetypes/symbolic                                                ${THEME_DIR}/mimetypes
    cp -r "${SRC_DIR}"/src/devices/{16,22,24,32,symbolic}                                    ${THEME_DIR}/devices
    cp -r "${SRC_DIR}"/src/places/{16,22,24,symbolic}                                        ${THEME_DIR}/places
    cp -r "${SRC_DIR}"/src/status/{16,22,24,symbolic}                                        ${THEME_DIR}/status

    # Change icon color for dark theme
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,devices,places,status}/{16,22,24}/*
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,devices}/32/*
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,apps,categories,devices,emblems,mimetypes,places,status}/symbolic/*

    cp -r "${SRC_DIR}"/links/actions/{16,22,24,32,symbolic}                                  ${THEME_DIR}/actions
    cp -r "${SRC_DIR}"/links/devices/{16,22,24,32,symbolic}                                  ${THEME_DIR}/devices
    cp -r "${SRC_DIR}"/links/places/{16,22,24,symbolic}                                      ${THEME_DIR}/places
    cp -r "${SRC_DIR}"/links/status/{16,22,24,symbolic}                                      ${THEME_DIR}/status
    cp -r "${SRC_DIR}"/links/apps/symbolic                                                   ${THEME_DIR}/apps
    cp -r "${SRC_DIR}"/links/categories/symbolic                                             ${THEME_DIR}/categories
    cp -r "${SRC_DIR}"/links/mimetypes/symbolic                                              ${THEME_DIR}/mimetypes

    cd ${dest}
    ln -sf ../../${name}${theme}${scheme}-light/apps/scalable ${name}${theme}${scheme}-dark/apps/scalable
    ln -sf ../../${name}${theme}${scheme}-light/devices/scalable ${name}${theme}${scheme}-dark/devices/scalable
    ln -sf ../../${name}${theme}${scheme}-light/places/scalable ${name}${theme}${scheme}-dark/places/scalable
    ln -sf ../../${name}${theme}${scheme}-light/categories/32 ${name}${theme}${scheme}-dark/categories/32
    ln -sf ../../${name}${theme}${scheme}-light/emblems/16 ${name}${theme}${scheme}-dark/emblems/16
    ln -sf ../../${name}${theme}${scheme}-light/emblems/22 ${name}${theme}${scheme}-dark/emblems/22
    ln -sf ../../${name}${theme}${scheme}-light/status/32 ${name}${theme}${scheme}-dark/status/32
    ln -sf ../../${name}${theme}${scheme}-light/mimetypes/scalable ${name}${theme}${scheme}-dark/mimetypes/scalable
  fi

  if [[ "${color}" == '' ]]; then
    mkdir -p                                                                                 ${THEME_DIR}/status
    cp -r "${SRC_DIR}"/src/status/{16,22,24}                                                 ${THEME_DIR}/status
    # Change icon color for dark panel
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/status/{16,22,24}/*
    cp -r "${SRC_DIR}"/links/status/{16,22,24}                                               ${THEME_DIR}/status

    cd ${dest}
    ln -sf ../${name}${theme}${scheme}-light/apps ${name}${theme}${scheme}/apps
    ln -sf ../${name}${theme}${scheme}-light/actions ${name}${theme}${scheme}/actions
    ln -sf ../${name}${theme}${scheme}-light/devices ${name}${theme}${scheme}/devices
    ln -sf ../${name}${theme}${scheme}-light/emblems ${name}${theme}${scheme}/emblems
    ln -sf ../${name}${theme}${scheme}-light/places ${name}${theme}${scheme}/places
    ln -sf ../${name}${theme}${scheme}-light/categories ${name}${theme}${scheme}/categories
    ln -sf ../${name}${theme}${scheme}-light/mimetypes ${name}${theme}${scheme}/mimetypes
    ln -sf ../../${name}${theme}${scheme}-light/status/32 ${name}${theme}${scheme}/status/32
    ln -sf ../../${name}${theme}${scheme}-light/status/symbolic ${name}${theme}${scheme}/status/symbolic
  fi

  (
    cd ${THEME_DIR}
    ln -sf actions actions@2x
    ln -sf apps apps@2x
    ln -sf categories categories@2x
    ln -sf devices devices@2x
    ln -sf emblems emblems@2x
    ln -sf mimetypes mimetypes@2x
    ln -sf places places@2x
    ln -sf status status@2x
  )

  gtk-update-icon-cache ${THEME_DIR}
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -notint|--notint)
      notint='true'
      shift
      ;;
    -s|--scheme)
      shift
      for scheme in "${@}"; do
        case "${scheme}" in
          default)
            schemes+=("${SCHEME_VARIANTS[0]}")
            shift
            ;;
          nord)
            schemes+=("${SCHEME_VARIANTS[1]}")
            shift
            ;;
          dracula)
            schemes+=("${SCHEME_VARIANTS[2]}")
            shift
            ;;
          all)
            schemes+=("${SCHEME_VARIANTS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color schemes variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          teal)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          grey)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized theme color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]]; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#schemes[@]}" -eq 0 ]]; then
  schemes=("${SCHEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]]; then
  colors=("${COLOR_VARIANTS[@]}")
fi

install_theme() {
  for theme in "${themes[@]}"; do
    for scheme in "${schemes[@]}"; do
      for color in "${colors[@]}"; do
        install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${scheme}" "${color}"
      done
    done
  done
}

install_theme
