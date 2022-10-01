#! /bin/bash

#sel4_repos=(seL4_tools camkes-tool gitactions-pr)
sel4_repos=(seL4_tools camkes-tool gitactions-pr)
PR_BR_NAME=$1
same_repocheck () {
      repo=$1  
      pr_repo_owner=$(curl  https://api.github.com/repos/amalx-ssrc/${repo}/pulls?state=open -H "Accept: application/json" | jq -r --arg PR_BR_NAME "$PR_BR_NAME" '.[] | select(.head.ref == $PR_BR_NAME) | .user.login')
      repo_owner=$(curl  https://api.github.com/repos/amalx-ssrc/${repo}/pulls?state=open -H "Accept: application/json" | jq -r --arg PR_BR_NAME "$PR_BR_NAME" '.[] | select(.head.ref == $PR_BR_NAME) | .base.user.login')
      repo_name=$(curl  https://api.github.com/repos/amalx-ssrc/${repo}/pulls?state=open -H "Accept: application/json" | jq -r --arg PR_BR_NAME "$PR_BR_NAME" '.[] | select(.head.ref == $PR_BR_NAME) | .head.repo.name')
      if [ $pr_repo_owner != $repo_owner ]; then 
      echo "pr from same repo"
      echo $repo
      sed -i "/<manifest>/a <remote name=\"$pr_repo_owner\" fetch=\"https://github.com/$pr_repo_owner\"/>" ./tii_sel4_manifest/external.xml
      fi
      sed -i "/$repo.git/c\<extend-project name=\"$repo_name.git\"                remote=\"$pr_repo_owner\" revision=\"$PR_BR_NAME\"/>" ./tii_sel4_manifest/external.xml
      echo "##################"
      cat external.xml

    }

same_branch=()
for repo in ${sel4_repos[@]}; do 
#if [ $PR_REPO_NAME = $OR_REPO_NAME ]
branch_name=$(curl https://api.github.com/repos/amalx-ssrc/${repo}/pulls?state=open -H "Accept: application/json" | jq -r '.[] | .head.ref')

#echo $branch_name"amal"
        for name in ${branch_name[@]}; do 
            #echo $name
            if [ $PR_BR_NAME = $name ]; then

            echo "same branch" 
            same_branch+=($repo)
            same_repocheck $repo
            fi
        done
done
echo $same_branch



# for repo in ${same_branch[@]}; do
#    echo $repo
#    same_repocheck $repo
#    done