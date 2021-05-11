Pod::Spec.new do |s|
  s.name         = 'ResearchKit'
  s.version      = '0.0.7'
  s.summary      = 'ResearchKit is an open source software framework that makes it easy to create apps for medical research or for other research projects.'
  s.homepage     = 'https://www.github.com/ResearchKit/ResearchKit'
  s.documentation_url = 'http://researchkit.github.io/docs/'
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { 'researchkit.org' => 'http://researchkit.org' }
  s.source       = { :git => 'https://github.com/HippocratesTech/OTFResearchKit', :tag => s.version.to_s }
 # s.source       = { :git => './', :tag => s.version.to_s }
  s.resources    = 'ResearchKit/**/*.{fsh,vsh}', 'ResearchKit/Animations/**/*.m4v', 'ResearchKit/Artwork.xcassets', 'ResearchKit/Localized/*.lproj'
  s.platform     = :ios, '11.0'
  s.requires_arc = true
  s.swift_version = '5.0'
  s.module_map = "ResearchKit/ResearchKit.modulemap"
  s.platform     = :ios, '11.0'
  s.default_subspec = 'Care'

  s.subspec 'Care' do |ss|
    ss.name = 'Care'
    ss.source_files = 'ResearchKit/**/*.{h,m,swift}'
    ss.public_header_files = `./scripts/find_headers.rb --public`.split("\n")
    ss.private_header_files = `./scripts/find_headers.rb --private`.split("\n")
    ss.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'CARE=1'
    }
    ss.platform     = :ios, '11.0'
  end

  s.subspec 'Health' do |ss|
    ss.name = 'Health'
    ss.source_files = 'ResearchKit/**/*.{h,m,swift}'
    ss.public_header_files = `./scripts/find_headers.rb --public`.split("\n")
    ss.private_header_files = `./scripts/find_headers.rb --private`.split("\n")
    ss.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'HEALTH=1'
    }
    ss.platform     = :ios, '11.0'
  end

  s.subspec 'CareHealth' do |ss|
    ss.name = 'CareHealth'
    ss.source_files = 'ResearchKit/**/*.{h,m,swift}'
    ss.public_header_files = `./scripts/find_headers.rb --public`.split("\n")
    ss.private_header_files = `./scripts/find_headers.rb --private`.split("\n")
    ss.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => ['HEALTH=1','CARE=1']
    }
    ss.platform     = :ios, '11.0'
  end


end
