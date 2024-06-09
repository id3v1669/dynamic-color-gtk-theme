#! /usr/bin/env bash

set -Eeo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${REPO_DIR}/src"

source "${REPO_DIR}/gtkrc.sh"

ROOT_UID=0
DEST_DIR=

ctype=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
	DEST_DIR="/usr/share/themes"
else
	DEST_DIR="$HOME/.themes"
fi

SASSC_OPT="-M -t expanded"

THEME_VARIANTS=('' '-Purple' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Teal' '-Grey')
COLOR_VARIANTS=('-Light' '-Dark')

install() {
	local dest="${1}"
	local name="${2}"
	local theme="${3}"
	local color="${4}"
	local size="${5}"
	local ctype="${6}"

	[[ "${color}" == '-Light' ]] && local ELSE_LIGHT="${color}"
	[[ "${color}" == '-Dark' ]] && local ELSE_DARK="${color}"

	local THEME_DIR="${1}/${2}${3}${4}${5}${6}"

	[[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

	echo "Installing '${THEME_DIR}'..."



	# GTK2 Themes
	mkdir -p                                                                      		 "${THEME_DIR}/gtk-2.0"
	 cp -r "${SRC_DIR}/main/gtk-2.0/gtkrc${theme}${ELSE_DARK:-}${ctype}" 				 "${THEME_DIR}/gtk-2.0/gtkrc"
	cp -r "${SRC_DIR}/main/gtk-2.0/common/"*'.rc'                                 		 "${THEME_DIR}/gtk-2.0"
	cp -r "${SRC_DIR}/assets/gtk-2.0/assets-common${ELSE_DARK:-}"                 		 "${THEME_DIR}/gtk-2.0/assets"
	cp -r "${SRC_DIR}/assets/gtk-2.0/assets${theme}${ELSE_DARK:-}${ctype}/"*"png" 		 "${THEME_DIR}/gtk-2.0/assets"

	# GTK3 Themes
	mkdir -p                                                                             "${THEME_DIR}/gtk-3.0"
    cp -r "${SRC_DIR}/assets/gtk/assets${theme}${ctype}"                                 "${THEME_DIR}/gtk-3.0/assets"
	cp -r "${SRC_DIR}/assets/gtk/scalable"                                               "${THEME_DIR}/gtk-3.0/assets"
	cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${theme}${ctype}${ELSE_DARK:-}.png" "${THEME_DIR}/gtk-3.0/thumbnail.png"
	sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk${color}.scss"                          "${THEME_DIR}/gtk-3.0/gtk.css"
	sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk-Dark.scss"                             "${THEME_DIR}/gtk-3.0/gtk-dark.css"

	# GTK4 Themes
	mkdir -p                                                                             "${THEME_DIR}/gtk-4.0"
	cp -r "${SRC_DIR}/assets/gtk/scalable"                                               "${THEME_DIR}/gtk-4.0/assets"
	cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${theme}${ctype}${ELSE_DARK:-}.png" "${THEME_DIR}/gtk-4.0/thumbnail.png"
	sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk${color}.scss"                          "${THEME_DIR}/gtk-4.0/gtk.css"
	sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk-Dark.scss"                             "${THEME_DIR}/gtk-4.0/gtk-dark.css"

	# Cinnamon Themes
	mkdir -p                                                                             "${THEME_DIR}/cinnamon"
	cp -r "${SRC_DIR}/assets/cinnamon/common-assets"                                     "${THEME_DIR}/cinnamon/assets"
	cp -r "${SRC_DIR}/assets/cinnamon/assets${ELSE_DARK:-}/"*'.svg'                      "${THEME_DIR}/cinnamon/assets"
	cp -r "${SRC_DIR}/assets/cinnamon/theme${theme}${ctype}/"*'.svg'                     "${THEME_DIR}/cinnamon/assets"
	sassc $SASSC_OPT "${SRC_DIR}/main/cinnamon/cinnamon${color}.scss"                    "${THEME_DIR}/cinnamon/cinnamon.css"
	cp -r "${SRC_DIR}/assets/cinnamon/thumbnails/thumbnail${theme}${ctype}${color}.png"  "${THEME_DIR}/cinnamon/thumbnail.png"

	# Metacity Themes
	mkdir -p                                                         					 "${THEME_DIR}/metacity-1"
	cp -r "${SRC_DIR}/main/metacity-1/metacity-theme-3.xml"          					 "${THEME_DIR}/metacity-1/metacity-theme-3.xml"
	cp -r "${SRC_DIR}/assets/metacity-1/assets"                      					 "${THEME_DIR}/metacity-1/assets"
	cp -r "${SRC_DIR}/assets/metacity-1/thumbnail${ELSE_DARK:-}.png" 					 "${THEME_DIR}/metacity-1/thumbnail.png"
	cd "${THEME_DIR}/metacity-1" && ln -s metacity-theme-3.xml metacity-theme-1.xml && ln -s metacity-theme-3.xml metacity-theme-2.xml

	# XFWM4 Themes
	mkdir -p                                                                             "${THEME_DIR}/xfwm4"
	cp -r "${SRC_DIR}/assets/xfwm4/assets${ELSE_LIGHT:-}${ctype}${window}/"*.png         "${THEME_DIR}/xfwm4"
	cp -r "${SRC_DIR}/main/xfwm4/themerc${ELSE_LIGHT:-}"                                 "${THEME_DIR}/xfwm4/themerc"
	mkdir -p                                                                             "${THEME_DIR}-hdpi/xfwm4"
	cp -r "${SRC_DIR}/assets/xfwm4/assets${ELSE_LIGHT:-}${ctype}${window}-hdpi/"*.png    "${THEME_DIR}-hdpi/xfwm4"
	cp -r "${SRC_DIR}/main/xfwm4/themerc${ELSE_LIGHT:-}"                                 "${THEME_DIR}-hdpi/xfwm4/themerc"
	sed -i "s/button_offset=6/button_offset=9/"                                          "${THEME_DIR}-hdpi/xfwm4/themerc"
	mkdir -p                                                                             "${THEME_DIR}-xhdpi/xfwm4"
	cp -r "${SRC_DIR}/assets/xfwm4/assets${ELSE_LIGHT:-}${ctype}${window}-xhdpi/"*.png   "${THEME_DIR}-xhdpi/xfwm4"
	cp -r "${SRC_DIR}/main/xfwm4/themerc${ELSE_LIGHT:-}"                                 "${THEME_DIR}-xhdpi/xfwm4/themerc"
	sed -i "s/button_offset=6/button_offset=12/"                                         "${THEME_DIR}-xhdpi/xfwm4/themerc"

	# Plank Themes
	mkdir -p                                                							 "${THEME_DIR}/plank"
	if [[ "$color" == '-Light' ]]; then
		cp -r "${SRC_DIR}/main/plank/theme-Light${ctype}/"* 							 "${THEME_DIR}/plank"
	else
		cp -r "${SRC_DIR}/main/plank/theme-Dark${ctype}/"*  							 "${THEME_DIR}/plank"
	fi
}

themes=()
colors=()
sizes=()
lcolors=()

while [[ $# -gt 0 ]]; do
	case "${1}" in
	-d | --dest)
		dest="${2}"
		if [[ ! -d "${dest}" ]]; then
			echo "Destination directory does not exist. Let's make a new one..."
			mkdir -p ${dest}
		fi
		shift 2
		;;
	-n | --name)
		name="${2}"
		shift 2
		;;
	-r | --remove | -u | --uninstall)
		uninstall="true"
		shift
		;;
	-l | --libadwaita)
		libadwaita="true"
		shift
		;;
	-c | --color)
		shift
		for color in "${@}"; do
			case "${color}" in
			standard)
				colors+=("${COLOR_VARIANTS[0]}")
				lcolors+=("${COLOR_VARIANTS[0]}")
				shift
				;;
			light)
				colors+=("${COLOR_VARIANTS[1]}")
				lcolors+=("${COLOR_VARIANTS[1]}")
				shift
				;;
			dark)
				colors+=("${COLOR_VARIANTS[2]}")
				lcolors+=("${COLOR_VARIANTS[2]}")
				shift
				;;
			-* | --*)
				break
				;;
			*)
				echo "ERROR: Unrecognized color variant '$1'."
				echo "Try '$0 --help' for more information."
				exit 1
				;;
			esac
		done
		;;
	-t | --theme)
		accent='true'
		shift
		for variant in "$@"; do
			case "$variant" in
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
			-*)
				break
				;;
			*)
				echo "ERROR: Unrecognized theme variant '$1'."
				echo "Try '$0 --help' for more information."
				exit 1
				;;
			esac
		done
		;;
	-s | --size)
		shift
		for variant in "$@"; do
			case "$variant" in
			standard)
				sizes+=("${SIZE_VARIANTS[0]}")
				shift
				;;
			compact)
				sizes+=("${SIZE_VARIANTS[1]}")
				compact='true'
				shift
				;;
			-*)
				break
				;;
			*)
				echo "ERROR: Unrecognized size variant '${1:-}'."
				echo "Try '$0 --help' for more information."
				exit 1
				;;
			esac
		done
		;;
	--tweaks)
		shift
		for variant in $@; do
			case "$variant" in
			storm)
				storm="true"
				ctype="-Storm"
				echo -e "Storm ColorScheme version! ..."
				shift
				;;
			moon)
				moon="true"
				ctype="-Moon"
				echo -e "Moon ColorScheme version! ..."
				shift
				;;
			black)
				blackness="true"
				echo -e "Blackness version! ..."
				shift
				;;
			float)
				float="true"
				echo -e "Install Floating Gnome-Shell Panel version! ..."
				shift
				;;
			outline)
				outline="true"
				echo -e "Install 2px windows outline version! ..."
				shift
				;;
			macos)
				macos="true"
				window="-Macos"
				echo -e "Macos window button version! ..."
				shift
				;;
			-*)
				break
				;;
			*)
				echo "ERROR: Unrecognized tweaks variant '$1'."
				echo "Try '$0 --help' for more information."
				exit 1
				;;
			esac
		done
		;;
	-h | --help)
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

if [[ "${#colors[@]}" -eq 0 ]]; then
	colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#lcolors[@]}" -eq 0 ]]; then
	lcolors=("${COLOR_VARIANTS[1]}")
fi

if [[ "${#sizes[@]}" -eq 0 ]]; then
	sizes=("${SIZE_VARIANTS[0]}")
fi

uninstall_link() {
	rm -rf "${HOME}/.config/gtk-4.0/"{assets,windows-assets,gtk.css,gtk-dark.css}
}

install_theme() {
	for theme in "${themes[@]}"; do
		for color in "${colors[@]}"; do
			for size in "${sizes[@]}"; do
				install "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$ctype"
				make_gtkrc "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$ctype"
			done
		done
	done

	if has_command xfce4-popup-whiskermen; then
		sed -i "s|.*menu-opacity=.*|menu-opacity=0|" "$HOME/.config/xfce4/panel/whiskermenu"*".rc"
	fi

	if (pgrep xfce4-session &>/dev/null); then
		xfce4-panel -r
	fi
}


	install_package && install_theme
	if [[ "$libadwaita" == 'true' ]]; then
		uninstall_link && link_theme
	fi

echo
echo Done.
