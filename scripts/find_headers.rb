#!/usr/bin/env ruby

# Copyright (c) 2015, Dasmer Singh. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1.  Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2.  Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# 3.  Neither the name of the copyright holder(s) nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission. No license is granted to the trademarks of
# the copyright holders even if such marks are included in this software.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


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
