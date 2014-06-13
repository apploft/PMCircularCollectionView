Pod::Spec.new do |s|
  s.name             = "PMCircularCollectionView"
  s.version          = "0.0.31"
  s.summary          = "Demonstrates how a UICollectionView subclass can scroll infinitely in the horizontal or vertical direction."
  s.homepage         = "https://github.com/pm-dev/#{s.name}"
  s.license          = 'MIT'
  s.author           = { "Peter Meyers" => "petermeyers1@gmail.com" }
  s.source           = { :git => "https://github.com/pm-dev/#{s.name}.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true
  s.source_files     = 'Classes/**/*.{h,m}'
  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks       = 'Foundation', 'CoreGraphics', 'UIKit'
  s.dependency 'PMUtils'
end
