FROM gitlab/gitlab-ce:latest

RUN apt-get -y update \
    && apt-get -y install build-essential \
    && git clone https://github.com/awslabs/git-secrets /var/opt/git-secrets \
    && cd /var/opt/git-secrets \
    && make install \
    && git secrets --register-aws --global
