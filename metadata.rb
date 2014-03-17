name             'gitzone'
maintainer       'Petr Michalec'
maintainer_email 'epcim@apealive.net'
license          'All rights reserved'
description      'Installs/Configures gitzone'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.6'

recipe            "gitzone::default", "Install and fully configure gitzone using the install and configure recipes"
recipe            "gitzone::install", "Install gitzone scripts"
recipe            "gitzone::configure", "Configure gitzone (including BIND and default zones)"

supports "ubuntu"
supports "centos"


attribute "gitzone/user",
  :display_name => "gitzone user",
  :description => "Gitzone user system account",
  :default => "gitzone"

#TODO fill desc. about other attributes
