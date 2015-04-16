Pod::Spec.new do |s|
  s.name         = 'ResearchKit'
  s.version      = '1.0.0'
  s.summary      = 'ResearchKit is an open source software framework that makes it easy to create apps for medical research or for other research projects.'
  s.homepage     = 'https://www.github.com/ResearchKit/ResearchKit'
  s.documentation_url = 'http://researchkit.github.io/docs/'
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "Apple Inc." => "http://apple.com" }
  s.source       = { :git => 'https://github.com/ResearchKit/ResearchKit.git', :tag => "v#{s.version}"}
  s.public_header_files = `./scripts/find_headers.rb --public`.split("\n")
  s.private_header_files = `./scripts/find_headers.rb --private`.split("\n")
  s.source_files = 'ResearchKit/**/*.{h,m}'
  s.resources    = 'ResearchKit/**/*.{fsh,vsh}', 'ResearchKit/Animations/**/*.m4v', 'ResearchKit/Artwork.xcassets', 'ResearchKit/Localized/*.lproj'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
end
