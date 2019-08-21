require 'set'

IPV4_REGEX = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
IPV6_REGEX = /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/

def register(params)
  @source_field = params["source_field"]
end

def filter(event)

  if @source_field.nil?
    event.tag("http_host_source_field_not_set")
    return [event]
  end

  # Tag and quit if any fields aren't present
  if event.get(@source_field).nil?
    event.tag("#{@source_field}_not_found")
    return [event]
  end

  host = event.get(@source_field)

  related_ip = Set.new( event.get('[related][ip]'))
  related_hostname = Set.new( event.get('[related][domain]'))

  if (host =~ IPV4_REGEX) || (host =~ IPV6_REGEX)
    related_ip.add(host)
  else
    related_hostname.add(host)
  end

  if related_ip.size() > 0
    event.set( '[related][ip]', related_ip.to_a )
  end
  if related_hostname.size() > 0
    event.set( '[related][domain]', related_hostname.to_a )
  end

  return [event]
end

### Validation Tests

test "when host is hostname" do
  parameters {{"source_field" => "host"}}
  in_event {{"host" => "www.google.com"}}
  expect("related fields are set") {|events| events.first.get("[related][domain]").first == "www.google.com"}
end

test "when host is IPv4" do
  parameters {{"source_field" => "host"}}
  in_event {{"host" => "1.2.3.4"}}
  expect("the hash is computed") {|events| events.first.get("[related][ip]").first == "1.2.3.4"}
end

test "when host is IPv6" do
  parameters {{"source_field" => "host"}}
  in_event {{ "host" => "2607:f8b0:400c:c03::1a"}}
  expect("the hash is computed") {|events| events.first.get("[related][ip]").first == "2607:f8b0:400c:c03::1a" }
end
