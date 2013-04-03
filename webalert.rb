require 'rubygems'
require 'sms_fu'
require 'yaml'
require 'digest/md5'
require 'open-uri'

# The new YAML parser won't handle the @ symbols sms_fu.yml uses
YAML::ENGINE.yamler = 'syck'

@config = YAML::load(File.open('config.yml'))

def write_digest(digest)
  File.open('snapshot', 'w') { |f| f.write(digest)}
end

def send_sms
  pony_config = { 
    :via => :smtp,
    :via_options => {
      :address => 'smtp.gmail.com',
      :port => '587',
      :user_name => @config['gmail']['address'],
      :password => @config['gmail']['password'],
      :authentication => :plain,
      :enable_starttls_auto => true,
      :domain => "localhost.localdomain"
    }
  }
    sms_fu = SMSFu::Client.configure(:delivery => :pony, :pony_config => pony_config)

    @config['people'].each do |person|
      sms_fu.deliver(person['phone'].to_s, person['carrier'], @config['message'])
    end 
end

def check_website
  webpage = nil
  webpage_digest = nil

  begin
    webpage = open(@config['website']).read
    webpage_digest = Digest::MD5.hexdigest(webpage)
  rescue
      if @config['log']
        puts 'Error occured while opening webpage. Trying again.'
      end
      sleep(@config['interval'])
      check_website
  end 

  if @config['log']
    puts "Digest: #{webpage_digest}"
  end

  if File.exist?('snapshot')
    snapshot_digest = File.read('snapshot')
    if @config['log']
      puts "Snapshot digest: #{snapshot_digest}"
    end

    if (snapshot_digest != webpage_digest)
      if @config['log']
        puts "Change detected - sending sms"
      end
      send_sms
    else
      if @config['log']
        puts 'No changes'
      end
    end

    write_digest(webpage_digest)
  else
    if @config['log']
      puts "No snapshot digest to compare"
    end
    write_digest(webpage_digest)
  end
end

while true
  if @config['log']
    puts "Checking #{@config['website']}"
  end
  check_website
  sleep(@config['interval'])
end