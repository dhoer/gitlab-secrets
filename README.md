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

### GitLab Secrets

Start GitLab Secrets container in background:

    docker-compose up -d gitlab


Tail the logs to make sure it came up properly:

    docker-compose logs -f gitlab

Open a browser and navigate to http://localhost:8081 and initialize the
`root` password. For this demo we will use `Welcome1` as the password.

Once logged in, create a new Group called `demo`.  Then create a new
Project called `my-repo`.

### Test

Start gitlab-secrets container:

    docker-compose run gitlab-secrets /bin/sh

From `gitlab-secrets` container,
clone `my-repo` with `root/Welcome` creds:

    git clone http://gitlab:8081/demo/my-repo.git

Change directory to my-repo:

    cd my-repo

Verify you are able to push a non-secret change:

    echo "no secrets here" > README.md
    git add README.md
    git commit -m "tweak readme"
    git push -u origin master


Verify you are not able to push an allowed AWS example key:

    echo "AKIAIOSFODNN7EXAMPLE wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" > README.md
    git add README.md
    git commit -m "allowed example secret"
    git push -u origin master

Verify you are not able to push an AWS secret key:

    echo "AKIAIOSFODSECRETSKEY wJalrXUtnFEMI/K7MDENG/bPxRfiCYSECRETSKEY" > README.md
    git add README.md
    git commit -m "oops"
    git push -u origin master

Verify you are able to override GitLab blocking push with `.gitallowed`:

    echo "SECRETSKEY" > .gitallowed
    git add .gitallowed
    git commit -m "false positive"
    git push -u origin master

## Setup

Clone git-secrets to `/var/opt/git-secrets`:

    git clone https://github.com/awslabs/git-secrets /var/opt/git-secrets

Change directory to `/var/opt/git-secrets`:

    cd /var/opt/git-secrets

Install build-essential:

    apt-get -y update && apt-get -y install build-essential

Install git-secrets:

    make install

Register AWS security scan rules at global level:

    git secrets --register-aws --global

TODO: Add global pre-receive hook steps


curl --request POST --user root:Welcome1 --url http://gitlab:8081/rest/api/1.0/projects/PDE/repos --header 'Content-Type: application/json' --data "{\"name\": \"my-repo-name\"}"