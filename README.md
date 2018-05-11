# GitLab Secrets

GitLab offers a way to
[prevent pushing files with secrets](https://docs.gitlab.com/ee/push_rules/push_rules.html#prevent-pushing-secrets-to-the-repository)
that have a specific filename, but this doesn't go far enough because it
doesn't scan files for secrets.

AWS's git-secrets (https://github.com/awslabs/git-secrets) provides a
way to scan files, but it requires users to install it on their
local machine.  This is not ideal because it is hard to ensure users
are compliant with best practices.

A hybrid approach would be to have git-secrets on both client and
GitLab server side checking for secrets. GitLab can reject a push if it
fails a scan, and users can use the same git-secrets tool to resolve
the problem from their end.

## Demonstration

Demonstrate the use of git-secrets
(https://github.com/awslabs/git-secrets) with GitLab server side
hooks.

### gitlab

Extends gitlab container to include git-secrets with aws rules in
global pre-recieve custom hooks.

Start GitLab container in background:

    docker-compose up -d gitlab


Tail the logs to make sure it came up properly:

    docker-compose logs -f gitlab

Open a browser and navigate to http://localhost:8081 and initialize the
`root` password. For this demo we will use `Welcome1` as the password.

Once logged in, create a new Group called `demo`.  Then create a new
Project called `my-repo`.

### git

Start gitlab-secrets container:

    docker-compose run git /bin/sh

From `gitlab-secrets` container,
clone `my-repo` with `root/Welcome` creds:

    git clone http://gitlab:8081/demo/my-repo.git

Change directory to my-repo:

    cd my-repo

Verify you are able to push a non-secret change:

    echo "no secrets here" > README.md
    git add README.md
    git commit -m "Update readme"
    git push -u origin master


Verify you are able to push an allowed AWS example key:

    echo "AKIAIOSFODNN7EXAMPLE wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" > README.md
    git add README.md
    git commit -m "Allowed example secret"
    git push -u origin master

Verify you are NOT able to push an AWS secret key:

    echo "AKIAIOSFODSECRETSKEY wJalrXUtnFEMI/K7MDENG/bPxRfiCYSECRETSKEY" > README.md
    git add README.md
    git commit -m "Oops"
    git push -u origin master

Verify you are able to override GitLab blocking push with `.gitallowed`:

    echo "SECRETSKEY" > .gitallowed
    git add .gitallowed
    git commit -m "False positive"
    git push -u origin master
