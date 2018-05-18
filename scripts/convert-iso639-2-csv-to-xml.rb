#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'
require 'set'

@doc = Nokogiri::XML("<iso-639-2></iso-639-2>")

used_codes = Set.new

CSV.foreach ARGV.pop, headers: true do |row|
  code = row['code']
  name = row['name']

  next if used_codes.include? code
  next if name.nil?
  next if name.strip.empty?

  lang = <<~EOF
    <language>
      <code>#{code}</code>
      <name>#{name}</name>
    </language>
  EOF

  @doc.root.add_child lang
end

puts @doc.to_xml indent: 2
