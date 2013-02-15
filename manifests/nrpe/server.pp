#
# class to set up NRPE daemon on remotely monitored nodes
# and allow access to it from Nagios server

class naginator::nrpe::server( $allowed_hosts = ['127.0.0.1'], ) {

    package { [ "nagios-nrpe-server", "nagios-plugins", ]:
        ensure => installed,
    }

    service { "nagios-nrpe-server":
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => Package["nagios-nrpe-server"],
        subscribe  => File["nrpe_config"],
    }

    file { "nrpe_config":
        name    => "/etc/nagios/nrpe.cfg",
        content => template("naginator/nrpe.erb"),
        mode    => 0644,
        owner   => root,
        group   => root,
        require => File["nrpe_config_dir"],
        notify  => Service["nagios-nrpe-server"],
    }

    file { "nrpe_config_dir":
        name    => "/etc/nagios",
        ensure  => directory,
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-nrpe-server"],
    }

}
