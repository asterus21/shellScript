#!/bin/bash
shopt -s extglob

# TODO: ./helpCompile --path or -p changes the path_to_license_file value (only absolute paths are allowed, otherwise a warning occures) (mind the use of slashes)
# TODO: ./helpCompile --data or -d changes both of the path_to_build_windows and path_to_build_for_command_line values (only absolute paths are allowed, otherwise a warning occures) (mind the use of slashes) (see the slashes change)
# TODO: ./helpCompile --script or -s changes the path_to_main_script value (only absolute paths are allowed, otherwise a warning occures) (mind the use of slashes)

######### the list of the constants #########

# path to the license file
declare path_to_license_file=D:\\pa_config\\comlicbits.h

# path to the Build folder for the script
declare path_to_build_windows=C:\\pa6autotests\\Builds

# path to the Build folder for the Comand Line Interface
declare path_to_build_for_command_line=C:\\pa6autotests\\Builds

# path to the Main script file
# declare path_to_main_script=D:\\gitbash\\help\\testBuild.cmd
declare path_to_main_script=D:\\gitbash\\help\\testBuild.cmd

######### the functions in use #########

print() {
  printf '%(%Y/%m/%d %H:%M:%S)T '
  echo "$1"
}

print_exit() {
  print "Exiting..." && print "Exited"
}

ask_sure() {
  print "Are you sure you want to continue (Y/N)?"
  while read -r -n 1 -s answer; do
  if [[ $answer = [YyNnНнТт] ]]; then
    [[ $answer = [YyНн] ]] && retval=0
    [[ $answer = [NnТт] ]] && print_exit && exit 0
      break
  fi
  done

  return "$retval"
}

show_arguments() {
  print "Here is a list of arguments:"
  print "Add --help or -h to show this list of arguments."
  print "Add --list or -l to show a list of builds."
  print "Add a build number, e.g. 32534 to start the script."
  print "Add --path or -p to change the licence path (only absolute paths are allowed)."
  print "Add --data or -d to change the server path (only absolute paths are allowed)."
  print "Add --script or -s to change the path to the main script (only absolute paths are allowed)."
}

show_builds() {
  local windows_path
  windows_path="${path_to_build_windows%\\}"

  for entry in "$path_to_build_for_command_line"/*; do
    local build_name
    build_name=$(basename "$entry")
    print "${windows_path}\\${build_name}"
  done
}

##### the script is given in a separate function #####

start_script_with_build_number() {
  build_path="${path_to_build_windows}\\$1"
  check_paths "$build_path"
}

start_main_script() {
  $path_to_main_script
}

check_paths() {
  build_path="$1"
  print "The build folder path: $build_path"

  if [ ! -d "$build_path" ]; then
      print "The build folder does not exist."
      print_exit
      exit 1
  fi

  if [ -z "$( ls -A "$build_path" )" ]; then
    print "Check whether the build folder is empty..."
    print "The build folder is empty."
    print "The program is about to exit..."
    print_exit
    exit 0
  else
    print "Check whether the build folder is empty..."
    print "Note that the script execution can take several minutes."
    print "The script is about to start..."
    ask_sure
    echo ""
  fi  

  # path to the nodejs to compile the User Manual with the API specification
  node_js_path="$build_path\\Bin64\\nodejs"

  # PDF files are not copied, that's why we need to cut them before the script starts and insert afterwards
  mv "$build_path\\SourceData\\www\\help\\pdf" "$build_path\\SourceData\\www"

  export SOURCEDATA=$build_path\\SourceData
  export COMLICBITSPATH=${path_to_license_file}
  export MISHARED=${node_js_path}

  start_main_script

  mv "$build_path\\SourceData\\www\\pdf" "$build_path\\SourceData\\www\\help"
}

start_script() {
  print "Starting the script..."
  print "Getting a list of folders..."
  print "Note that there can be several builds in the folder."
  print "The list of the builds in the folder is given below:"
  show_builds
  print "Type a build number to process, e.g. 30251."
  print "Type 'exit' to close the script."
  printf '%(%Y/%m/%d %H:%M:%S)T '

  read -r build_number

  case "$build_number" in
    "ext"  )
      print_exit
      exit 0 ;;
    "exit" )
      print_exit
      exit 0 ;;
    "Exit" )
      print_exit
      exit 0 ;;
    "EXIT" )
      print_exit
      exit 0 ;;
    "учш"  )
      print_exit
      exit 0 ;;
    "учше" )
      print_exit
      exit 0 ;;
    "Учше" )
      print_exit
      exit 0 ;;
    "УЧШЕ" )
      print_exit
      exit 0 ;;
  esac

  build_path="${path_to_build_windows}\\${build_number}"
  check_paths "$build_path"
}

######### the input check #########

case "$1" in
    "" | " " )
      start_script ;;
    "-l" | "--list" )
      print "Here is a list of builds:"
      show_builds
      print "Use --help or -h to show a list of arguments."
      print_exit
      exit 0 ;;
    "-h" | "--help" )
      show_arguments
      print_exit
      exit 0 ;;
    *[a-zA-Z]* )
      show_arguments
      print_exit
      exit 1 ;;
    *[!0-9]* )
      show_arguments
      print_exit
      exit 1 ;;
    * )
      start_script_with_build_number "$@" ;;
esac
