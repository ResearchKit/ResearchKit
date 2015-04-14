Pod::Spec.new do |s|
  s.name         = 'ResearchKit'
  s.version      = '1.0.0'
  s.summary      = 'ResearchKit is an open source software framework that makes it easy to create apps for medical research or for other research projects.'
  s.homepage     = 'https://www.github.com/ResearchKit/ResearchKit'
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "Apple Inc." => "http://apple.com" }
  s.source       = { :git => 'https://github.com/ResearchKit/ResearchKit.git', :tag => "v#{s.version}"}
  s.source_files = 'ResearchKit/**/*'
  s.private_header_files = 'ResearchKit/**/*Private.h'
  s.resources    = 'ResearchKit/**/*.{fsh,vsh}', 'ResearchKit/Animations/**/*.m4v', 'ResearchKit/Artwork.xcassets', 'ResearchKit/Localized/*.lproj'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
end
