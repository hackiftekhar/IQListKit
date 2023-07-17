project 'ListKit.xcodeproj'

platform :ios, '13.0'
use_frameworks!

target 'ListKit' do

    pod 'SwiftLint'
    pod 'IQListKit', :path => '.'
end

post_install do |installer|

  installer.pods_project.targets.each do |target|

    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
     end
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
