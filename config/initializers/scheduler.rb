def call_rake (task, options = {})
  options[:rails_env] ||= Rails.env
  args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
  system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
end
#call_rake "scheduler:start"