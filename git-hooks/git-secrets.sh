#!/usr/bin/env bash

refname=$1
oldrev=$2
newrev=$3

echo "Executing git-secrets"
echo ""

# use git-secrets aws-provider git configuration
HOME=/opt/git-hooks

# add git-secrets to path
PATH=$PATH:/usr/local/bin

# handle empty repository
if [ "$oldrev" = "0000000000000000000000000000000000000000" ]; then
  oldrev=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

for i in $(git show $newrev:.gitallowed 2>/dev/null); do
  git secrets --add --allowed $i;
done

exitcode='0'
FILES=`git diff --name-status $oldrev $newrev | awk '{print $2}'`
for filepath in $FILES; do
  if [ "$filepath" = ".gitallowed" ]; then
    echo "Skipping $filepath ..."
  else
    echo "Scanning $filepath ..."
  fi
  git show $newrev:$filepath | git secrets --scan -
  result=$?
  if [ "$result" != "0" ]; then
    exitcode=$result
  fi
done

for i in $(git show $newrev:.gitallowed 2>/dev/null); do
  git secrets --add --allowed $i;
done

if [ "$exitcode" != "0" ]; then
    echo ""
    echo "Listing configuration ..."
    echo ""
    git secrets --list
    echo ""
    echo "Please fix the above issues by running \`git reset HEAD~1\`, and encrypting the secrets."
    echo ""
    echo "To prevent committing secrets in the future, install git-secrets on your local machine."
    echo "    https://github.com/awslabs/git-secrets"
    echo ""
    echo "Add AWS configuration template to add hooks to all repositories you initialize or clone in the future."
    echo "     git secrets --register-aws --global"
    echo ""
    echo "Add hooks to all your local repositories."
    echo "    git secrets --install ~/.git-templates/git-secrets"
    echo "    git config --global init.templateDir ~/.git-templates/git-secrets"
    echo ""
    exit 1
fi
