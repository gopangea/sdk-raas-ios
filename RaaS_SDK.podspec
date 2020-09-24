Pod::Spec.new do |spec|
  spec.name         = "RaaS_SDK"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of RaaS_SDK."
  spec.description  = <<-DESC
  Pangea RaaS for mitigate fraud and to securely collect debit card information for payment
                   DESC
  spec.homepage     = "https://github.com/gopangea/sdk-raas-ios"
  spec.license      = "Apache License 2.0"
  spec.author             = { "Pangea Money Transfer" => "carlos.hernandez@gopangea.com" }
  spec.platform     = :ios, "10.0"
  #spec.source       = { :git => "http://EXAMPLE/RaaS_SDK.git", :tag => "#{spec.version}" }
  #spec.source       = { :path => '.' }
  spec.source       = { :git => "URL", :tag => "0.0.1" }
  spec.dependency 'RiskifiedBeacon', '1.2.7'
  spec.static_framework = true
  spec.source_files  = "RaaS_SDK/*.*"
  #spec.exclude_files = "RaaS_SDK/Info.plist", "RaaS_SDK/libriskifiedbeacon.a", "RaaS_SDK/RiskifiedBeacon.h"
  spec.exclude_files = "RaaS_SDK/Info.plist", "RaaS_SDK/libriskifiedbeacon.a"
  spec.swift_version = "4.2"
end
