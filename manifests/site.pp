require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  #include dnsmasq
  #include hub
  #include nginx

  include git
  include chrome
  
  #OS X custom preferences

  include osx::global::enable_keyboard_control_access
  include osx::global::expand_save_dialog
  include osx::global::disable_autocorrect
  include osx::dock::autohide
  include osx::dock::clear_dock
  include osx::software_update

  class { 'osx::global::key_repeat_delay':
    delay => 2
  }

  class { 'osx::global::key_repeat_rate':
    rate => 5
  }

  class { 'osx::dock::position':
    position => 'left'
  }

  class { 'osx::global::natural_mouse_scrolling':
    enabled => true
  }

  #Ruby
  class { 'ruby::global':
    version => '2.0.0-p353'
  }


  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
