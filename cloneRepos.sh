#!/usr/bin/env bash
: << 'COMMENT'
Purpose: Bash script to clone all public repositories associated with a github account also creates file structure in current directory
Date: 2/17/2025
Author: Max Hoffman
COMMENT

set -euo pipefail

#Get Github username
echo "Enter Github username to clone all public repos associated with it"
read username

#check username exits
check_user=$(curl -s -o /dev/null -I -w "%{http_code}" https://api.github.com/users/$username)


#if the user does not exist we don't try to clone their repos
if [ "$check_user" -eq 404 ]; then
    
    echo "Username does not exist on Github"
    echo "Exiting"

else
    #User exists
    echo "Username exists on Github"    
    echo "Getting all repos associated with the github account : $username"
    #get the JSON returned from your github profile this will return all your repos and thier data
    json=$(curl -s https://api.github.com/users/$username/repos )
    #we just want the repo urls so we use jq to grab them -r means read . refers to the current object [] refers to the list and each repo url is html_url in the JSON
    urls=$(echo $json | jq -r '.[].html_url')
    #Also grab the repo names so we can create the directory structure
    names=($(echo $json | jq -r '.[].name'))
    dir=${username}_repos
    #create directory structure
    mkdir -p ${dir}/Repositories/PublicRepositories
    #also create a directory for private repos, in case you want to clone private repos in the same file structure
    mkdir -p ${dir}/Repositories/PrivateRepositories

    cd ${dir}/Repositories/PublicRepositories
    i=0
    #for every url in urls
    for url in $urls
    do 
        #Create folder for each repo
        echo "Creating directory for $url"
        #get the current name for our directory
        mkdir -p ${names[$i]}
        cd ${names[$i]}
       

        #clone the repo
        echo "Cloning repo called ${names[$i]}"
        git clone $url > /dev/null 2>&1
        #move to parent directory
        cd ../
        #loop to next name
        i=$((i + 1))
        
    done
    echo "Cloned ${#names[@]} repositories from Github user $username"
    echo "Done"

fi