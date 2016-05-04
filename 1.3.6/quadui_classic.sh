#! /bin/bash

# Check if the variable PACKAGE_BASE has been set in env.sh
if [ -z "$PACKAGE_BASE" ];
then
  echo "source env.sh before running this script"
  exit
fi

# Check if the number of parameters is correct
if [ $# -lt 4 ]
then
    echo "Usage: $0 inputType domeType surveyData fieldDome [...]"
    exit -1
fi

# If needed, trap the tool scratch directory somewhere else
THISDIR=`pwd`
#THISDIR="/scratch/wrf/sandbox/quadui/"
cd $THISDIR

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Save a copy of a command line for fast debug
cat > `basename $0`.cmd << EOF
source $DIR/env.sh
$0 $@
EOF

chmod +x `basename $0`.cmd

# The actual script begins here
###############################


inputType=$1
domeType=$2
surveyData=$3
fieldDome=$4
if [ "$domeType" == "seasonal" ]
then
  if [ "$inputType" == "zip" ]
  then
    seasonalDome=$5
    linkage=$6
    outputDssat=$7
    outputApsim=$8
  else
    seasonalDome=$4
    linkage=$5
    outputDssat=$6
    outputApsim=$7
  fi
else
  seasonalDome=""
  linkage=$5
  outputDssat=$6
  outputApsim=$7
fi

echo input_type: $inputType
echo dome_type: $domeType
echo survey_data: $surveyData
echo field_overlay_dome: $fieldDome
echo seasonal_strategy_dome: $seasonalDome
echo linkage: $linkage
echo output DSSAT: $outputDssat
echo output APSIM: $outputApsim


#INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_DIR=/mnt/galaxyTools/quadui/1.3.6
quadui=quadui-1.3.7-faceit.jar
ln -sf $INSTALL_DIR/$quadui

if [ "$inputType" == "zip" ]
then
  if [ "$domeType" == "seasonal" ]
  then
    cp -f $surveyData $PWD/survey.zip
    cp -f $fieldDome $PWD/overlay.zip
    cp -f $seasonalDome $PWD/strategy.zip
    cp -f $linkage $PWD/linkage.alnk
    java -jar $quadui -cli -clean -s -DA "survey.zip" "linkage.alnk" "overlay.zip" "strategy.zip" "./"
	else
    cp -f $surveyData $PWD/survey.zip
    cp -f $fieldDome $PWD/overlay.zip
    cp -f $linkage $PWD/linkage.alnk
    java -jar $quadui -cli -clean -f -DA "survey.zip" "linkage.alnk" "overlay.zip" "./"
  fi
else
  if [ "$domeType" == "seasonal" ]
  then
    cp -f $surveyData $PWD/1.aceb
    cp -f $fieldDome $PWD/1.dome
    cp -f $linkage $PWD/1.alnk
    java -jar $quadui -cli -clean -s -DA "1.aceb" "1.alnk" "1.dome" "1.dome" $PWD
  else
    cp -f $surveyData $PWD/1.aceb
    cp -f $fieldDome $PWD/1.dome
    cp -f $linkage $PWD/1.alnk
    java -jar $quadui -cli -clean -f -DA "1.aceb" "1.alnk" "1.dome" $PWD
  fi
fi

rm -f $quadui
cd DSSAT
zip -r -q ../retD.zip *
cd ..
cp retD.zip $outputDssat
cd APSIM
zip -r -q ../retA.zip *
cd ..
cp retA.zip $outputApsim
