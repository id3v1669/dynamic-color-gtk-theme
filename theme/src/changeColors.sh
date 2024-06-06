#!/usr/bin/env bash

#----------------------------------------#
##############Terminal Colors#############
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
bc="\033[7m"
defaultColour="\033[0m"
#----------------------------------------#

# array of allowed contrast colors
accentColorsWhitelist=("red" "orange" "yellow" "green" "cyan" "blue" "purlple" "pink")
accentColorName="orange"                   # default accent color
declare -A accentColors                    # declare an associative array to store the contrast colors

input_dir="./assets"
output_dir="./assets-colored"
test_yml="./test.yml"

declare -A baseColors                      # declare an associative array to store the base colors
#----------------------------------------#


#----------------------------------------#
##################Write###################
write() {
    # Recreate dest dir
    rm -rf "$output_dir"
    mkdir -p "$output_dir"
    # Copy all files from input dir to dest with color replacements
    find "$input_dir" -type f | while read -r file; do
        target_file="$output_dir/${file#$input_dir/}"
        echo -e "${green}Writing $target_file"
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
  done < <(grep -oE 'base[0-9A-Fa-f]{2}: "[0-9A-Fa-f]{6}"*' $test_yml)
}
#----------------------------------------#

#----------------------------------------#
###############Accent color###############
verify_accent_color() {
  if [[ ! " ${accentColorsWhitelist[@]} " =~ " $accentColorName " ]]; then
    echo -e "${red}Invalid accent color: $accentColorName."
    exit 1
  fi
}
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
##################Flags###################
# Check for flags
while getopts ":i:o:c:a:l:h" flag; do #
  case $flag in 
    i) #flag to have a custom input directory
      input_flag=true
      ;;
    o) #flag to have a custom output directory
      out_flag=true
      ;;
    c) #flag to have a custom color yml file
      colors_flag=true
      ;;
    a) #flag to have a custom accent color
      accentColorName="$OPTARG"
      echo "Accent color: $accentColorName"
      verify_accent_color $accentColorName
      ;;
    l) #flag to set light theme
      theme="light"
      ;;
    h)
      help_flag=true
      ;;
    \?) #print error and exit
      echo -e "${red}Invalid option: -$OPTARG Use -h for help - exiting.."
      exit 1
      ;;
  esac
done
#----------------------------------------#

echo "start"

# if [ ! "$(which sassc 2>/dev/null)" ]; then
# 	echo sassc needs to be installed to generate the css.
# fi
#----------------------------------------#
##################Main####################
read_colors
set_accent_color
write
#----------------------------------------#



# tests

print_baseColors() {
  for key in "${!baseColors[@]}"; do
    echo "$key: ${baseColors[$key]}"
  done
}