#!/bin/bash
shopt -s extglob

# TODO: ./helpCompile --path or -p changes the pathLicense value (only absolute paths are allowed, otherwise a warning occures) (mind the use of slashes)
# TODO: ./helpCompile --data or -d changes both of the dataSourceWin and dataSource values (only absolute paths are allowed, otherwise a warning occures) (mind the use of slashes) (see the slashes change)
# TODO: ./helpCompile --script or -s changes the helpScript value only absolute paths are allowed, otherwise a warning occures (mind the use of slashes)

######### the list of the constants #########

# path to the license file
declare pathLicense=D:\\pa_config\\comlicbits.h

# path to the Build folder for the script
declare dataSourceWin=C:\\pa6autotests\\Builds

# path to the Build folder for the Comand Line Interface
declare dataSource=C:\\pa6autotests\\Builds

# path to the Main script file
declare helpScript=D:\\gitbash\\help\\testBuild.cmd

######### the functions in use #########

print() {
  printf '%(%Y/%m/%d %H:%M:%S)T '
  echo "$1"
}

printExit() {
  print "Exiting..." && print "Exited"
}

askSure() {

  print "Are you sure you want to continue (Y/N)?"
  while read -r -n 1 -s answer; do
  if [[ $answer = [YyNnНнТт] ]]; then
    [[ $answer = [YyНн] ]] && retval=0
    [[ $answer = [NnТт] ]] && printExit && exit 0
      break
  fi
  done

  return "$retval"
}

helpArguments() {
  print "Here is a list of arguments:"
  print "Add --help or -h to show this list of arguments."
  print "Add --list or -l to show a list of builds."
  print "Add a build number, e.g. 32534 to start the main script."
  print "Add --path or -p to change the licence path (only absolute paths are allowed)."
  print "Add --data or -d to change the server path (only absolute paths are allowed)."
  print "Add --script or -s to change the main script path (only absolute paths are allowed)."
}

listBuilds() {

  local winBase
  winBase="${dataSourceWin%\\}"

  for entry in "$dataSource"/*; do
    local buildName
    buildName=$(basename "$entry")
    print "${winBase}\\${buildName}"
  done

}

##### the script is given in a separate function #####

enteredBuild() {

  buildPath="${dataSourceWin}\\$1"
  commonCode "$buildPath"

}

commonCode() {

  local buildPath="$1"
  print "The build folder path: $buildPath"

  if [ ! -d "$buildPath" ]; then
      print "The build folder does not exist."
      printExit
      exit 1
  fi

  if [ -z "$( ls -A "$buildPath" )" ]; then
    print "Check whether the build folder is empty..."
    print "The build folder is empty."
    print "The program is about to exit..."
    printExit
    exit 0
  else
    print "Check whether the build folder is empty..."
    print "Note that the script execution can take several minutes."
    print "The script is about to start..."
    askSure
    echo ""
  fi  

  # path to the nodejs to compile the User Manual with the TM API specification
  nodeJS="$buildPath\\Bin64\\nodejs"

  # although the original build.cmd is not used, PDF files are still not copied
  # that's why we need to cut them before the script starts and insert afterwards
  mv "$buildPath\\SourceData\\www\\help\\pdf" "$buildPath\\SourceData\\www"

  export SOURCEDATA=$buildPath\\SourceData
  export COMLICBITSPATH=${pathLicense}
  export MISHARED=${nodeJS}

  $helpScript

  mv "$buildPath\\SourceData\\www\\pdf" "$buildPath\\SourceData\\www\\help"
}

mainScript() {
  print "Starting the script..."
  print "Getting a list of folders..."
  print "Note that there can be several builds in the folder."
  print "The list of the builds in the folder is given below:"
  listBuilds
  print "Type a build number to process, e.g. 30251."
  print "Type 'exit' to close the script."
  printf '%(%Y/%m/%d %H:%M:%S)T '

  read -r buildNumber

  case "$buildNumber" in
    "ext"  ) printExit && exit 0;;
    "exit" ) printExit && exit 0;;
    "Exit" ) printExit && exit 0;;
    "EXIT" ) printExit && exit 0;;
    "учш"  ) printExit && exit 0;;
    "учше" ) printExit && exit 0;;
    "Учше" ) printExit && exit 0;;
    "УЧШЕ" ) printExit && exit 0;;
  esac

  buildPath="${dataSourceWin}\\${buildNumber}"
  commonCode "$buildPath"

}

######### the input check #########

case "$1" in
    "" | " " )
        mainScript ;;
    "-l" | "--list" )
        print "Here is a list of builds:"
        listBuilds
        print "Use --help or -h to show a list of arguments."
        printExit
        exit 0 ;;
    "-h" | "--help" )
        helpArguments
        printExit
        exit 0 ;;
    *[a-zA-Z]* )
        helpArguments
        printExit
        exit 1 ;;
    *[!0-9]* )
        helpArguments
        printExit
        exit 1 ;;
    * )
        enteredBuild "$@" ;;
esac
