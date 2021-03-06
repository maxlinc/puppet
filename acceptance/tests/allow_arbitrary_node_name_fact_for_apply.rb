test_name "node_name_fact should be used to determine the node name for puppet apply"

success_message = "node_name_fact setting was correctly used to determine the node name"

node_names = []

on agents, facter('kernel') do
  node_names << stdout.chomp
end

node_names.uniq!

manifest = %Q[
  Exec { path => "/usr/bin:/bin" }
  node default {
    exec { "false": }
  }
]

node_names.each do |node_name|
  manifest << %Q[
    node "#{node_name}" {
      exec { "echo #{success_message}": }
    }
  ]
end

on agents, puppet_apply("--verbose --node_name_fact kernel"), :stdin => manifest do
  assert_match(success_message, stdout)
end
