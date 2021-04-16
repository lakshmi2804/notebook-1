Notebook_Path_in_Git=$1
Target_Path_in_Databricks=$2
WORKSPACE=$3
git_url=$4
Git_Branch=$5
Git_Url=`echo $git_url | cut -d "/" -f5 | cut -d "." -f1`

Git_Branch=`echo $Git_Branch | cut -d '/' -f1`


user=$(echo `cat $WORKSPACE/folder1.sh` | cut -d ' ' -f4-)
#test=`echo "$user" | cut -d ' ' -f4-`

echo "$user"
cd $WorkSpace
da=`date +%m-%d-%Y-%T`
date=`date +%m-%d-%Y`
da1=`date +%T`
mkdir -p $WORKSPACE/notebooks_copy/notebook_$da



for i in $Notebook_Path_in_Git
do
  echo "$i" >> $WORKSPACE/test1
done

for i in $Target_Path_in_Databricks
do
  echo "$i" >> $WORKSPACE/test2
done

set -f
IFS='
'
set -- $(cat $WORKSPACE/test2)
for i in `cat $WORKSPACE/test1`
do
    cd $WORKSPACE/$Git_Branch/$Git_Url/
   # test=$WORKSPACE/$b/$a/$i
    if [ -d "$i" ]; then
        a=`echo "$1" | rev | awk -F'/' '{ print $1 }' | rev`
        echo "******************* Copying files from Databricks to Local *********************"
        databricks workspace export_dir $1 $WORKSPACE/notebooks_copy/notebook_$da/$a
        echo "\n\n"
        echo " ******************* Deleting Databricks Folder *********************"
        echo "$1/"
        databricks workspace delete -r  $1/
        echo "\n\n"
        echo " ******************* Copying Folder from Git to Databricks *********************"
        databricks workspace import_dir $WORKSPACE/$Git_Branch/$Git_Url/$i -o $1
        echo "\n\n"
    else
        a=`echo "$1" | rev | awk -F'/' '{ print $1 }' | rev`
        b=`echo "$1" | rev | cut -d '/' -f2- | rev`
        echo " ******************* Copying Notebooks from Databricks to Local *********************"
        echo "databricks workspace export $1 $WORKSPACE/notebooks_copy/notebook_$da"
        databricks workspace export $1 $WORKSPACE/notebooks_copy/notebook_$da
        echo "\n\n"
        echo " ******************* Copying Notebooks from Git to Databricks *********************"
        echo "databricks workspace import -l PYTHON -f SOURCE $WORKSPACE/$Git_Branch/$Git_Url/$i -o $1"
        databricks workspace import -l PYTHON -f SOURCE $WORKSPACE/$Git_Branch/$Git_Url/$i -o $1
        echo "\n\n"
        #databricks workspace import -l PYTHON -f SOURCE $WORKSPACE/$Git_Branch/$Git_Url/$i -o $1
    fi
  #  cp -r $WORKSPACE/$b/$a/$i $WORKSPACE/notebooks_copy/notebook_$da/
shift
done
echo " ******************* Copying Notebooks from Local to Migration Backup Folder *********************"
databricks workspace import_dir $WORKSPACE/notebooks_copy/notebook_$da /Users/email.com/Migration-Backup/$date/$user-$da1
echo "\n\n"

#FILE=/etc/resolv.conf
#if [ -f "$FILE" ]; then
 #   echo "$FILE exists."
#fi
