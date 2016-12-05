class guix::install inherits guix {
  exec {'load GPG signing key for Guix':
    command => "/bin/gpg2 --keyserver hkp://keys.gnupg.net:80 --recv-keys 090B11993D9AEBB5",
    unless => "/bin/gpg2 --list-key 090B11993D9AEBB5"
  }

  file {'/tmp/guix-binary.tar.xz.sig':
    source => 'http://alpha.gnu.org/gnu/guix/guix-binary-0.11.0.x86_64-linux.tar.xz.sig',
  }

  file {'/tmp/guix-binary.tar.xz':
    source => 'http://alpha.gnu.org/gnu/guix/guix-binary-0.11.0.x86_64-linux.tar.xz',
    validate_cmd => 'cd /tmp && /bin/gpg2 --verify %.sig %',
    unless => "test -e /gnu",
    require => [ File['/tmp/guix-binary.tar.xz.sig'],
                 Exec['load GPG signing key for Guix']]
  }

  exec {'unpack guix':
    command => "cd /tmp && /bin/tar --warning=no-timestamp -xf guix-binary.tar.xz && mv var/guix /var/ && mv gnu /",
    unless => "test -e /gnu || test -e /var/guix",
    require => File['/tmp/guix-binary.tar.xz']
  }

  # Set up build users
  group {'guixbuild':
    ensure => present
  }

  define guixbuild_user ($number) {
    user {"guixbuilder${number}":
      ensure     => present,
      comment    => "Guix build user ${number}",
      gid        => "guixbuild",
      groups     => "guixbuild",
      membership => inclusive,
      shell      => "/bin/nologin",
      system     => true,
      forcelocal => true,
      require    => Group["guixbuilder"]
    }
  }

  guixbuild_user { [ "01", "02", "03", "04", "05",
                     "06", "07", "08", "09", "10",
                     "11", "12", "13", "14", "15",
                     "16", "17", "18", "19", "20",
                     ]:
  }
}
