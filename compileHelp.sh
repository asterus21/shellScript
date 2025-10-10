#!/bin/bash
shopt -s extglob

######### the list of the constants #########

# path to the License file
declare default_path_to_license_file=D:\\license_file.h

# path to the Build folder for the script
declare default_path_to_build=C:\\builds

# path to the Main script file
declare default_path_to_main_script=D:\\help\\script.cmd

######### the functions in use #########

# timestamp print function
print() {
  printf '%(%Y/%m/%d %H:%M:%S)T '
  echo "$1"
}

# timestamp print function to exit the program
print_exit() {
  print "Exiting..." && print "Exited"
}

# function to ask a user whether they want to start the Main script
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

# function to show a list of arguments
show_arguments() {
  print "Here is a list of arguments:"
  print "Add --help or -h to show this list of arguments."
  print "Add --list or -l to show a list of builds on the default Server path."
  print "Add a build number, e.g. 32534 to start the script."
  print "Add --path or -p to change the Licence path (e.g. 'C:\my_license_folder\license.h' or C:\\\my_license_folder\\\license.h)."
  print "Add --build or -b to change the Server path (e.g. 'C:\my_builds_folder' or C:\\\my_builds_folder)."
  print "Add --script or -s to change the Main script path (e.g. 'C:\my_script_folder\my_script.cmd' or C:\\\my_script_folder\\\my_script)."
  print "Several paths flags (if needed) must be given together (./helpCompile.sh -p 'C:\my_license_folder\license.h' -b 'C:\my_builds_folder' -s 'C:\my_script_folder\my_script.cmd')."
}

# function to show a list of builds
show_builds() {
  for entry in "$default_path_to_build"/*; do
    local build_name
    build_name=$(basename "$entry")
    print "${default_path_to_build}\\${build_name}"
  done
}

# function to check whether a path is absolute
is_absolute() {
  if [[ "$1" =~ ^[a-zA-Z]:\\ ]]; then
    return 0
  else
    print "Please, use an absolute path (e.g. 'C:\my_folder' or C:\\\my_folder)."
    exit 1
  fi
}

# function to change default values
change_default_values() {
  local path_to_change=$1
  local new_path=$2

  is_absolute "$new_path"

  case "$path_to_change" in
    "license" )
      default_path_to_license_file="$new_path"
      print "License path changed to $new_path"
      ;;
    "build"   )
      default_path_to_build="$new_path"
      print "Build path changed to $new_path"
      ;;
    "script"  )
      default_path_to_main_script="$new_path"
      print "Script path changed to $new_path"
      ;;
  esac
}

# function to check paths
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
  if [ ! -d "$node_js_path" ]; then
      print "The NodeJS folder is not found."
      print_exit
      exit 1
  fi
}

# function to start the script without arguments
start_script_without_arguments() {
  print "Starting the script..."
  print "Getting a list of folders..."
  print "Note that there can be several builds in the folder."
  print "The list of the builds in the folder is given below:"
  show_builds
  print "Type a build number to process, e.g. 30251."
  print "Type 'exit' to close the script."
  printf '%(%Y/%m/%d %H:%M:%S)T '

  read -r user_input

  case "$user_input" in
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
    *[a-zA-Z]* )
      print "Enter a valid build number."
      print_exit
      exit 1 ;;
  esac

  build_path="${default_path_to_build}\\${user_input}"
  check_paths "$build_path"
  start_main_script
}

# function to start the script with a specified number
start_script_with_build_number() {
  build_path="${default_path_to_build}\\$1"
  check_paths "$build_path"
  start_main_script
}

##### the main script #####

# function to start the main script
start_main_script() {
  # PDF files are not copied, that's why we need to cut them before the script starts and insert afterwards
  mv "$build_path\\SourceData\\www\\help\\pdf" "$build_path\\SourceData\\www"

  # export of the environmental variables
  export SOURCEDATA=$build_path\\SourceData
  export COMLICBITSPATH=${default_path_to_license_file}
  export MISHARED=${node_js_path}

  # the main script call
  $default_path_to_main_script

  # PDF files are not copied, that's why we need to cut them before the script starts and insert afterwards
  mv "$build_path\\SourceData\\www\\pdf" "$build_path\\SourceData\\www\\help"
}

######### the scripts calls #########

if [[ $# -gt 0 ]]; then
  while [[ $# -gt 0 ]]; do
    case "$1" in
        "-p" | "--path"   )
          if [ -z "$2" ]; then
            print "Error: no path is specified"
            print_exit
            exit 1
          fi
          change_default_values "license" "$2"
          shift 2
          ;;
        "-b" | "--build"  )
          if [ -z "$2" ]; then
            print "Error: no path is specified"
            print_exit
            exit 1
          fi
          change_default_values "build" "$2"
          shift 2
          ;;
        "-s" | "--script" )
          if [ -z "$2" ]; then
            print "Error: no path is specified"
            print_exit
            exit 1
          fi
          change_default_values "script" "$2"
          shift 2
          ;;
        "-l" | "--list"   )
          print "Here is a list of builds:"
          show_builds
          print "Use --help or -h to show a list of arguments."
          print_exit
          exit 0 ;;
        "-h" | "--help"   )
          show_arguments
          print_exit
          exit 0 ;;
        *[a-zA-Z]*        )
          show_arguments
          print_exit
          exit 1 ;;
        *[!0-9]*          )
          show_arguments
          print_exit
          exit 1 ;;
        *                 )
          start_script_with_build_number "$@"
          exit 0 ;;
    esac
  done
else
  start_script_without_arguments
fi
