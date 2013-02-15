# 
# class to define compute-node specific monitoring
#

class naginator::compute_target {

    class { "naginator::common_target":
    }

    #
    # custom plugin to monitor resource usage due to VMs on compute nodes

    @@nagios_service { "check_vm_${hostname}":
        check_command       => "check_nrpe_1arg!check_vm",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "VM Stats",
    }

    naginator::nrpe::command { "check_vm":
        command => "check_vm";
    }

    file { "check_vm":
        name    => "/usr/lib/nagios/plugins/check_vm",
        source  => 'puppet:///modules/naginator/check_vm',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

}
