# bimsb-guix -- Install Guix via Puppet
# Copyright © 2016, 2017 Ricardo Wurmus <rekado@elephly.net>
#
# This file is part of bimsb-guix.
#
# bimsb-guix is free software under the GPL version 3 or any
# later version; see the LICENSE file for details.

class guix::install inherits guix {
  exec {'load GPG signing key for Guix':
    command => "/bin/gpg2 --keyserver hkp://keys.gnupg.net:80 --recv-keys 090B11993D9AEBB5",
    unless => "/bin/gpg2 --list-key 090B11993D9AEBB5"
  }

  exec {'/tmp/guix-binary.tar.xz.sig':
    command => '/bin/wget -O /tmp/guix-binary.tar.xz.sig http://alpha.gnu.org/gnu/guix/guix-binary-0.11.0.x86_64-linux.tar.xz.sig',
    creates => '/tmp/guix-binary.tar.xz.sig'
  }

  exec {'/tmp/guix-binary.tar.xz':
    command => '/bin/wget -O /tmp/guix-binary.tar.xz http://alpha.gnu.org/gnu/guix/guix-binary-0.11.0.x86_64-linux.tar.xz && cd /tmp && /bin/gpg2 --verify /tmp/guix-binary.tar.xz.sig',
    creates => '/tmp/guix-binary.tar.xz',
    require => [ Exec['/tmp/guix-binary.tar.xz.sig'],
                 Exec['load GPG signing key for Guix']]
  }

  exec {'unpack guix':
    command => "cd /tmp && /bin/tar --warning=no-timestamp -xf guix-binary.tar.xz && /bin/mv var/guix /var/ && /bin/mv gnu /",
    path    => ['/bin/', '/usr/bin/', '/usr/sbin/'],
    creates => "/gnu/store",
    require => Exec['/tmp/guix-binary.tar.xz']
  }

  file {'/root/.guix-profile':
    ensure  => link,
    target  => "/var/guix/profiles/per-user/root/guix-profile",
    require => Exec['unpack guix']
  }

  file {'/usr/local/bin/guix':
    ensure  => link,
    target  => '/var/guix/profiles/per-user/root/guix-profile/bin/guix',
    require => Exec['unpack guix']
  }

  exec {'install systemd service':
    command => "cp /root/.guix-profile/lib/systemd/system/guix-daemon.service /etc/systemd/system/",
    path    => ['/bin/', '/usr/bin/', '/usr/sbin/'],
    creates => "/etc/systemd/system/guix-daemon.service",
    require => Exec['unpack guix']
  }

  service {'guix-daemon':
    ensure    => running,
    enable    => true,
    require   => Exec['install systemd service'],
  }

  # TODO: check acl first
  exec {'authorize hydra':
    command => '/usr/local/bin/guix archive --authorize < /root/.guix-profile/share/guix/hydra.gnu.org.pub',
    require => [ File['/usr/local/bin/guix'],
                 File['/root/.guix-profile']],
    refreshonly => true,
    subscribe   => [ File['/usr/local/bin/guix'],
                     File['/root/.guix-profile']]
  }

  # Set up build users
  group {'guixbuild':
    ensure => present,
    system => true
  }

  define guixbuild_user ($number) {
    user {"guixbuilder${number}":
      ensure     => present,
      comment    => "Guix build user ${number}",
      gid        => "guixbuild",
      groups     => "guixbuild",
      membership => inclusive,
      shell      => "/sbin/nologin",
      system     => true,
      forcelocal => true,
      require    => Group["guixbuild"]
    }
  }

  guixbuild_user {'guixbuild01': number => "01" }
  guixbuild_user {'guixbuild02': number => "02" }
  guixbuild_user {'guixbuild03': number => "03" }
  guixbuild_user {'guixbuild04': number => "04" }
  guixbuild_user {'guixbuild05': number => "05" }
  guixbuild_user {'guixbuild06': number => "06" }
  guixbuild_user {'guixbuild07': number => "07" }
  guixbuild_user {'guixbuild08': number => "08" }
  guixbuild_user {'guixbuild09': number => "09" }
  guixbuild_user {'guixbuild10': number => "10" }
}
