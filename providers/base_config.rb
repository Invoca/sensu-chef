action :create do
  definitions = Sensu::Helpers.select_attributes(
    node.sensu,
    %w[rabbitmq redis api dashboard]
  )

  config = Sensu::Helpers.data_bag_item("config", true)

  if config
    definitions = Chef::Mixin::DeepMerge.merge(definitions, config.to_hash)
  end

  definitions = Sensu::Helpers.sanitize(definitions)
  if definitions['dashboard'] && definitions['dashboard'].has_key?('disable_authentication')
    if definitions['dashboard'].delete('disable_authentication')
      definitions['dashboard']['user'] = nil
      definitions['dashboard']['password'] = nil
    end
  end

  f = sensu_json_file ::File.join(node.sensu.directory, "config.json") do
    content definitions
  end

  new_resource.updated_by_last_action(f.updated_by_last_action?)
end
