source 'git@github.com:EnterTech/PodSpecs.git'

platform :ios ,'8.0'
use_frameworks!

def uicomponent
  pod 'DynamicColor', '~> 3.0.0'
end

def utility
  pod 'SnapKit' , '~> 3.0.0'
end

def personal
    pod 'NaptimeDevice', :git => 'https://github.com/qiubei/Naptime-Device-iOS.git', :branch => 'master'
end

target 'QBFastlaneMonkeyTest' do
  utility 
  uicomponent
  personal
end
