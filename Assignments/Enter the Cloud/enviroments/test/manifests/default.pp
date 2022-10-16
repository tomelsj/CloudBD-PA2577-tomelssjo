node default {
    include idefault
}

node "appserver." {
    include iappserver
}

node "dbserver." {
    include idbserver
}

class idefault () {
    notice("default ${fqdn}")
}

class iappserver () {
    notice("app ${fqdn}")
    
    exec { "add-to-hosts":
        command => '/usr/bin/echo "$(/usr/bin/hostname -I) $(/usr/bin/hostname)" >> /vagrant/hosts'
    }

    exec { "apt-update":
        command => "/usr/bin/apt-get update"
    }

    package { "curl":
        ensure => installed,
        require => Exec["apt-update"]
    }

    exec { "before_nodejs":
        command => "/bin/curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -"
    }

    package { "nodejs":
        ensure => installed
    }
}

class idbserver () {
    notice("db ${fqdn}")

    exec { "add-to-hosts":
        command => '/usr/bin/echo "$(/usr/bin/hostname -I) $(/usr/bin/hostname)" >> /vagrant/hosts'
    }

    exec { "apt-update":
        command => "/usr/bin/apt-get update"
    }

    package { "mysql-server":
        ensure => installed,
        require => Exec["apt-update"]
    }

    service {"mysql":
        ensure  => running,
        require => Package["mysql-server"]
    }

    exec { "set-mysql-password":
        unless => "mysqladmin -uroot -p123 status",
        path => ["/bin", "/usr/bin"],
        command => "mysqladmin -uroot password '123'",
        require => Service["mysql"],
    }
}
