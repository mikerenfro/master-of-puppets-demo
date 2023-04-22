node 'git.theits23.renf.ro' {
  $hostonly_ip = $::facts['networking']['interfaces']['eth1']['ip']
  $hostonly_network = $::facts['networking']['interfaces']['eth1']['network']
  class { 'gitea':
    ensure               => '1.18.5',
    checksum             => '4766ad9310bd39d50676f8199563292ae0bab3a1922b461ece0feb4611e867f2',
    custom_configuration => {
      'server'  => {
        'ROOT_URL'   => "http://${hostonly_ip}:3000/",
        'SSH_DOMAIN' => $hostonly_ip,
        'DOMAIN'     => $hostonly_ip,
      },
      'webhook' => {
        'ALLOWED_HOST_LIST' => "${hostonly_network}/24",
      }
    },
  }
}
node 'puppet.theits23.renf.ro' {
  class { 'puppet':
    server         => true,
    server_foreman => false,
    server_reports => 'store',
  }
  package { 'git':
    ensure => present,
  }
  ssh_keygen { 'puppet':
    home => '/opt/puppetlabs/server/data/puppetserver'
  }
  sshkey { 'git.theits23.renf.ro':
    ensure => present,
    type   => 'ssh-ed25519',
    key    => 'AAAAC3NzaC1lZDI1NTE5AAAAICNYDq2jAEFC3yqM9vzDwxrFuqFp8Qz7QgekMR2mBevf'
    # substitute with output from ssh-keyscan
  }
  $webhook_baseurl = 'https://github.com/adnanh/webhook/releases/download/2.8.0'
  archive { '/usr/local/bin/webhook.tar.gz':
    source          => "${webhook_baseurl}/webhook-linux-amd64.tar.gz",
    extract         => true,
    extract_command => 'tar xfz %s --no-same-owner --strip-components=1',
    extract_path    => '/usr/local/bin',
    creates         => '/usr/local/bin/webhook',
  }
  file { '/etc/systemd/system/webhook.service':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => '/vagrant/conf/webhook.service',
  }
  file { '/etc/webhook.yaml':
    ensure => present,
    source => '/vagrant/conf/webhook.yaml',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  service { 'webhook':
    ensure  => running,
    enable  => true,
    require => [
      File['/etc/systemd/system/webhook.service'],
      File['/etc/webhook.yaml'],
      Archive['/usr/local/bin/webhook.tar.gz'],
    ],
  }
  class { 'r10k':
    remote   => 'git@git.theits23.renf.ro:theits23/puppet-control.git',
    provider => 'puppet_gem',
  }
  file { '/usr/local/bin/r10k-deploy-ref':
    ensure => present,
    source => '/vagrant/shell/r10k-deploy-ref',
    owner  => 'root',
    group  => 'puppet',
    mode   => '0750',
  }
  file { [
    '/etc/puppetlabs/code/environments/production',
    '/etc/puppetlabs/code/environments/production/modules',
  ]:
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0750',
  }
}
node 'web.theits23.renf.ro' {
  notify { 'web to be configured from puppet server':
    message => 'Web server to be configured from the Puppet server.',
  }
}
