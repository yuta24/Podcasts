# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'Core' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Core

  target 'CoreTests' do
    # Pods for testing
  end

end

target 'Podcasts' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Podcasts
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'

  target 'PodcastsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PodcastsUITests' do
    # Pods for testing
  end

end

target 'PodcastsWidgetExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PodcastsWidgetExtension

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
