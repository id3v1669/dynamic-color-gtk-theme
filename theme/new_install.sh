#!/usr/bin/env bash

source "./help.sh"

#----------------------------------------#
##############Terminal Colors#############
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
bc="\033[7m"
defaultColour="\033[0m"
#----------------------------------------#


#----------------------------------------#
#################Variables################
# array of allowed contrast colors
accentColorsWhitelist=("red" "orange" "yellow" "green" "cyan" "blue" "purlple" "pink")
accentColorName="orange"                   # default accent color
declare -A accentColors                    # declare an associative array to store the contrast colors

theme_name="Dynamic-Color-GTK-Theme"
input_dir="./src"
temp_dir="./src-colored"
theme_dir="$HOME/.themes/$theme_name"
default_theme_dir=true
url_colors="https://api.github.com/repos/id3v1669/32based-color-shemes/contents/src?ref=master"
color_filenames=($(curl -s "$url_colors" | grep -oP '"name": "\K[^"]+' | grep -oP '.*(?=\.)'))
color_palette=""
palette_type="dark"
palette_variants=("dark" "light")
yml_file="./default.yml"

declare -A baseColors                      # declare an associative array to store the base colors
theme_dark=true                            # default theme is dark
compat_flag=false                          # default compat flag is false
blackness_flag=false                       # default blackness flag is false
mac_buttons_flag=false                     # default mac buttons flag is false
float_panel_flag=false                     # default float panel flag is false
outline_flag=false                         # default outline flag is false
debug_flag=false                           # default debug flag is false
link_gtk4_flag=true                        # default link gtk4 flag is true
allowed_gs_versions=("3-28" "40-0" "42-0" "44-0" "46-0")
custom_gs_version=false
gs_version="46-0"                          # default gnome-shell version

sassc_opt="-M -t expanded"
dependencies=("sassc" "lutgen")
color_variants=("-Light" "-Dark" "")
color_sheme=""
else_dark=""
else_light=""
declare -A png_replacement_colors
png_replacement_colors["base00"]="D2D2DA"
#----------------------------------------#


#----------------------------------------#
###############Verifications##############
yes_no() {
  while true; do
    read -p "" yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo -e "${red}Incorrect option: $yn. Try again:${defaultColour}";;
    esac
  done
}
verify_accent_color() {
  if [[ ! " ${accentColorsWhitelist[@]} " =~ " $accentColorName " ]]; then
    echo -e "${red}Invalid accent color: $accentColorName."
    echo -e "${blue}Availible accents: ${accentColorsWhitelist[@]}${defaultColour}"
    exit 1
  fi
}
verify_palette_name() {
  filenames=($(curl -s "$url_colors" | grep -oP '"name": "\K[^"]+' | grep -oP '.*(?=\.)'))
  if [[ ! " ${filenames[@]} " =~ " ${color_palette} " ]]; then
    echo -e "${red}Invalid color palette: $color_palette."
    echo -e "${blue}Availible palettes:"
    for i in "${!filenames[@]}"; do
      echo -e "${blue}${filenames[$i]}${defaultColour}"
    done
    exit 1
  fi
}
verify_palette_type() {
  if [[ ! " ${palette_variants[@]} " =~ " ${palette_type} " ]]; then
    echo -e "${red}Invalid palette type: $palette_type."
    echo -e "${blue}Availible types: ${palette_variants[@]}${defaultColour}"
    exit 1
  fi
}
verify_yml_file() {
  if [[ ! -f $yml_file ]]; then
    echo -e "${red}Invalid yml file: $yml_file."
    exit 1
  fi
}
verify_or_create_theme_dir() {
  if [[ ! -d $theme_dir ]]; then
    echo -e "${red}Output directory does not exist: $theme_dir."
    echo -e "${blue}Create it? (y/n)${defaultColour}"
    if yes_no; then
      mkdir -p $theme_dir
      echo -e "${green}Directory created: $theme_dir${defaultColour}"
    else
      echo -e "${red}Exiting.."
      exit 1
    fi
  else
    if [ "$(ls -A $theme_dir)" ]; then
      echo -e "${red}Output directory is not empty: $theme_dir."
      echo -e "${blue}Delete contents? (y/n)${defaultColour}"
      if yes_no; then
        rm -rf $theme_dir/*
        echo -e "${green}Contents deleted: $theme_dir${defaultColour}"
      else
        echo -e "${red}Exiting.."
        exit 1
      fi
    fi
  fi
  if [[ $default_theme_dir == false ]]; then
    echo -e "${blue}Using non-default directory: $theme_dir${defaultColour}"
    echo -e "${blue}Do you want gtk4 forlder to be linked to $HOME/.config ?(y/n)${defaultColour}"
    if ! yes_no; then
      link_gtk4_flag=false
    fi
  fi
}
verify_dependencies() {
  for dep in "${dependencies[@]}"; do
    if [[ ! "$(command -v $dep)" ]]; then
      echo -e "${red}Dependency not found: $dep."
      exit 1
    fi
  done
}
verify_gs_version() {
    # if custom gs version is set, check if it is allowed
    if [[ $custom_gs_version == true ]]; then
        if [[ ! " ${allowed_gs_versions[@]} " =~ " $gs_version " ]]; then
            echo -e "${red}Invalid gnome-shell version: $gs_version."
            echo -e "${blue}Availible versions: ${allowed_gs_versions[@]}${defaultColour}"
            exit 1
        fi
    elif [[ "$(command -v gnome-shell)" ]]; then
	    echo && gnome-shell --version
	    shell_version="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
	    if [[ "${shell_version:-}" -ge "46" ]]; then
	        gs_version="46-0"
	    elif [[ "${shell_version:-}" -ge "44" ]]; then
	        gs_version="44-0"
	    elif [[ "${shell_version:-}" -ge "42" ]]; then
	        gs_version="42-0"
	    elif [[ "${shell_version:-}" -ge "40" ]]; then
	        gs_version="40-0"
	    else
	        gs_version="3-28"
	    fi
    else
	    echo -e "${blue}'gnome-shell' not found, using styles for default version - $gs_version.${defaultColour}"
    fi
}
verify_style() {
    if [[ $theme_style == true ]]; then
        if [[ ! " ${color_variants[@]} " =~ " $color_sheme " ]]; then
            echo -e "${red}Invalid style: $color_sheme."
            echo -e "${blue}Availible styles: ${color_variants[@]}"
            echo -e "Leave empty to use default style${defaultColour}"
            exit 1
        else
            if [[ $color_sheme == "-Light" ]]; then
                else_light="-Light"
            elif [[ $color_sheme == "-Dark" ]]; then
                else_dark="-Dark"
            fi
        fi
    fi
}
#----------------------------------------#


#----------------------------------------#
################Write temp################
generate_gtk_assets() {
  input_svg="$temp_dir/assets/gtk/assets.svg"
  local out_dir="$temp_dir/assets/gtk/assets"
  mkdir -p $out_dir

  get_ids="inkscape --query-all $input_svg"

  ids=$(eval $get_ids | awk '{print $1}' | awk '/^\*\*/ { sub(/,.*/, ""); print }')

  for id in $ids; do
    moded_id=${id:2}
    # regular assets
    inkscape --export-id="$id" --export-id-only --export-filename="$out_dir/$moded_id.png" $input_svg
    optipng -o7 --quiet "$out_dir/$moded_id.png"
    # @2 assets
    inkscape --export-id="$id" --export-id-only --export-dpi=192 --export-filename="$out_dir/$moded_id@2.png" $input_svg
    optipng -o7 --quiet "$out_dir/$moded_id@2.png"
  done
}
write() {
    # Recreate dest dir
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    # Copy all files from input dir to dest with color replacements
    find "$input_dir" -type f | while read -r file; do
        target_file="$temp_dir/${file#$input_dir/}"
        if [[ $debug_flag == true ]]; then
            echo -e "${green}Writing $target_file"
        fi
        mkdir -p "$(dirname "$target_file")"
        cp -L "$file" "$target_file"
        if [[ ! "$target_file" =~ \.png$ ]]; then
            for find_color in "${!baseColors[@]}"; do
                #echo -e "${blue}Replacing $find_color with ${baseColors[$find_color]}"
                replace_hex="#${baseColors[$find_color]}"
                #echo "sed -i 's/\*\*$find_color\*\*/$replace_hex/g' $target_file"
                sed -i "s/\*\*$find_color\*\*/$replace_hex/g" "$target_file"
            done
            for accent in "${!accentColors[@]}"; do
                replace_hex="#${accentColors["$accent"]}"
                sed -i "s/\*\*$accent\*\*/$replace_hex/g" "$target_file"
            done
        else
          echo "png"
        fi
    done
}
#----------------------------------------#


#----------------------------------------#
###########Read colors form yml###########

read_colors() {
  while read -r line; do
    color=$(echo "$line" | grep -oP '(?<=: ")[0-9A-Fa-f]{6}')
    #echo "color: $color"
    key=$(echo "$line" | grep -oP 'base[0-9A-Fa-f]{2}')
    #echo "key: $key"
    baseColors[$key]=$color
  done < <(grep -oE 'base[0-9A-Fa-f]{2}: "[0-9A-Fa-f]{6}"*' $yml_file)
}
swap_fg_bg() {
  for i in {00..03}; do
    temp="${baseColors["base$i"]}"
    baseColors["base$i"]="${baseColors["base0$((i+4))"]}"
    baseColors["base0$((i+4))"]="$temp"
  done
}
#----------------------------------------#


#----------------------------------------#
###############Accent color###############
set_accent_color() {
  case $accentColorName in
    red)
      accentColors["accent00"]="${baseColors["base08"]}"
      accentColors["accent01"]="${baseColors["base09"]}"
      accentColors["accent02"]="${baseColors["base0A"]}"
      ;;
    orange)
      accentColors["accent00"]="${baseColors["base0B"]}"
      accentColors["accent01"]="${baseColors["base0C"]}"
      accentColors["accent02"]="${baseColors["base0D"]}"
      ;;
    yellow)
      accentColors["accent00"]="${baseColors["base0E"]}"
      accentColors["accent01"]="${baseColors["base0F"]}"
      accentColors["accent02"]="${baseColors["base10"]}"
      ;;
    green)
      accentColors["accent00"]="${baseColors["base11"]}"
      accentColors["accent01"]="${baseColors["base12"]}"
      accentColors["accent02"]="${baseColors["base13"]}"
      ;;
    cyan)
      accentColors["accent00"]="${baseColors["base14"]}"
      accentColors["accent01"]="${baseColors["base15"]}"
      accentColors["accent02"]="${baseColors["base16"]}"
      ;;
    blue)
      accentColors["accent00"]="${baseColors["base17"]}"
      accentColors["accent01"]="${baseColors["base18"]}"
      accentColors["accent02"]="${baseColors["base19"]}"
      ;;
    purple)
      accentColors["accent00"]="${baseColors["base1A"]}"
      accentColors["accent01"]="${baseColors["base1B"]}"
      accentColors["accent02"]="${baseColors["base1C"]}"
      ;;
    pink)
      accentColors["accent00"]="${baseColors["base1D"]}"
      accentColors["accent01"]="${baseColors["base1E"]}"
      accentColors["accent02"]="${baseColors["base1F"]}"
      ;;
  esac
}
#----------------------------------------#

#----------------------------------------#
##################Install#################

download_palette() {
  url_download="https://raw.githubusercontent.com/id3v1669/32based-color-shemes/master/src/$yml_file"
  curl -s "$url_download" > "$yml_file"
}

set_gnome_shell_version() {
	sed -i "/\widgets/s/40-0/${gs_version}/" "${temp_dir}/sass/gnome-shell/_common.scss"
	if [[ "${gs_version}" == '3-28' ]]; then
		sed -i "/\extensions/s/40-0/${gs_version}/" "${temp_dir}/sass/gnome-shell/_common.scss"
	fi
}

compact_size() {
	sed -i "/\$compact:/s/false/true/" "${temp_dir}/sass/_tweaks.scss"
}

blackness_color() {
	sed -i "/\$blackness:/s/false/true/" "${temp_dir}/sass/_tweaks.scss"
}

macos_buttons() {
	sed -i "/\$window_button:/s/normal/mac/" ${temp_dir}/sass/_tweaks.scss
}

float_panel() {
	sed -i "/\$float:/s/false/true/" "${temp_dir}/sass/_tweaks.scss"
}

outline_style() {
	sed -i "/\$outline:/s/false/true/" "${temp_dir}/sass/_tweaks.scss"
}

generate_index_theme() {
	cat <<EOF > $theme_dir/index.theme
Type=X-GNOME-Metatheme
[Desktop Entry]
Name=Dynamic-Color-GTK-Theme
Comment=Dynamic-Color-GTK-Theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Dynamic-Color-GTK-Theme
MetacityTheme=Dynamic-Color-GTK-Theme
IconTheme=Tela-circle${ELSE_DARK:-}
CursorTheme=${todo}-cursors
ButtonLayout=close,minimize,maximize:menu
EOF
}

link_gtk4() {

	rm -rf $HOME/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}

	echo -e "\nLink '$theme_dir/gtk-4.0' to '${HOME}/.config/gtk-4.0' for libadwaita..."

	mkdir -p $HOME/.config/gtk-4.0
	ln -sf $theme_dir/gtk-4.0/assets $HOME/.config/gtk-4.0/assets
	ln -sf $theme_dir/gtk-4.0/gtk.css $HOME/.config/gtk-4.0/gtk.css
	ln -sf $theme_dir/gtk-4.0/gtk-dark.css $HOME/.config/gtk-4.0/gtk-dark.css
}

install_theme() {
  # create directories
  mkdir -p $theme_dir/{gtk-2.0,gtk-3.0,gtk-4.0,metacity-1,cinnamon,gnome-shell,xfwm4}/assets

  # Gnome Shell
  cp -r $temp_dir/main/gnome-shell/pad-osd.css                                      $theme_dir/gnome-shell
	sassc $sassc_opt $temp_dir/main/gnome-shell/gnome-shell.scss		                  $theme_dir/gnome-shell/gnome-shell.css

	cp -r $temp_dir/assets/gnome-shell/common-assets              		                $theme_dir/gnome-shell/assets
	cp -r $temp_dir/assets/gnome-shell/assets${else_dark:-}/*.svg  		                $theme_dir/gnome-shell/assets
	cp -r $temp_dir/assets/gnome-shell/theme/*.svg 					                          $theme_dir/gnome-shell/assets

  cp $temp_dir/assets/gnome-shell/assets/{no-events,no-notifications}.svg           $theme_dir/gnome-shell
  cp $temp_dir/assets/gnome-shell/common-assets/process-working.svg                 $theme_dir/gnome-shell

  # GTK2 Themes
	cp -r $temp_dir/main/gtk-2.0/gtkrc${else_dark:-}  				                        $theme_dir/gtk-2.0/gtkrc
	cp -r $temp_dir/main/gtk-2.0/common/*.rc                                          $theme_dir/gtk-2.0
	cp -r $temp_dir/assets/gtk-2.0/assets-common${else_dark:-}                        $theme_dir/gtk-2.0/assets
	cp -r $temp_dir/assets/gtk-2.0/assets${else_dark:-}/*.png 		                    $theme_dir/gtk-2.0/assets

	# GTK3 Themes
  cp -r $temp_dir/assets/gtk/assets                                                 $theme_dir/gtk-3.0/assets
	cp -r $temp_dir/assets/gtk/scalable                                               $theme_dir/gtk-3.0/assets
	cp -r $temp_dir/assets/gtk/thumbnails/thumbnail.png                               $theme_dir/gtk-3.0/thumbnail.png
	sassc $SASSC_OPT $temp_dir/main/gtk-3.0/gtk${color_sheme:-}.scss                  $theme_dir/gtk-3.0/gtk.css
	sassc $SASSC_OPT $temp_dir/main/gtk-3.0/gtk-Dark.scss                             $theme_dir/gtk-3.0/gtk-dark.css

	# GTK4 Themes
	cp -r $temp_dir/assets/gtk/scalable                                               $theme_dir/gtk-4.0/assets
	cp -r $temp_dir/assets/gtk/thumbnails/thumbnail.png                               $theme_dir/gtk-4.0/thumbnail.png
	sassc $SASSC_OPT $temp_dir/main/gtk-4.0/gtk${color_sheme:-}.scss                  $theme_dir/gtk-4.0/gtk.css
	sassc $SASSC_OPT $temp_dir/main/gtk-4.0/gtk-Dark.scss                             $theme_dir/gtk-4.0/gtk-dark.css

	# Cinnamon Themes
	cp -r $temp_dir/assets/cinnamon/common-assets                                     $theme_dir/cinnamon/assets
	cp -r $temp_dir/assets/cinnamon/assets${else_dark:-}/*.svg                        $theme_dir/cinnamon/assets
	cp -r $temp_dir/assets/cinnamon/theme/*.svg                                       $theme_dir/cinnamon/assets
	sassc $SASSC_OPT $temp_dir/main/cinnamon/cinnamon${color_sheme:-}.scss            $theme_dir/cinnamon/cinnamon.css
	cp -r $temp_dir/assets/cinnamon/thumbnails/thumbnail.png                          $theme_dir/cinnamon/thumbnail.png

	# Metacity Themes
  for i in {1..3}; do cp $temp_dir/main/metacity-1/metacity-theme-3.xml             $theme_dir/metacity-1/metacity-theme-${i}.xml; done
	cp -r $temp_dir/assets/metacity-1/assets                      		                $theme_dir/metacity-1/assets
	cp -r $temp_dir/assets/metacity-1/thumbnail${else_dark:-}.png 		                $theme_dir/metacity-1/thumbnail.png

  # XFWM4 Themes
	cp -r $temp_dir/assets/xfwm4/assets${else_light:-}/*.png                          $theme_dir/xfwm4
	cp -r $temp_dir/main/xfwm4/themerc${else_light:-}                                 $theme_dir/xfwm4/themerc
  mkdir -p                                                                          $theme_dir-hdpi/xfwm4
	cp -r $temp_dir/assets/xfwm4/assets${else_light:-}-hdpi/*.png                     $theme_dir-hdpi/xfwm4
	cp -r $temp_dir/main/xfwm4/themerc${else_light:-}                                 $theme_dir-hdpi/xfwm4/themerc
	sed -i "s/button_offset=6/button_offset=9/"                                       $theme_dir-hdpi/xfwm4/themerc
	mkdir -p                                                                          $theme_dir-xhdpi/xfwm4
	cp -r $temp_dir/assets/xfwm4/assets${else_light:-}-xhdpi/*.png                    $theme_dir-xhdpi/xfwm4
	cp -r $temp_dir/main/xfwm4/themerc${else_light:-}                                 $theme_dir-xhdpi/xfwm4/themerc
	sed -i "s/button_offset=6/button_offset=12/"                                      $theme_dir-xhdpi/xfwm4/themerc

	# Plank Themes
	mkdir -p                                                							            $theme_dir/plank
	if [[ "$color_sheme" == '-Light' ]]; then
		cp -r $temp_dir/main/plank/theme-Light/* 							                          $theme_dir/plank
	else
		cp -r $temp_dir/main/plank/theme-Dark/*  							                          $theme_dir/plank
	fi
}
#----------------------------------------#



echo "start"
while getopts ":i:t:a:g:s:cbmfodh" flag; do
  case $flag in 
    i) # custom colos palette name
        if [[ "$OPTARG" == *:* ]]; then
            color_palette=$(echo $OPTARG | cut -d: -f1)
            palette_type=$(echo $OPTARG | cut -d: -f2)
        else
            color_palette=$OPTARG
        fi
        yml_file="./$color_palette.yml"
        ;;
    t) # custom theme directory
        theme_dir="$OPTARG/$theme_name"
        default_theme_dir=false
        ;;
    a) # custom accent color
        accentColorName="$OPTARG"
        ;;
    g) # custom gnome-shell version
        custom_gs_version=true
        gs_version="$OPTARG"
        ;;
    s) # set theme style
        theme_style=true
        color_sheme="$OPTARG"
        ;;
    c) # flag to set compat size
        compat_flag=true
        ;;
    b) # flag to set blackness
        blackness_flag=true
        ;;
    m) # flag to use mac buttons style
        mac_buttons_flag=true
        ;;
    f) # flag to use Gnome-Shell float panel version
        float_panel_flag=true
        ;;
    o) # flag to use outline style
        outline_flag=true
        ;;
    d) # debug flag
        debug_flag=true
        ;;
    h)
        print_help
        exit 0;
        ;;
    \?) #print error and exit
        echo -e "${red}Invalid option: -$OPTARG Use -h for help - exiting.."
        exit 1
        ;;
  esac
done


if [[ ! $color_palette == "" ]]; then
  verify_palette_type
  verify_palette_name
  download_palette
fi

verify_yml_file
verify_or_create_theme_dir $theme_dir
verify_accent_color $accentColorName
verify_gs_version
verify_dependencies
verify_style

read_colors
if [[ $palette_type == "light" ]]; then
  swap_fg_bg
fi
set_accent_color
write
generate_gtk_assets

if [[ $compat_flag == true ]]; then
    compact_size
fi

if [[ $blackness_flag == true ]]; then
    blackness_color
fi

if [[ $mac_buttons_flag == true ]]; then
    macos_buttons
fi

if [[ $float_panel_flag == true ]]; then
    float_panel
fi

if [[ $outline_flag == true ]]; then
    outline_style
fi

set_gnome_shell_version

generate_index_theme
install_theme

if [[ $link_gtk4_flag == true ]]; then
    link_gtk4
fi



echo "end"