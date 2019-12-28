source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

post_install do |installer|
     installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
               config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
               if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
                   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
               end
          end
     end
end

target 'Forum' do
	pod 'IGHTMLQuery', '~> 0.9.1'			#2018/03/04
	pod 'JSONModel', '~> 1.7.0' 			#2018/03/04
	pod 'MJRefresh', '~> 3.1.15.3'			#2018/03/04
	pod 'SVProgressHUD', '~> 2.2.5'			#2018/03/04
	pod 'ActionSheetPicker-3.0', '~>2.3.0'		#2018/03/04
	pod 'FDFullscreenPopGesture', '1.1'		#2018/03/04
	pod 'SDWebImage', '~>3.7.5'			#2018/03/04
	pod 'MGSwipeTableCell', '~>1.6.11'		#2018/03/04
	pod 'NYTPhotoViewer', '~> 2.0.0'		#2018/03/04
  pod 'AFNetworking', '~> 3.2.1'
end
    #pod 'UITableView+FDTemplateLayoutCell', '~> 1.4'
    #pod 'AVOSCloudIM', '~>4.2.0'
