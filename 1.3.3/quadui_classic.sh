#! /bin/bash

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
INSTALL_DIR=/mnt/galaxyTools/quadui/1.3.3
quadui=quadui-1.3.3.jar
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