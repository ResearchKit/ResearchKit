Pod::Spec.new do |s|
  s.name         = 'ResearchKit'
  s.version      = '3.0.1'
  s.summary      = 'ResearchKit is an open source software framework that makes it easy to create apps for medical research or for other research projects.'
  s.homepage     = 'https://www.github.com/ResearchKit/ResearchKit'
  s.documentation_url = 'http://researchkit.github.io/docs/'
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { 'researchkit.org' => 'http://researchkit.org' }
  s.source       = { :git => 'https://github.com/ResearchKit/ResearchKit.git', :tag => s.version.to_s }

  s.default_subspec = "ResearchKitAllTargets"

  s.subspec 'ResearchKitCore' do |ss|
    ss.vendored_frameworks = 'xcframework/ResearchKit.xcframework'
  end

  s.subspec 'ResearchKitUI' do |ss|
    ss.vendored_frameworks = 'xcframework/ResearchKitUI.xcframework'
    ss.dependency 'ResearchKit/ResearchKitCore'
  end

  s.subspec 'ResearchKitActiveTask' do |ss|
    ss.vendored_frameworks = 'xcframework/ResearchKitActiveTask.xcframework'
    ss.dependency 'ResearchKit/ResearchKitUI'
    ss.dependency 'ResearchKit/ResearchKitCore'
  end

  s.subspec 'ResearchKitAllTargets' do |ss|
    ss.dependency 'ResearchKit/ResearchKitCore'
    ss.dependency 'ResearchKit/ResearchKitUI'
    ss.dependency 'ResearchKit/ResearchKitActiveTask'
  end
end

