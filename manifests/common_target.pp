#
# class to be applied to remote nagios-monitored nodes
# this class includes baseline tests for those servers
# such as disk capacity monitoring and load monitoring
#
# if the nagios server is monitoring itself, any configuration
# regarding nagios server tests will not be done in this class;
# only remotely monitored nodes (NRPE) are covered by this class.
# The naginator base class should include any configuration of
# monitoring the Nagios server will run against itself
# 
# this class is included by the various node-type-specific
# classes (control_target, compute_target, etc) so should not
# need to be directly applied to any specific node or node type
#

class naginator::common_target {

    class { "naginator::nrpe::server":
        allowed_hosts => [ '127.0.0.1', "$::cobbler_node_ip" ]
    }

    @@nagios_service { "check_ntp_time_${hostname}":
        check_command       => "check_nrpe_1arg!check_ntp_time",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "NTP",
    }

    naginator::nrpe::command { "check_ntp_time":
        command => "check_ntp_time -H $::cobbler_node_ip -w 1 -c 3";
    }

    @@nagios_service { "check_disks_${hostname}":
        check_command       => "check_nrpe_1arg!check_all_disks",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "Disk Space",
    }

    naginator::nrpe::command { "check_all_disks":
        command => "check_disk -w '20%' -c '10%' -e";
    }

    @@nagios_service { "check_load_${hostname}":
        check_command       => "check_nrpe_1arg!check_load",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "Current Load",
    }

    naginator::nrpe::command { "check_load":
        command => "check_load -w '5.0,4.0,3.0' -c '10.0,6.0,4.0'";
    }

    @@nagios_service { "check_procs_${hostname}":
        check_command       => "check_nrpe_1arg!check_procs",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "Total Processes",
    }

    naginator::nrpe::command { "check_procs":
        command => "check_procs -w '250' -c '400'";
    }

    @@nagios_service { "check_users_${hostname}":
        check_command       => "check_nrpe_1arg!check_users",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "Current Users",
    }

    naginator::nrpe::command { "check_users":
        command => "check_users -w '10' -c '25'";
    }

}
