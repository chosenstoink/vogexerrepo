include base
include changehostname

class base {
        package { ['vim-enhanced','curl','git'] :
                ensure  => present,
        }

        package { 'wget' :
                ensure  => installed,
        }

        user { 'monitor' :
                ensure     => present,
                shell      => '/bin/bash',
                home       => '/home/monitor',
                managehome => true,
        }


        file { '/home/monitor/scripts' :
                 ensure  => directory,
        }

        exec { 'memcheck' :
                command => "/usr/bin/wget -q  https://github.com/chosenstoink/vogexerrepo/blob/master/memory_check",
                cwd     => "/home/monitor/scripts",
        }

        file { '/home/monitor/scripts/memory_check' :
                mode    => 0755,
                require => Exec["memcheck"],
        }


        file { '/home/monitor/src' :
                ensure => directory,
		require => User["monitor"],
        }


        file { '/home/monitor/src/my_memory_check' :
                ensure => link,
                target => "/home/monitor/scripts/memory_check",
        }

        cron { 'memory_check' :
                command => "/home/monitor/src/my_memory_check",
                minute  => '*/1',
                user    => root,
        }


}


class changehostname {
         file { "/etc/hostname":
                 ensure  => present,
                 owner   => root,
                 group   => root,
                 mode    => '0644',
                 content => "bpx.server.local",
                 notify  => Exec["set-hostname"],
          }
        exec { "set-hostname":
                command => '/bin/hostname -F /etc/hostname',
                unless  => "/usr/bin/test `hostname` = `/bin/cat /etc/hostname`",
  }
}



