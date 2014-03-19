name             'gitzone'
maintainer       'Petr Michalec'
maintainer_email 'epcim@apealive.net'
license          'Apache 2.0'
description      'Installs/Configures gitzone managed zone files for Bind'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.6'

recipe            "gitzone::default", "Install and fully configure gitzone using the install and configure recipes"
recipe            "gitzone::install", "Install gitzone scripts"
recipe            "gitzone::configure", "Configure gitzone (including BIND and default zones)"
recipe            "gitzone::configure_gitzone", "Configure gitzone itself)"
recipe            "gitzone::configure_bind", "Configure BIND to use gitzone managed zone files"
recipe            "gitzone::configure_zonefile", "Deploy zone files"
recipe            "gitzone::client_dyndns", "Configure client to update IP address on DNS server when starting networking"


supports "ubuntu"
supports "centos"


attribute "gitzone/user",
  :display_name => "gitzone user",
  :description => "Gitzone user system account",
  :default => "gitzone"

#TODO fill desc. about other attributes
