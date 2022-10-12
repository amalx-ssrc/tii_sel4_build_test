#! /bin/bash

sel4_repos=(seL4_tools camkes-tool gitactions-pr)
PR_BR_NAME=$1
echo $PR_BR_NAME
pwd
ls
same_repocheck () {
      repo=$1  
      pr_repo_owner=$( jq -r --arg PR_BR_NAME "$PR_BR_NAME" '.[] | select(.head.ref == $PR_BR_NAME) | .user.login' api_file )
      repo_owner=$(jq -r --arg PR_BR_NAME "$PR_BR_NAME" '.[] | select(.head.ref == $PR_BR_NAME) | .base.user.login' api_file)
      repo_name=$(jq -r --arg PR_BR_NAME "$PR_BR_NAME" '.[] | select(.head.ref == $PR_BR_NAME) | .head.repo.name' api_file)
      if [ $pr_repo_owner != $repo_owner ]; then 
      echo "pr from same repo"
      echo $repo
      pwd
      ls
      sed -i "/<manifest>/a <remote name=\"$pr_repo_owner\" fetch=\"https://github.com/$pr_repo_owner\"/>" tii_sel4_manifest-$PR_BR_NAME/external.xml
      #sed -i "/<manifest>/a <remote name=\"$pr_repo_owner\" fetch=\"https://github.com/$pr_repo_owner\"/>" ./external.xml

      fi
      sed -i "/$repo.git/c\<extend-project name=\"$repo_name.git\"                remote=\"$pr_repo_owner\" revision=\"$PR_BR_NAME\"/>" tii_sel4_manifest-$PR_BR_NAME/external.xml
      #sed -i "/$repo.git/c\<extend-project name=\"$repo_name.git\"                remote=\"$pr_repo_owner\" revision=\"$PR_BR_NAME\"/>" ./external.xml

    }


for repo in ${sel4_repos[@]}; do 
curl  https://api.github.com/repos/amalx-ssrc/${repo}/pulls?state=open -H "Accept: application/json" > api_file

 branch_name=$(jq -r '.[] | .head.ref' api_file)
        for name in ${branch_name[@]}; do 
            if [ $PR_BR_NAME = $name ]; then
            #same_branch+=($repo)
            same_repocheck $repo
            fi
        done
done
