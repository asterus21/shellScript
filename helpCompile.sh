#!/bin/bash

pathLisence=D:\\pa_config\\comlicbits.h
dataSource_WIN=C:\\pa6autotests\\Builds
dataSource=/c/pa6autotests/Builds
HELP=/d/gitbash/help/build.cmd

partPath=/dataSource

builds=()

# print the current and the following string
print() {
  printf '%(%H:%M:%S)T ' # current time
  echo "$1"
}

printExit() {
  print "Exiting..." && print "Exited"
}

# ask the user to continue
askSure() {
  
  print "Are you sure you want to continue (Y/N)? "
  while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && retval=0
    [[ $answer = [Nn] ]] && printExit && exit 0 
      break
    fi
  done

return "$retval"
}

for entry in "$dataSource"/*
do  
  builds+=("$entry")
done

### starts here
print "Note that there can be several builds in the folder."
print "Getting a list of folders..."

for entry in "$dataSource"/*
do  
  print "$entry"
done

print "Type a build number to process, e.g. 30251."
printf '%(%H:%M:%S)T '
read -r buildNumber
buildPath="${dataSource_WIN}\\${buildNumber}"
# print $buildPath
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
   print "The build folder is not empty."
   print "The script is about to start..."
   askSure
   echo ""
fi

pathBuild="${buildPath}${partPath}"
# print "$pathBuild"

export SOURCEDATA=${pathBuild}
export COMLICBITSPATH=${pathLisence}

$HELP
