#!/usr/bin/env ruby

require 'nokogiri'

@doc = Nokogiri::XML("<subtags></subtags>")

class Group
  def << value
    k, v = value.split /:\s+/, 2
    (@data ||= {})[:"#{k.downcase}"] = v
  end

  def add name, value
    (@data ||= {})[:"#{name.downcase}"] = value
  end

  def to_xml
    xml = %w{ <unit> }
    @data.each do |k,v|
      xml << "<#{k}>#{v}</#{k}>"
    end
    xml << '</unit>'
    xml.join "\n"
  end
end

groups = []
last_label = nil
last_text = nil

# TODO: Handle multi-line description
# TODO: Search for text base on indentation; catch text in continued lines;
# change comment_text to last text; also add last key

ARGF.each do |line|
  s = line.strip
  if s == '%%'
    if last_text
      groups.last.add last_label, last_text
      last_label = nil
      last_text  = nil
    end
    groups << Group.new
    next
  end
  next if groups.empty?
  if s =~ /^[A-Z][^:]+:/
    if last_text
      groups.last.add last_label, last_text
    end
    last_label, last_text = s.split(/:\s+/, 2)
    last_text.strip!
    next
  end
  last_text << " #{s.strip}"
end

groups.each do |group|
  @doc.root.add_child group.to_xml
end

puts @doc.to_xml indent: 2
