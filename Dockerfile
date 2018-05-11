FROM gitlab/gitlab-ce:latest

RUN apt-get -y update \
    && apt-get -y install build-essential \
    && git clone https://github.com/awslabs/git-secrets /var/opt/git-secrets \
    && cd /var/opt/git-secrets \
    && make install \
    && git secrets --register-aws --global \
    && mkdir -p /opt/gitlab/embedded/service/gitlab-shell/hooks/pre-receive.d \
    && echo -e '#!/usr/bin/env bash\ngit secrets --commit_msg_hook -- "$@"' > /opt/gitlab/embedded/service/gitlab-shell/hooks/pre-receive.d/pre-receive \
    && chmod +x /opt/gitlab/embedded/service/gitlab-shell/hooks/pre-receive.d/pre-receive
