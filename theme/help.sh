print_help() {
	cat <<EOF
Usage: $0 [OPTION]...

OPTIONS:
  -i DIR          Specify path to yml file with color palette (Default: ./test.yml)

  -o, DIR         Specify directory for theme output (Default: ./Dynamic-Color-GTK-Theme)

  -a VARIANT      Specify theme color variant ("red" "orange" "yellow" "green" "cyan" "blue" "purlple" "pink"] (Default: "orange")

  -l              flag ro use light theme

  -d              flag to enable debug mode (print debug info)

  -h, --help              Show help
EOF
}