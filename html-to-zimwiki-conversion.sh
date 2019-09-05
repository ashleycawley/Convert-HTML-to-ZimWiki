#!/bin/bash

# Author: Ashley Cawley // ash@ashleycawley.co.uk // @ashleycawley
#
# Description: This script is designed to convert (OneNote) HTML files into a Zim Desktop format (ZimWiki).
# Specifically this is designed for people trying to move away from OneNote to Zim Desktop - https://zim-wiki.org/
#
# Follow this guide: https://superuser.com/a/1449705 to export your OneNote Notebook as HTML files and then you can
# use this script to convert those HTML files into a format compatible with Zim Desktop (ZimWiki Markup).
#
# This script backs-up your HTML files before doing its work. It fixes formatting/layout issues, moves & renames
# files & folders into the correct hireachry, embeds document titles in articles, cleans up files afterwards and 
# much more. I have commented code where I can to explain the process step by step.

# OneNote Export Folder
ONENOTE_EXPORT_FOLDER='/home/acawley/Notebooks/testing/cloudabove' # Configure to point at your Exported OneNote Notebook

# Tests to see if you are logged in as root, if you are it stops. (A standard user is prefered)
if
[ `whoami` == root ]
then
	echo "Please do not run this script as root. Please re-run the script as a normal user."
	exit 1
fi

# A check to ensure the correct software is already installed
declare -r U_CMDS="pandoc tar grep rsync find sed"
for the_command in $U_CMDS
do
        type -P $the_command >> /dev/null && : || {
        echo -e "$the_command command was not found, please install it $the_command and then try using this script again." >&2
        exit 1
    }
done

# Functions

# Takes input via arguement and swaps out any spaces for underscores
function SWAP_SPACES_FOR_UNDERSCORES () {
	sed 's/ /_/g'
}

SAVEIFS=$IFS

# Changing the delimiter used by arrays from a space to a new line, this allows my for loops to iterate through a vertical list provided by the likes of ls -1
IFS=$'\n'

echo "" # Just creating a space from the last line

# This stores script-name.sh inside the variable $SCRIPTNAME
SCRIPTNAME=`basename "$0"`

# Archive / Backup of original file set before processing
tar --exclude="$ONENOTE_EXPORT_FOLDER/pre-conversion-backup-`date +"%d-%m-%y_%T"`.tar.gz" -zcvf $ONENOTE_EXPORT_FOLDER/pre-conversion-backup-`date +"%d-%m-%y_%T"`.tar.gz $ONENOTE_EXPORT_FOLDER

# Gathers list of top level folder names whilst excluding this script from the list
LVL1_FOLDER_NAMES=(`ls -1 $ONENOTE_EXPORT_FOLDER | grep -v $SCRIPTNAME`)

# Main for loop which iterates through all of the various folders to do the work
for FOLDER_NAME in "${LVL1_FOLDER_NAMES[@]}"
do
	SECOND_LVL_FOLDERS=(`ls -1 $FOLDER_NAME`)

	for SECOND_FOLDER in "${SECOND_LVL_FOLDERS[@]}"
	do
		# Removing number prefixes like: 23_ 24_ etc.
		SECOND_FOLDER_SANITISED=(`echo $SECOND_FOLDER | cut -d '_' -f2-`)

		# Renaming document title / file from main.html to whatever the folder name is
		mv "$FOLDER_NAME/$SECOND_FOLDER/main.html" "$FOLDER_NAME/$SECOND_FOLDER/$SECOND_FOLDER_SANITISED.html" &>/dev/null

		STATUS=(`echo $?`)

		# Setting up communal image directory
		mkdir -p $FOLDER_NAME/$SECOND_FOLDER/images/

		# Copies image files out of subdirectory and into one central image folder that Zim can use and reference
		rsync -ah --remove-source-files $FOLDER_NAME/$SECOND_FOLDER/images/ $FOLDER_NAME/images/ &>/dev/null

		if [ $STATUS != 0 ]
		then

			THIRD_LEVEL_FOLDER=(`ls -1 $FOLDER_NAME/$SECOND_FOLDER/`)

			# Removing number prefixes like: 23_ 24_ etc.
			THIRD_LEVEL_FOLDER=(`echo $THIRD_LEVEL_FOLDER | cut -d '_' -f2-`)

			# echo "Going to a Third Level:"

			# Sanitises the filename replacing spaces with underscores
			FILENAME_WITH_UNDERSCORES=(`echo "$THIRD_LEVEL_FOLDER" | SWAP_SPACES_FOR_UNDERSCORES`)

			# echo "mv $FOLDER_NAME/$SECOND_FOLDER/$THIRD_LEVEL_FOLDER/main.html $FOLDER_NAME/$SECOND_FOLDER/$THIRD_LEVEL_FOLDER/$FILENAME_WITH_UNDERSCORES.html"
			mv "$FOLDER_NAME/$SECOND_FOLDER/$THIRD_LEVEL_FOLDER/main.html" "$FOLDER_NAME/$SECOND_FOLDER/$THIRD_LEVEL_FOLDER/$FILENAME_WITH_UNDERSCORES.html"

			# Moves the document up one level as it doesn't want to be in a subfolder for itself to work with Zim nicely
			mv "$FOLDER_NAME/$SECOND_FOLDER/$THIRD_LEVEL_FOLDER/$FILENAME_WITH_UNDERSCORES.html" "$FOLDER_NAME/$SECOND_FOLDER/$FILENAME_WITH_UNDERSCORES.html"

			# Converts the document from HTML to Zim Wiki Format
			pandoc -s -r html "$FOLDER_NAME/$SECOND_FOLDER/$THIRD_LEVEL_FOLDER/$FILENAME_WITH_UNDERSCORES.html" -t zimwiki -o "$FOLDER_NAME/$SECOND_FOLDER/$FILENAME_WITH_UNDERSCORES.txt"

			# Inserts a title into the article itself
			#echo "sed -i "3i====== $SECOND_FOLDER_SANITISED ======" "$FOLDER_NAME/$SECOND_FOLDER/$FILENAME_WITH_UNDERSCORES.txt""
			sed -i "3i====== $SECOND_FOLDER_SANITISED ======" "$FOLDER_NAME/$SECOND_FOLDER/$FILENAME_WITH_UNDERSCORES.txt" # &>/dev/null
			#read -p "Pausing - Enter to continue" INPUT

		fi

		if [ $STATUS == 0 ]
		then
			# Sanitises the filename replacing spaces with underscores
			FILENAME_WITH_UNDERSCORES=(`echo "$SECOND_FOLDER_SANITISED" | SWAP_SPACES_FOR_UNDERSCORES`)
			mv "$FOLDER_NAME/$SECOND_FOLDER/$SECOND_FOLDER_SANITISED.html" "$FOLDER_NAME/$SECOND_FOLDER/$FILENAME_WITH_UNDERSCORES.html"

			# Moves the document up one level as it doesn't want to be in a subfolder for itself to work with Zim nicely
			mv "$FOLDER_NAME/$SECOND_FOLDER/$FILENAME_WITH_UNDERSCORES.html" "$FOLDER_NAME/$FILENAME_WITH_UNDERSCORES.html"

			# Converts the document from HTML to Zim Wiki Format
			pandoc -s -r html "$FOLDER_NAME/$FILENAME_WITH_UNDERSCORES.html" -t zimwiki -o "$FOLDER_NAME/$FILENAME_WITH_UNDERSCORES.txt"

			# Inserts a title into the article itself
			#echo "sed -i "3i====== $SECOND_FOLDER_SANITISED ======" "$FOLDER_NAME/$FILENAME_WITH_UNDERSCORES.txt""
			sed -i "3i====== $SECOND_FOLDER_SANITISED ======" "$FOLDER_NAME/$FILENAME_WITH_UNDERSCORES.txt" # &>/dev/null
			#read -p "Pausing - Enter to continue" INPUT
		fi
	done

	echo ""
done
echo ""

#  The three three commands below attempt to remove all spaces from directory names, the problem is made harder by trailing spaces or spaces at the start of a filename
find $ONENOTE_EXPORT_FOLDER -name "* *" -print0 | sort -rz | while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"; done
find $ONENOTE_EXPORT_FOLDER -name "* " -print0 | sort -rz | while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"; done
find $ONENOTE_EXPORT_FOLDER -name " *" -print0 | sort -rz | while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"; done

# Fix Broken Image Paths, the default syntax pandoc seems to be inserting for zimwiki format doesn't seem to be working, so I'm replacing it with working syntax
IMAGE_PATHS=(`grep -ril "{{:images" $ONENOTE_EXPORT_FOLDER/ | grep -v "$SCRIPTNAME"`)
for IMAGE in "${IMAGE_PATHS[@]}"
do
	sed -i s,{{:images,{{../\images,g $IMAGE
done

FILE_LIST=(`find $ONENOTE_EXPORT_FOLDER -type f -name "*.txt"`)

# Replaces doubled-up (two newlines) for just one, which makes the layout more sensible in Zim
for FILE in "${FILE_LIST[@]}"
do
	sed -i '/^$/N;/^\n$/D' $FILE
done

# Deletes empty folders after things have been moved around
find $ONENOTE_EXPORT_FOLDER -type d -empty -delete

# Deletes OneNote HTML files which are no longer needed (they've already been backed up toward the top of this script)
find $ONENOTE_EXPORT_FOLDER -type f -name "*.html" -delete

# Resets $IFS this changes the delimiter that arrays use from new lines (\n) back to just spaces (which is what it normally is)
IFS=$SAVEIFS


