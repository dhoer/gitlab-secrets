FROM gitlab/gitlab-ce:latest

# install git-secrets
RUN apt-get -y update \
    && apt-get -y install build-essential \
    && git clone https://github.com/awslabs/git-secrets /var/opt/git-secrets \
    && cd /var/opt/git-secrets \
    && make install

# config git-secrets as update hook
COPY git-hooks/.gitconfig /opt/git-hooks/
COPY git-hooks/git-secrets.sh /opt/git-hooks/update.d/
RUN chown -R git:git /opt/git-hooks
