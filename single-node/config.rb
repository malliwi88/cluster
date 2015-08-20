# Endpoint to generate a discovery token
$new_discovery_url='https://discovery.etcd.io/new?size=1'

# Automatically replace the discovery token
if File.exists?('user-data') && ARGV[0].eql?('up')
  require 'open-uri'
  require 'yaml'

  token = open($new_discovery_url).read
  data = YAML.load(IO.readlines('user-data')[1..-1].join)
  data['coreos']['etcd2']['discovery'] = token
  yaml = YAML.dump(data)
  File.open('user-data', 'w') { |file| file.write("#cloud-config\n\n#{yaml}") }
end

# Single instance cluster
$num_instances = (ENV['CLUSTER_SIZE'] || 1).to_i

# Basename of the VM
$instance_name_prefix = "core"

# CoreOS channel
$update_channel = 'alpha'

# Enable port forwarding of Docker TCP socket
$expose_docker_tcp = 2375

# Custom port forwads
$forwarded_ports = {}

# VM settings
$vm_gui = false
$vm_memory = 512
$vm_cpus = 1
