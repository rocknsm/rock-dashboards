LogStash::PLUGIN_REGISTRY.add(:modules, "bro", LogStash::Modules::Scaffold.new("bro", File.join(File.dirname(__FILE__), "..", "configuration")))
