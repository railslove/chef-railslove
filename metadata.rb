maintainer       "Railslove GmbH"
maintainer_email "lars@railslove.com"
license          "Apache 2.0"
description      "Installs/Configures railslove"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.8"
depends          "logrotate"
depends          "mongodb"
depends          "application"
depends          "users"
depends          "hostname"
depends          "route53"
depends          "campfire"