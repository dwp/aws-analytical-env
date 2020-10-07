http_port 3128 require-proxy-header

acl localnet src 10.0.0.0/8
proxy_protocol_access allow localnet

acl SSL_ports port 443
acl Safe_ports port 80            # http
acl Safe_ports port 443           # https

acl CONNECT method CONNECT

# Deny requests to certain unsafe ports
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager

# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost


# HOSTS
%{ if environment == "management-dev" }

acl hosts_analytical_env_dev src      ${cidr_block_analytical_env_dev}

acl hosts_analytical_env_qa src       ${cidr_block_analytical_env_qa}

acl hosts_analytical_env_int src      ${cidr_block_analytical_env_int}

%{ endif }


%{ if environment == "management" }

acl hosts_analytical_env_pre src      ${cidr_block_analytical_env_pre}

acl hosts_analytical_env_prod src     ${cidr_block_analytical_env_prod}

%{ endif }


# WHITELISTS
acl whitelist dstdomain   "/etc/squid/conf.d/whitelist"

# RULES
%{ if environment == "management-dev" }

http_access allow hosts_analytical_env_dev      whitelist
http_access allow hosts_analytical_env_qa       whitelist
http_access allow hosts_analytical_env_int      whitelist

%{ endif }


%{ if environment == "management" }

# Allow Kali boxes to reach everything as we don't know what the ITHC testers
# will need

http_access allow hosts_analytical_env_pre      whitelist
http_access allow hosts_analytical_env_prod     whitelist

%{ endif }

# http_access allow localnet
# http_access allow localhost
http_access deny all

# Leave coredumps in the first cache dir
coredump_dir /var/cache/squid

refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320

# Delete forwarded-for header, to hide internal IP addresses from Internet end-points
forwarded_for delete
