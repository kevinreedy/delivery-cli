case node['platform_family']
when 'rhel', 'fedora'
  # centos needs to have the default install prefix for rust added to
  # ld.so.conf
  file "/etc/ld.so.conf.d/rust-x86_64.conf" do
    content <<-EOH
  /usr/local/lib
  EOH
    mode "0644"
  end

  execute "reload ldconfig" do
    command "ldconfig"
  end

  package "git"

  include_recipe "delivery_rust::_omnibus"
when 'debian'
  include_recipe 'apt::default'

  package "curl"
  package "git"

  include_recipe "delivery_rust::_omnibus"
when 'windows'
  env 'Add Omnibus ruby to PATH' do
    key_name 'PATH'
    delim ';'
    action :modify
    value "C:/rubies/#{node['omnibus']['ruby_version']}/bin"
  end

  env "Add Omnibus ruby's MinGW to PATH" do
    key_name 'PATH'
    delim ';'
    action :modify
    value "C:/rubies/#{node['omnibus']['ruby_version']}/mingw/bin"
  end
when 'mac_os_x'
else
  log "Unrecognized platform_family '#{node['platform_family']}'"
end
