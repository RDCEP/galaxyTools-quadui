#! /bin/bash

inputType=$1
domeType=$2
surveyData=$3
wthDataPackage=$4
culDataPackage=$5
supDataPackage=$6
fieldDome=$7
if [ "$domeType" == "seasonal" ]
then
  if [ "$inputType" == "zip" ]
  then
    seasonalDome=$8
    linkage=$9
    batchDome=${10}
    outputJson=${11}
    outputCul=${12}
    culSource=${13}
  else
    seasonalDome=$7
    linkage=$8
    batchDome=$9
    outputJson=${10}
    outputCul=${11}
    culSource=${12}
  fi
else
  seasonalDome=""
  linkage=$8
  batchDome=$9
  outputJson=${10}
  outputCul=${11}
  culSource=${12}
fi
supDataFlg=false

echo input_type: $inputType
echo dome_type: $domeType
echo survey_data: $surveyData
echo supDataPackage: $supDataPackage
echo field_overlay_dome: $fieldDome
echo seasonal_strategy_dome: $seasonalDome
echo linkage: $linkage
echo batchDome: $batchDome
echo cultivar source: $culSource
echo output JSON: $outputJson
echo output Cultivar: $outputCul

# read supplementary data packages and prepare survey data package
mkdir tmp
mkdir aceb_output
declare -i countW
declare -i countC
declare -i countS
declare -i count
countW=0
countC=0
countS=0
count=0
#if [ "$inputType" == "zip" ]
#then
  while read line
  do
    data=`echo $line|awk '{ print $1 }'`
    if [ $countW -gt 0 ]
    then
      count=$count+1
      echo $count wth_data_$countW: $data
      cp $data $count.zip
      mkdir tmp/$count
      unzip -o -q $count.zip -d tmp/$count/
    fi
    countW=$countW+1
  done < "$wthDataPackage"
  while read line
  do
    data=`echo $line|awk '{ print $1 }'`
    if [ $countC -gt 0 ]
    then
      count=$count+1
      echo $count cul_data_$countC: $data
      cp $data $count.zip
      mkdir tmp/$count
      unzip -o -q $count.zip -d tmp/$count/
    fi
    countC=$countC+1
  done < "$culDataPackage"
  while read line
  do
    data=`echo $line|awk '{ print $1 }'`
    if [ $countS -gt 0 ]
    then
      count=$count+1
      echo $count sup_data_$countS: $data
      cp $data $count.zip
      mkdir tmp/$count
      unzip -o -q $count.zip -d tmp/$count/
    fi
    countS=$countS+1
  done < "$supDataPackage"
  if [ $count -gt 1 ]
  then
    supDataFlg=true
    count=$count+1
    if [ "$inputType" == "zip" ]
    then
      cp $surveyData $count.zip
      mkdir tmp/$count
      unzip -o -q $count.zip -d tmp/$count/
    else
      cp $surveyData tmp/$count.aceb
    fi
  fi
#else
#  while read line
#  do
#    data=`echo $line|awk '{ print $1 }'`
#    if [ $count -gt 0 ]
#    then
#      echo sup_acebData_$count: $data
#      cp $data tmp/$count.aceb
#    fi
#    count=$count+1
#  done < "$supDataPackage"
#  if [ $count -gt 1 ]
#  then
#    supDataFlg=true
#    cp $surveyData tmp/$count.aceb
#  fi
#fi
if [ $supDataFlg == true ]
then
  cd tmp
  zip -r -q ../survey.zip *
  cd ..
else
  if [ "$inputType" == "zip" ]
  then
    cp -f $surveyData $PWD/survey.zip
  else
    cp -f $surveyData $PWD/survey.aceb
  fi
fi

#INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_DIR=/mnt/galaxyTools/quadui/1.3.3
quadui=quadui-1.3.5-beta1.jar
c3mp_batch=C3MP_Sensitivity.csv
ln -sf $INSTALL_DIR/$quadui
ln -sf $INSTALL_DIR/$c3mp_batch

if [ "$inputType" == "zip" ]
then
  if [ "$domeType" == "seasonal" ]
  then
    cp -f $fieldDome $PWD/overlay.zip
    cp -f $seasonalDome $PWD/strategy.zip
    cp -f $linkage $PWD/linkage.csv
    cp -f $batchDome $PWD/batch.csv
    java -jar $quadui -cli -clean -s -batch -J "survey.zip" "linkage.csv" "overlay.zip" "strategy.zip" "batch.csv" $PWD/output
  else
    cp -f $fieldDome $PWD/overlay.zip
    cp -f $linkage $PWD/linkage.csv
    cp -f $batchDome $PWD/batch.csv
    java -jar $quadui -cli -clean -f -batch -J "survey.zip" "linkage.csv" "overlay.zip" "batch.csv" $PWD/output
  fi
else
  if [ "$domeType" == "seasonal" ]
  then
    cp -f $fieldDome $PWD/1.dome
    cp -f $linkage $PWD/1.alnk
    cp -f $batchDome $PWD/batch.csv
    if [ $supDataFlg == true ]
    then
      java -jar $quadui -cli -clean -s -batch -J "survey.zip" "1.alnk" "1.dome" "1.dome" "batch.csv" $PWD/output
    else
      java -jar $quadui -cli -clean -s -batch -J "survey.aceb" "1.alnk" "1.dome" "1.dome" "batch.csv" $PWD/output
    fi
  else
    cp -f $surveyData $PWD/survey.aceb
    cp -f $fieldDome $PWD/1.dome
    cp -f $linkage $PWD/1.alnk
    cp -f $batchDome $PWD/batch.csv
    if [ $supDataFlg == true ]
    then
      java -jar $quadui -cli -clean -f -batch -J "survey.zip" "1.alnk" "1.dome" "batch.csv" $PWD/output
    else
      java -jar $quadui -cli -clean -f -batch -J "survey.aceb" "1.alnk" "1.dome" "batch.csv" $PWD/output
    fi
  fi
fi

rm -f $quadui
mkdir ./outputJsons
cd output
for dir in batch-*/; do
{
	cd $dir
	batchId=${dir#*-}
	batchId=${batchId%/}
	for file in *.json; do
	{
		filename="${file%.*}"
		cp $filename.json ../../outputJsons/$batchId.json
	}
	done
	cd ..
}
done
cd ..
cd outputJsons
zip -r -q ../outputJson.zip * 
cd ..
cp outputJson.zip $outputJson

# Handling cultivar files
if [ "$culSource" == "customized" ]
then
  if [ "$inputType" == "zip" ] || [ $supDataFlg == true ]
  then
    unzip -o -q survey.zip -d survey/
    cd survey
    dirs=`find -type d -name *_specific`
    if [ "$dirs" == "" ]
    then 
      echo "[Warn] Could not find model specific diretory in the cultivar package, will using default cultivar loaded in the system"
    else
      echo "Find model specific folders: $dirs"
      mkdir ./cul
      for dir in $dirs
      do
        if [ -d "$dir" ]
        then
          newDir=./cul/`basename $dir`
          if [ ! -d "$newDir" ]
          then
            mkdir $newDir
          fi
          mv -f $dir/* $newDir/.
        fi
      done
      cd cul
      zip -r -q ../../retCul.zip *
      cd ..
      cd ..
      cp retCul.zip $outputCul
    fi
  else
    echo inputType: $inputType
    echo supDataFlg: $supDataFlg
    echo "[Warn] Invalid selection for cultivar source, please choose system default or provide cultivar files in the supplementary data file"
  fi
else
	echo "No need to generate cultivar package, will use system default"
fi

echo inputType: $inputType
echo supDataFlg: $supDataFlg