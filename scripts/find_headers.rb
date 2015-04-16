#!/usr/bin/env ruby

require 'pathname'
require 'xcodeproj'
require 'optparse'

ROOT = Pathname.new(File.expand_path('../../', __FILE__))

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: find_headers.rb [options]'

  opts.on('--public', 'Find public headers') do |v|
    options[:public] = v
  end

  opts.on('--private', 'Find private headers') do |v|
    options[:private] = v
  end
end.parse!

required_opts = options[:public] || options[:private]
fail ArgumentError, 'Must provide --public or --private' unless required_opts

separator = "\n"

project = Xcodeproj::Project.open(ROOT + 'ResearchKit.xcodeproj')
target = project.targets.find { |t| t.name == 'ResearchKit' }

public_headers = target.headers_build_phase.files.select do |build_file|
  settings = build_file.settings
  settings && settings['ATTRIBUTES'].include?('Public')
end

private_headers = target.headers_build_phase.files.select do |build_file|
  settings = build_file.settings
  settings && settings['ATTRIBUTES'].include?('Private')
end

if options[:public]
  puts public_headers.map { |build_file|
    build_file.file_ref.real_path.relative_path_from(ROOT)
  }.join(separator)
end

if options[:private]
  puts private_headers.map { |build_file|
    build_file.file_ref.real_path.relative_path_from(ROOT)
  }.join(separator)
end
