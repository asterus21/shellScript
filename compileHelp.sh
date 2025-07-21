#!/bin/bash

######### the list of the constant values #########

# path to the 'comlicbits.h' file
declare pathLisence=D:\\pa_config\\comlicbits.h

# path to the build file for the script
declare dataSourceWin=C:\\pa6autotests\\Builds

# path to the build file for the command line
declare dataSource=/c/pa6autotests/Builds

# path to the main script file
declare helpScript=D:\\gitbash\\help\\testBuild.cmd

# you may change the variable values according to your needs
# the build.cmd is not used
# as it does not copy any PDF files

######### the list of the functions #########

# print the current time and the following string
print() {
  printf '%(%Y/%m/%d %H:%M:%S)T ' # current time
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

builds=()

for entry in "$dataSource"/*
  do
    builds+=("$entry")
  done

######### the script starts here #########

print "Starting the script..."
print "Getting a list of folders..."
print "Note that there can be several builds in the folder."
print "The list of the builds in the folder is given below:"

for entry in "$dataSource"/*
  do  
    print "$entry"
  done

print "Type a build number to process, e.g. 30251."
print "Type 'exit' to close the script."
printf '%(%Y/%m/%d %H:%M:%S)T '

read -r buildNumber

case "$buildNumber" in
  "exit" ) printExit && exit 1;;
  "Exit" ) printExit && exit 1;;
  "EXIT" ) printExit && exit 1;;
  "ext"  ) printExit && exit 1;;
  "учше" ) printExit && exit 1;;
  "УЧШЕ" ) printExit && exit 1;;
esac

buildPath="${dataSourceWin}\\${buildNumber}"

print "The build folder path: ${buildPath}"

if [ -d "$buildPath" ]; then
  print "Check whether the build folder exists..."
    build=$buildPath
    
  else
    print "The build folder does not exist."
    printExit
    exit 1
fi

if [ -z "$( ls -A "$build" )" ]; then
   print "Check whether the build folder is empty..."
   print "The build folder is empty."
   print "The program is about to exit..."
   printExit
   exit 0
else
   print "Check whether the build folder is empty..."
   print "Note that the script can take several minutes."
   print "The script is about to start..."
   askSure
   echo ""
fi

# although the original build.cmd is not used, PDF files are not copied
# that's why we need to cut them before the script starts and insert afterwards

# path to the nodejs to compile the User Manual with the TM API specification
nodeJS="${buildPath}\\Bin64\\nodejs"

mv "${buildPath}\\SourceData\\www\\help\\pdf" "${buildPath}\\SourceData\\www"

export SOURCEDATA=${buildPath}\\SourceData
export COMLICBITSPATH=${pathLisence}
export MISHARED=${nodeJS}

$helpScript

mv "${buildPath}\\SourceData\\www\\pdf" "${buildPath}\\SourceData\\www\\help"
