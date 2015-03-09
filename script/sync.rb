#!/usr/bin/env ruby

require 'json'
require 'net/http'

SYNC_URI = URI("https://dev.sfv2.cox.mxmcloud.com/showroom-sync")
RECORDS_URI = URI('http://showroom.mxm/stats/records.json')

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
