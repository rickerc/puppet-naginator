#
# definition used to create config files on remote nodes specifying
# monitoring commands to be executed by Nagios server via NRPE

define naginator::nrpe::command ( $command,) {

    file { "/etc/nagios/nrpe.d/${title}.cfg":
        ensure => present,
        mode   => 0755,
        owner  => root,
        group  => root,
        content => template("naginator/command.erb"),
        require => Package[ ["nagios-nrpe-server", "nagios-plugins"] ],
        notify  => Service["nagios-nrpe-server"],
    }

}
