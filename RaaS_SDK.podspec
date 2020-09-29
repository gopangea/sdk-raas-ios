Pod::Spec.new do |spec|
  spec.name         = "RaaS_SDK"
  spec.version      = "0.0.9"
  spec.summary      = "Pangea RaaS for mitigate fraud and to securely collect debit card information for payment"
  spec.description  = <<-DESC
  The Pangea Remittance as a Service (RaaS) API allows any company to add remittances to their 
  existing product or service by integrating a simple API while leveraging Pangea's money transmitter license,
  compliance controls, and integrations with payment networks worldwide. 
  Companies using the API do not need their own money transmitter license.

    The API facilitates a complete end to end transfer of funds from a sender's funding mechanism to the receiver's funding mechanism, such as a debit card or bank account. Transfers can be created, completed, cancelled or refunded. The API supports retrieving transaction status and receipts.
                   DESC
  spec.homepage     = "https://github.com/gopangea/sdk-raas-ios"
  spec.license      = "Apache License 2.0"
  spec.author             = { "Pangea Money Transfer" => "carlos.hernandez@gopangea.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/gopangea/sdk-raas-ios.git", :tag => "0.0.9"}
  spec.dependency 'RiskifiedBeacon', '1.2.7'
  spec.static_framework = true
  spec.source_files  = "RaaS_SDK/*.*"
  #spec.exclude_files = "RaaS_SDK/Info.plist", "RaaS_SDK/libriskifiedbeacon.a", "RaaS_SDK/RiskifiedBeacon.h"
  spec.exclude_files = "RaaS_SDK/Info.plist", "RaaS_SDK/libriskifiedbeacon.a"
  spec.swift_version = "4.2"
end
