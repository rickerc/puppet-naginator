# 
# class to define control-node specific monitoring
#

class naginator::control_target {

    class { "naginator::common_target":
    }

    @@nagios_service { "check_http_${hostname}":
        check_command       => "check_http",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "HTTP",
    }

    #
    # custom plugin to validate glance functionality
    # expects to find at least one image, and an image named "precise-x86_64"

    @@nagios_service { "check_glance_${hostname}":
        check_command       => "check_nrpe_1arg!check_glance",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "Glance",
    }

    naginator::nrpe::command { "check_glance":
        command => "check_glance --host $::controller_node_address --auth_url http://$::controller_node_address:5000/v2.0/ --username admin --password $admin_password --tenant openstack --req_count 1 --req_images precise-x86_64";
    }

    file { "check_glance":
        name    => "/usr/lib/nagios/plugins/check_glance",
        source  => 'puppet:///modules/naginator/check_glance',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    #
    # custom plugin to validate keystone functionality
    # verifies endpoints for basic services are found in the catalog

    @@nagios_service { "check_keystone_${hostname}":
        check_command       => "check_nrpe_1arg!check_keystone",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "Keystone",
    }

    naginator::nrpe::command { "check_keystone":
        command => "check_keystone --auth_url http://$::controller_node_address:5000/v2.0/ --username admin --password $admin_password --tenant openstack volume identity compute image network ec2";
    }

    file { "check_keystone":
        name    => "/usr/lib/nagios/plugins/check_keystone",
        source  => 'puppet:///modules/naginator/check_keystone',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    #
    # custom plugin to validate nova-api functionality
    # queries via nova-api to verify; requires that an image already be added

    @@nagios_service { "check_novaapi_${hostname}":
        check_command       => "check_nrpe_1arg!check_novaapi",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "Nova-Api",
    }

    naginator::nrpe::command { "check_novaapi":
        command => "check_novaapi --auth_url http://$::controller_node_address:5000/v2.0/ --username admin --password $admin_password --tenant openstack";
    }

    file { "check_novaapi":
        name    => "/usr/lib/nagios/plugins/check_novaapi",
        source  => 'puppet:///modules/naginator/check_novaapi',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    #
    # enable rabbitmq management HTTP API if not already enabled

    exec { "rabbitmq_management_enable":
        command => "/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management",
        unless  => "/bin/grep rabbitmq_management /etc/rabbitmq/enabled_plugins 2>/dev/null",
        notify  => Service["rabbitmq-server"],
        require => Package["rabbitmq-server"],
    }

    @@nagios_service { "check_rabbitmq_aliveness_${hostname}":
        check_command       => "check_nrpe_1arg!check_rabbitmq_aliveness",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "RabbitMQ Alive",
    }

    naginator::nrpe::command { "check_rabbitmq_aliveness":
        command => "check_rabbitmq_aliveness -H $::controller_node_address -u $::rabbit_user -p $::rabbit_password --vhost=/";
    }

    file { "check_rabbitmq_aliveness":
        name    => "/usr/lib/nagios/plugins/check_rabbitmq_aliveness",
        source  => 'puppet:///modules/naginator/check_rabbitmq_aliveness',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    @@nagios_service { "check_rabbitmq_objects_${hostname}":
        check_command       => "check_nrpe_1arg!check_rabbitmq_objects",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "RabbitMQ Objects",
    }

    naginator::nrpe::command { "check_rabbitmq_objects":
        command => "check_rabbitmq_objects -H $::controller_node_address -u $::rabbit_user -p $::rabbit_password";
    }

    file { "check_rabbitmq_objects":
        name    => "/usr/lib/nagios/plugins/check_rabbitmq_objects",
        source  => 'puppet:///modules/naginator/check_rabbitmq_objects',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    @@nagios_service { "check_rabbitmq_overview_${hostname}":
        check_command       => "check_nrpe_1arg!check_rabbitmq_overview",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "RabbitMQ Overview",
    }

    naginator::nrpe::command { "check_rabbitmq_overview":
        command => "check_rabbitmq_overview -H $::controller_node_address -u $::rabbit_user -p $::rabbit_password";
    }

    file { "check_rabbitmq_overview":
        name    => "/usr/lib/nagios/plugins/check_rabbitmq_overview",
        source  => 'puppet:///modules/naginator/check_rabbitmq_overview',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    @@nagios_service { "check_rabbitmq_server_${hostname}":
        check_command       => "check_nrpe_1arg!check_rabbitmq_server",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "RabbitMQ Process",
    }

    naginator::nrpe::command { "check_rabbitmq_server":
        command => "check_rabbitmq_server -H $::controller_node_address -u $::rabbit_user -p $::rabbit_password -n $::controller_hostname";
    }

    file { "check_rabbitmq_server":
        name    => "/usr/lib/nagios/plugins/check_rabbitmq_server",
        source  => 'puppet:///modules/naginator/check_rabbitmq_server',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    @@nagios_service { "check_rabbitmq_watermark_${hostname}":
        check_command       => "check_nrpe_1arg!check_rabbitmq_watermark",
        use                 => "generic-service",
        host_name           => "$fqdn",
        service_description => "RabbitMQ Memory",
    }

    naginator::nrpe::command { "check_rabbitmq_watermark":
        command => "check_rabbitmq_watermark -H $::controller_node_address -u $::rabbit_user -p $::rabbit_password -n $::controller_hostname";
    }

    file { "check_rabbitmq_watermark":
        name    => "/usr/lib/nagios/plugins/check_rabbitmq_watermark",
        source  => 'puppet:///modules/naginator/check_rabbitmq_watermark',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    #
    # installed but not configured - useful if you need to monitor
    # a specific RabbitMQ queue but not of general default interest
    file { "check_rabbitmq_queue":
        name    => "/usr/lib/nagios/plugins/check_rabbitmq_queue",
        source  => 'puppet:///modules/naginator/check_rabbitmq_queue',
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package["nagios-plugins"],
        notify  => Service["nagios-nrpe-server"],
    }

    #
    # perl modules required by the RabbitMQ monitoring scripts
    package { [ "libnagios-plugin-perl", "libwww-perl", "libjson-perl", ]:
        ensure  => installed,
        require => Package["nagios-nrpe-server"],
        notify  => Service["nagios-nrpe-server"],
    }

}
