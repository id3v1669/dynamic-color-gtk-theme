#! /usr/bin/env bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

./make-thumbnails.sh

for theme in '' '-Purple' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Blue' '-Grey'; do
    for type in '' '-Storm' '-Moon'; do
        SRC_FILE="thumbnail${theme}${type}.svg"
        for color in '' '-Dark'; do
            echo
            echo Rendering thumbnail${theme}${type}${color}.png
            $INKSCAPE --export-id=thumbnail \
                --export-id-only \
                --export-dpi=96 \
                --export-filename=thumbnail2.png $SRC_FILE >/dev/null &&
            $OPTIPNG -o7 --quiet thumbnail2.png
        done
    done
done

for theme in '' '-Purple' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Blue' '-Grey'; do
    for type in '' '-Storm' '-Moon'; do
        if [[ ${theme} == '' && ${type} == '' ]]; then
            echo "keep thumbnail.svg"
        else
            rm -rf "thumbnail${theme}${type}.svg"
        fi
    done
done

exit 0
