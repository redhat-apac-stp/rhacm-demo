#!/bin/bash

# Ask the user for the folder to search
read -p "Enter the folder to search in: " folder
# example
# folder="/Users/rajiv-ranjan/Documents/github/rajiv-ranjan/policy-collection/community/CM-Configuration-Management"

# Ask the user for the string to search for
read -p "Enter the string to search for: " search_string
# example
# search_string="kind: "

# Define output CSV file
output_file="search_results.csv"

# Initialize the output file with headers
echo "File Name,Matched Lines" > $output_file

# Search through all yaml files in the specified folder
for file in "$folder"/*.yaml; do
  # Find lines in the file that match the search string
  match1=$(grep -E -ih "$search_string" "$file" | sed 's/ //g' |grep -E -iv "kind:policy|kind:ConfigurationPolicy|#kind:" | tr "\n" "|" | sed 's/ //g')
  matches=$(echo $match1 | sed "s|$search_string||g")
  #matches=$(grep -n "kind: *$search_string" "$file")

#  if [ ! -z "$matches" ]; then
    #filename=$file
    # Extract file name
    filename=$(echo $file | sed "s|$folder/||g")
    #filename=$(sed 's,'"$folder"',,' "$file")
    #echo $filename
    #filename=$(basename "$file")

    # Concatenate matched lines with '|'
    #concatenated_matches=$(echo "$matches" | awk -F: '{print $2}' | paste -sd "|" -)

    # Write to the CSV file
    echo "$filename,${matches}" >> $output_file
    #echo "$filename,$concatenated_matches" >> $output_file
#  fi
done

echo "Search complete. Results saved in $output_file"
