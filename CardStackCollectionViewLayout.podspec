#
# Be sure to run `pod lib lint CardStackCollectionViewLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CardStackCollectionViewLayout'
  s.version          = '0.1.0'
  s.summary          = 'UICollectionViewLayout as a stack of cards.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'CardStackCollectionViewLayout provides UICollectionViewLayout using a stacked card metaphore, similar to the Apple Wallet Card view'

  s.homepage         = 'https://github.com/cdstamper/CardStackCollectionViewLayout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cdstamper' => 'chris@cdstamper.co' }
  s.source           = { :git => 'https://github.com/cdstamper/CardStackCollectionViewLayout.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/cdstamper'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CardStackCollectionViewLayout/Sources/**/*'
  
  # s.resource_bundles = {
  #   'CardStackCollectionViewLayout' => ['CardStackCollectionViewLayout/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
