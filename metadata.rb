name             "railslove"
maintainer       "Railslove GmbH"
maintainer_email "lars@railslove.com"
license          "Apache 2.0"
description      "Installs/Configures railslove"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.5.11"

depends          "logrotate"
depends          "mongodb"
depends          "application", "2.0.4"
depends          "users"
depends          "hostname"
depends          "route53"
depends          "sudo", "2.2.0"
depends          "ohai"
depends          "chef-client", "3.0.4"
depends          "backup"
