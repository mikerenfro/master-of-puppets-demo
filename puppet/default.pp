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
