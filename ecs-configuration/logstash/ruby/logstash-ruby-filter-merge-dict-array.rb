def register(params)
  @source_field = params["source_field"]
  @target_field = params["target_field"]
end

def filter(event)

  # Tag and quit if source field isn't set
  if @source_field.nil?
    event.tag("array_dict_merge_source_not_set")
    return [event]
  end
  # Tag and quit if target field isn't set
  if @target_field.nil?
    event.tag("array_dict_merge_target_not_set")
    return [event]
  end

  # Tag and quit if source field isn't present
  if event.get(@source_field).nil?
    event.tag("#{@source_field}_not_found")
    return [event]
  end

  source = event.get(@source_field)
  target = Array(event.get(@target_field))

  target = target.push(source)
  event.set(@target_field, target)

  return [event]

end

test "when source is atomic type" do
  parameters {{"source_field" => "source", "target_field" => "target"}}
  in_event {{"source" => "foo", "target" => []}}
  expect("target is list and contains source data"){|events|
    events.first.get("[target]").is_a? Array
    events.first.get("[target]").first == "foo"
  }
end

test "when source is dict type" do
  parameters {{"source_field" => "source", "target_field" => "target"}}
  in_event {{"source" => {"foo" => "moo", "bar" => "baz"}, "target" => []}}
  expect("target is list and contains source data"){|events|
    events.first.get("[target]").is_a? Array
    events.first.get("[target]").first == {"foo" => "moo", "bar" => "baz"}
  }
end
