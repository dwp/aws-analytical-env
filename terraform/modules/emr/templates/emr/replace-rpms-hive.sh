#!/bin/bash
set -ex
(
    prefix="${hive_scratch_dir_s3_prefix}"
    local_repo=/var/aws/emr/packages/bigtop

    exclude_pkgs=""

    # Only passing one in here so it is ok as is
    # shellcheck disable=SC2068
    for app in $@; do
        sudo mkdir -p "$local_repo/$app"
        # Never usually quote the which aws statement
        # shellcheck disable=SC2046
        sudo $(which aws) s3 cp "$prefix" "$local_repo/$app" --recursive
        exclude_pkgs="$exclude_pkgs $app*"
    done

    repo=""
    flag=true
    # For pre emr-5.10.0 clusters
    if [ -e "/etc/yum.repos.d/Bigtop.repo" ]; then
        flag=false
    # For emr-5.10.0+ clusters
    elif [ -e "/etc/yum.repos.d/emr-apps.repo" ]; then
        repo="/etc/yum.repos.d/emr-apps.repo"
    # For BYOA clusters
    elif [ -e "/etc/yum.repos.d/emr-bigtop.repo" ]; then
        repo="/etc/yum.repos.d/emr-bigtop.repo"
    fi

    if [ "$flag" = true ]; then
        sudo bash -c "cat >> $repo" <<EOL
exclude =$exclude_pkgs
EOL
    fi

    sudo yum install -y createrepo
    sudo createrepo --update --workers 8 -o $local_repo $local_repo
    sudo yum clean all
    # This sleep hasn't seemed necessary to me (jonathak@), but it can be uncommented if it is found to be truly necessary
    # Yes, this sleep is necessary in particular cases as I (dauwu@) tested in CN region since yum works quite slowly there. We also need another sleep before calling "yum clean all" above to avoid "yum lock" issue due to the same reason.
    # sleep 200

    if [ "$flag" = true ]; then
        sudo bash -c "cat > /etc/yum.repos.d/bigtop_test.repo" <<EOL
[bigtop_test]
name=bigtop_test_repo
baseurl=file:///var/aws/emr/packages/bigtop
enabled=1
gpgcheck=0
priority=4
EOL
    fi
) >> /var/log/pdm/replace_rpms_hive.log 2>&1
