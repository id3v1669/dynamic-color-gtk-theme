#! /usr/bin/env bash

for theme in '' '-Purple' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Blue' '-Grey'; do
    for color in '' '-Dark'; do
        for type in '' '-Storm' '-Moon'; do
            if [[ "$color" == '' ]]; then
                case "$theme" in
                    '')
                        theme_color='#fe8019'
                        ;;
                    -Purple)
                        theme_color='#9d7cd8'
                        ;;
                    -Pink)
                        theme_color='#ff007c'
                        ;;
                    -Red)
                        theme_color='#f7768e'
                        ;;
                    -Orange)
                        theme_color='#ff9e64'
                        ;;
                    -Yellow)
                        theme_color='#e0af68'
                        ;;
                    -Green)
                        theme_color='#9ece6a'
                        ;;
                    -Blue)
                        theme_color='#7aa2f7'
                        ;;
                    -Grey)
                        theme_color='#282828'
                        ;;
                esac

                if [[ "$type" == '-Storm' ]]; then
                    background_color='#ebdbb2'

                    case "$theme" in
                        '')
                            theme_color='#29a4bd'
                            ;;
                        -Purple)
                            theme_color='#9d7cd8'
                            ;;
                        -Pink)
                            theme_color='#ff007c'
                            ;;
                        -Red)
                            theme_color='#f7768e'
                            ;;
                        -Orange)
                            theme_color='#ff9e64'
                            ;;
                        -Yellow)
                            theme_color='#e0af68'
                            ;;
                        -Green)
                            theme_color='#9ece6a'
                            ;;
                        -Blue)
                            theme_color='#7aa2f7'
                            ;;
                        -Grey)
                            theme_color='#24283b'
                            ;;
                    esac
                fi

                if [[ "$type" == '-Moon' ]]; then
                    background_color='#c8d3f5'

                    case "$theme" in
                        '')
                            theme_color='#589ed7'
                            ;;
                        -Purple)
                            theme_color='#c099ff'
                            ;;
                        -Pink)
                            theme_color='#fca7ea'
                            ;;
                        -Red)
                            theme_color='#ff757f'
                            ;;
                        -Orange)
                            theme_color='#ff966c'
                            ;;
                        -Yellow)
                            theme_color='#ffc777'
                            ;;
                        -Green)
                            theme_color='#c3e88d'
                            ;;
                        -Blue)
                            theme_color='#3e68d7'
                            ;;
                        -Grey)
                            theme_color='#222436'
                            ;;
                    esac
                fi
            else
                case "$theme" in
                    '')
                        theme_color='#af3a03'
                        ;;
                    -Purple)
                        theme_color='#7847bd'
                        ;;
                    -Pink)
                        theme_color='#d20065'
                        ;;
                    -Red)
                        theme_color='#cc241d'
                        ;;
                    -Orange)
                        theme_color='#b15c00'
                        ;;
                    -Yellow)
                        theme_color='#8c6c3e'
                        ;;
                    -Green)
                        theme_color='#587539'
                        ;;
                    -Blue)
                        theme_color='#7aa2f7'
                        ;;
                    -Grey)
                        theme_color='#ebdbb2'
                        ;;
                esac

                if [[ "$type" == '-Storm' ]]; then
                    background_color='#24283b'

                    case "$theme" in
                        '')
                            theme_color='#af3a03'
                            ;;
                        -Purple)
                            theme_color='#7847bd'
                            ;;
                        -Pink)
                            theme_color='#d20065'
                            ;;
                        -Red)
                            theme_color='#cc241d'
                            ;;
                        -Orange)
                            theme_color='#b15c00'
                            ;;
                        -Yellow)
                            theme_color='#8c6c3e'
                            ;;
                        -Green)
                            theme_color='#587539'
                            ;;
                        -Blue)
                            theme_color='#2e7de9'
                            ;;
                        -Grey)
                            theme_color='#ebdbb2'
                            ;;
                    esac
                fi

                if [[ "$type" == '-Moon' ]]; then
                    background_color='#222436'

                    case "$theme" in
                        '')
                            theme_color='#af3a03'
                            ;;
                        -Purple)
                            theme_color='#7847bd'
                            ;;
                        -Pink)
                            theme_color='#d20065'
                            ;;
                        -Red)
                            theme_color='#cc241d'
                            ;;
                        -Orange)
                            theme_color='#b15c00'
                            ;;
                        -Yellow)
                            theme_color='#8c6c3e'
                            ;;
                        -Green)
                            theme_color='#587539'
                            ;;
                        -Blue)
                            theme_color='#2e7de9'
                            ;;
                        -Grey)
                            theme_color='#c8d3f5'
                            ;;
                    esac
                fi
            fi

            if [[ "$type" != '' ]]; then
                cp -r "assets${color}.svg" "assets${theme}${color}${type}.svg"
                if [[ "$color" == '' ]]; then
                    sed -i "s/#fe8019/${theme_color}/g" "assets${theme}${color}${type}.svg"
                else
                    sed -i "s/#af3a03/${theme_color}/g" "assets${theme}${color}${type}.svg"
                fi
            elif [[ "$theme" != '' ]]; then
                cp -r "assets${color}.svg" "assets${theme}${color}.svg"
                if [[ "$color" == '' ]]; then
                    sed -i "s/#fe8019/${theme_color}/g" "assets${theme}${color}.svg"
                else
                    sed -i "s/#af3a03/${theme_color}/g" "assets${theme}${color}.svg"
                fi
            fi

        done
    done
done

echo -e "DONE!"
