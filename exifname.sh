#! /usr/bin/env bash

#https://medium.com/sysf/bash-scripting-everything-you-need-to-know-about-bash-shell-programming-cd08595f2fba#:~:text=Normally%2C%20a%20Bash%20script%20file,is%20a%20shell%20script%20file.
# math
# result=1+1          # 1+1
# let result=1+1      # 2
# result=$((1+1))     # 2
# result=$(("1+1"))   # 2

# if-then structure
# for strings: use  ==,  !=,   <,   >
# for numbers: use -eq, -ne, -lt, -gt
# for empty or not empty: -z, -n
# if [ 'hi' == 'hi' ]; then echo 'yes it does'; fi
# if ([ 5 -lt 9 ] && [ 6 -gt 5 ]) || [ 1 -gt 2 ])        # if (5<9 and 6>5) or (1>2) 
# then
#    # code
# elif [ another conditional ]
#    # code
# else
#    # code
# fi

# for loop
# for (( i=0; i<5; i++ )); do; echo $i; done

# while loop

# until loop


# exiftool to edit picture meta data
# downloaded Windows version of exiftool
# in .bashrc:    alias exiftool='/c/Windows/exiftool.exe'
# example commands: https://exiftool.org/examples.html
# to see (extract) all info from a jpg
#     exiftool a.jpg
# to see particular info
#     exiftool a.jpg | grep -i gps
# to write Artist tag to a.jpg
#     exiftool -artist="my name" a.jpg
# add path to "Directory" metadata


# identify current folder
original=`pwd`

# list each file with full path
# local files=`find . -name \*.jpg -print`  # relative path
files=`find ~+ -type f -name \*.jpg -print`  # absolute path

# need to first fix the problem of spaces in folder names
# temporarily replace $IFS variable which, by default, sets a space to a field delimiter
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# rename each file
for file in $files
do
    echo ""
    echo "file          =" $file
    
    # extract picture name
    picture=`basename "$file"`
    echo "picture       =" $picture

    # extract folder
    ## local folder_file=`dirname $file`  # relative path
    folder=`echo "$file" | sed 1,1s/$picture//`
    echo "folder        =" $folder
    
    # enter folder
    cd $folder

    # replace all spaces with _
    folder_nospace=`echo "$folder" | sed 1,1s/" "/_/g`
    echo "folder_nospace=" $folder_nospace

    # find deepest (subject1) folder (no spaces)
    subject1=`echo $folder_nospace | awk -F '/' '{print $(NF-1)}'`
    echo "subject1          =" $subject1
    
    # find 2nd deepest (subject2) folder (no spaces)
    subject2=`echo $folder_nospace | awk -F '/' '{print $(NF-2)}'`
    echo "subject2          =" $subject2
    
    # find 3rd deepest (subject3) folder (no spaces)
    subject3=`echo $folder_nospace | awk -F '/' '{print $(NF-3)}'`
    echo "subject3          =" $subject3
    
    ## # construct new filename
    ## fn=$subject2"_"$subject1"_"$picture
    ## echo "fn            =" $fn

    # strip out initial part of folder name
    strip='\/f\/MY_PICTURES\/'
    prefix=`echo "$folder_nospace" | sed 1,1s/$strip//`

    # replace / with _
    strip='\/'
    prefix=`echo "$prefix" | sed 1,1s/$strip/_/g`
    echo "prefix        =" $prefix
    
    # construct new filename
    picture_new=$prefix"_"$picture
    echo "picture_new   =" $picture_new

    # print results to screen
    # echo $file, $folder, $picture, $picture_new

    # rename picture
    old="$folder$picture"
    new="$folder$picture_new"
    cp "$old" "$old"'_original'
    mv "$old" "$new"

    # options for tags
    # https://www.exiftool.org/TagNames/XMP.html#dc
    #
    # Based on F:\MY Pictures\2010s\2017\2017_04\Dad's service\2010_Thanksgiving whole fam.jpg,
    # Jackie and Dave seem to use:
    #       XMP Title       to identify, e.g., Thanksgiving
    #       XMP Subject     to create tags for people
    # subject is found in "Tags" in File Explorer
    #
    # https://exiftool.org/gui/articles/where_what.html
    #    XMP-dc -for your name, copyright notice, photo title, keywords, etc.
    #    XMP-iptcCore -for your contact data (address, mail, phone, etc.)
    #    XMP-iptcExt -for location data, event notice, names of persons on photo, etc.
    #
    # exiftool -xmp-dc:title="mytitle" -xmp-dc:description="mydescription" -xmp-dc:subject="subject1" -xmp-dc:subject="subject2" test.jpg
    #
    # tried following which loads but Diffractor does not filter on these (MS Photos only uses file name)
    # exiftool -xmp-iptcExt:PersonInImage='David Hjelmar' -xmp-iptcExt:PersonInImage='Brad Hjelmar' test.jpg
    exiftool -xmp-dc:title="$prefix" -xmp-dc:description="$prefix" -xmp-dc:subject="$subject3" -xmp-dc:subject="$subject2" -xmp-dc:subject="subject1" test.jpg
t.jpg

    
done
cd $original
IFS=$SAVEIFS

#---------------------------------------------------------
# terminate script below here
exit



