# frozen_string_literal: true

Given(/Given command "([^"]*)"/) do |command|
  @command = command
end

Given(/Given options? "([^"]*)"/) do |options|
  @options = options
end

When(/When we run command/) do
  @stdout, @stderr, @status = Open3.capture3("#{@command} #{@options}")
  [@stdout, @stderr].each(&:chomp!)
end

Then(/Then exit status is "(\d+)"/) do |status|
  unless @status.exitstatus == status.to_i
    raise "Got #{@status} instead of #{status}"
  end
end

Then(/Then stdout is '([^']*)'/) do |string|
  unless @stdout == string
    raise "stdout: Expectected '#{string}'. Got '#{@stdout}'"
  end
end

Then(/Then stdout is ("[^"]*")/) do |string|
  unless @stdout.inspect == string
    raise "stdout: Expectected '#{string}'. Got '#{@stdout}'"
  end
end

Then(/Then stderr is "([^"]*)"/) do |string|
  unless @stderr == string
    raise "stderr: Expectected '#{string}'. Got '#{@stderr}'"
  end
end

Then(/Then stderr is '([^']*)'/) do |string|
  unless @stderr == string
    raise "stderr: Expectected '#{string}'. Got '#{@stderr}'"
  end
end

Then(/Then stdout includes "([^"]*)"/) do |string|
  raise "Stdout did not include '#{string}'" unless @stdout.include?(string)
end

Then(/Then stderr includes "([^"]*)"/) do |string|
  raise "Stderr did not include '#{string}'" unless @stderr.include?(string)
end

Then %r{Then stdout matches /([^/]*)/} do |string|
  unless Regexp.new(string).match?(@stdout)
    raise "Stdout did not match '#{string}'"
  end
end

Then(/Then (\w+) => (\S+)/) do |k, v|
  h = JSON.parse @stdout
  raise "#{k} is not #{v}, it's #{h[k]}" unless h[k] == v
end

Then(/Then (\w+) maps to true/) do |k|
  h = JSON.parse @stdout
  raise "#{k} is not true, it's #{h[k]}" unless h[k] == true
end

Then(/Then (\w+) maps to nil/) do |k|
  h = JSON.parse @stdout
  raise "#{k} is not nil, it's #{h[k]}" unless h[k].nil?
end

Then(/Then (\w+) is \[(\S+)\]/) do |k, v|
  h = JSON.parse @stdout
  l = h[k].join(',')
  raise "#{k} is not #{v}, it's #{l}" unless l == v
end

Then(/Then header is "(.*)"/) do |v|
  header = @stdout.split("\n", 2).first
  raise "Header is not #{v}, it's #{header}" unless header == v
end

Then(/Then digest is "(.*)"/) do |v|
  # This is just to ensure not changes to the output occured in future edits...
  # Note that stdout was striped, so adding the newline back in,
  # making the use of piped md5sum output possible.
  digest = Digest::MD5.hexdigest("#{@stdout}\n")
  raise "Digest is not #{v}, it's #{digest}" unless digest == v
end
