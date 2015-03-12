#!/usr/bin/env ruby

require 'json'
require 'net/http'

def usage(exit_code)
  puts "Usage: #{$0} ENVIRONMENT"
  puts "Syncs the records to the given ENVIRONMENT"
  puts "    ENVIRONMENT   dev|staging|prod"
  exit exit_code
end

ENVIRONMENT = ARGV[0]
RECORDS_URI = URI('http://showroom.mxm/stats/records.json')

case ENVIRONMENT
when 'dev', 'staging'
  SYNC_URI = URI("https://#{ENVIRONMENT}.sfv2.cox.mxmcloud.com/showroom-sync")
when 'prod'
  SYNC_URI = URI("https://sfv2.cox.mxmcloud.com/showroom-sync")
else
  $stderr.puts "Invalid environment"
  usage 1
end

res = Net::HTTP.start("localhost", RECORDS_URI.port) do |http|
  req = Net::HTTP::Get.new RECORDS_URI
  http.request req
end

res_body = JSON.parse(res.body)
if res_body["status"] == "success"
  uri = SYNC_URI.dup
  res = Net::HTTP.start(SYNC_URI.host, SYNC_URI.port, use_ssl: SYNC_URI.scheme == "https") do |http|
    req = Net::HTTP::Post.new SYNC_URI
    req['Content-Type'] = 'application/json'
    req.body = res_body["data"].to_json
    http.request req
  end

else
  $stderr.printf("Error getting records\n    %s\n", res_body["message"])
end
