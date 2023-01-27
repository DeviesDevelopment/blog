---
title: "Xcode 14 & SPM: Deployment Pipeline in Azure"
date: 2023-01-27T08:00:00+01:00
tags: [Xcode, SPM, Apple, iOS, Azure, Pipeline]
featured_image: ""
description: "Build, Sign, and Deploy an iOS App"
slug: "xcode-14-manual-signing"
author:
 - Jean-Paul Massoud
---

_[tl;dr](#tldr)_

## Background
Continuous Deployment (CD) pipelines are great tools to automate the deployment process of a software. Their main objective is to minimise human error and maintain a consistent process for how the software is released.

For Xcode projects this becomes a time critical process once the project has to be built for different configurations and/or environments. Since every configuration might require a different signing method, or even different deployment platform.

This article explains how to set up a project so that an Azure pipeline can build, archive, sign, and deploy the project to TestFlight. However, this approach is mostly focused on manually signing an SPM (Swift Package Manager) managed project.

## Motive
SPM is an Xcode integrated tool for managing the distribution of Swift code. It helps automating the process of downloading, compiling, and linking dependencies.
However, when it comes to signing the code, SPM will try to sign the dependencies with the same provisioning profile that is used for the project. In most cases, this will not be allowed and results in build failure when trying to package the archive of the project.

## Setup
The project uses three different configurations and schemas (DEBUG, BETA, and RELEASE). While the signing process is Xcode managed; meaning Xcode will automatically manage the signing process. This setup saves headaches of certificates and profiles management when trying to build or run the project locally.

## Implementation

* First create a variable group in your Azure pipeline, from the library tab. Here we will store all variables/credentials for a specific build configuration that are used within the pipeline .i.e. bundle ID, provisioning profile, certificate... etc.

* In your pipeline .yml file add the environment variables that will be used later in the process

```yml
variables:
  - group: testflight-variables
  - name: configuration
    value: 'BETA'
  - name: sdk
    value: 'iphoneos'
  - name: scheme
    value: 'BETA'
  - name: entitlement-path
    value: MyProject/project.entitlements
  - name: app-path
    value: Products/Applications/*.app
  - name: export-options
    value: export.plist
```

* Now since the project uses Xcode 14, we are going to need a macOS 12 image for the pipeline

```yml
pool:
  vmImage: "macOS-12"
```

* Once the above is set, it's time to define the steps of the deployment process

    1. Setup the mac image to use the distribution certificate by installing the certificate
    ```yml
      - task: InstallAppleCertificate@2
        displayName: "Install distribution certificate"
        inputs:
            certSecureFile: '$(p12CertName)'
            certPwd: '$(p12Password)'
            keychain: 'temp'
            deleteCert: true
    ```
    2.  Setup the mac image to use the distribution provisioning profile by installing the profile
    ```yml
      - task: InstallAppleProvisioningProfile@1
        displayName: "Install Provisioning Profile"
        inputs:
            provisioningProfileLocation: 'secureFiles'
            provProfileSecureFile: '$(betaProvisioningProfile)'
            removeProfile: true
    ```
    3. Using `PlistBuddy` create an export-options file that is used to sign the archive when exporting the binary
    ```yml
      - task: Bash@3
        displayName: 'Create export options file'
        inputs:
            targetType: 'inline'
            script:
            /usr/libexec/PlistBuddy -c "Add :method string app-store" $(Pipeline.Workspace)/$(export-options) &&
            /usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" $(Pipeline.Workspace)/$(export-options) &&
            /usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$(betaAppIdentifier) string $(APPLE_PROV_PROFILE_UUID)" $(Pipeline.Workspace)/$(export-options) &&
            /usr/libexec/PlistBuddy -c "Add :signingCertificate string $(APPLE_CERTIFICATE_SIGNING_IDENTITY)" $(Pipeline.Workspace)/$(export-options) &&
            /usr/libexec/PlistBuddy -c "Add :signingStyle string manual" $(Pipeline.Workspace)/$(export-options) &&
            /usr/libexec/PlistBuddy -c "Add :teamID string $(teamId)" $(Pipeline.Workspace)/$(export-options) &&
            /usr/libexec/PlistBuddy -c "Add :stripSwiftSymbols bool true" $(Pipeline.Workspace)/$(export-options) &&
            /usr/libexec/PlistBuddy -c "Add :compileBitcode bool false" $(Pipeline.Workspace)/$(export-options)
    ```

    4. Now it's time for archiving the project. Here we set some flags for xcodebuild to save the archive in a specific directory (that will be used later), but most importantly is to set `CODE_SIGNING_ALLOWED=No'` since we don't want Xcode to sign the project along with its dependencies. On a side note, disable Xcode-pretty and add `-verbose` to get better debug output in the pipeline console
    ```yml
      - task: Xcode@5
        displayName: 'Xcode archive'
        inputs:
            actions: 'archive'
            configuration: '$(configuration)'
            sdk: '$(sdk)'
            scheme: '$(scheme)'
            xcodeVersion: '14'
            signingOption: 'default'
            packageApp: false
            useXcpretty: false
            args: '-destination generic/platform=iOS -archivePath $(Pipeline.Workspace)/$(scheme).xcarchive -verbose CODE_SIGNING_ALLOWED=No'
    ```
    
    5. Now that we have successfully archived the project, there is still a missing critical part before we sign and export the binary, that is to sign the archive with the project entitlements. These entitlements files are not bundled within the archive and since many projects require different entitlements to use Apple services .i.e. Push notification, Universal domains, signing with Apple... etc, this step is critical to not get the App rejected by Apple. Here we use a bash script to locate the entitlements file and use `codesign` to sign the `.app` that is located within the archive
    ```yml
      - task: Bash@3
        displayName: 'Entitlements signing'
        inputs:
            targetType: 'inline'
            script:
            codesign --entitlements $(Build.Repository.LocalPath)/$(entitlement-path) -f -s "$(APPLE_CERTIFICATE_SIGNING_IDENTITY)" $(Pipeline.Workspace)/$(scheme).xcarchive/$(app-path)
    ```

    6. The next step is to sign and export an `.ipa` file from the archive. This `.ipa` will be then published to a desired platform
    ```yml
      - task: Bash@3
        displayName: 'Xcode sign and export'
        inputs:
            targetType: 'inline'
            script:
            /usr/bin/xcodebuild -exportArchive -archivePath $(Pipeline.Workspace)/$(scheme).xcarchive -exportPath $(Build.ArtifactStagingDirectory) -exportOptionsPlist $(Pipeline.Workspace)/$(export-options)
    ```

    7. The last step now that we have a signed `.ipa` file is to publish it to a desired platform. For this post TestFlight is used as a hosting platform. Here we'll be using Fastlane to publish the app. Ideally one would want to use an API authentication method with `AppStoreConnect`, but for simplicity reasons a regular user authentication method is used
    ```yml
      - task: AppStoreRelease@1
        inputs:
            authType: 'UserAndPass'
            username: '$(AppStoreUsername)'
            password: '$(AppStorePassword)'
            isTwoFactorAuth: true
            appSpecificPassword: '$(AppStoreSpecificPassword)'
            releaseTrack: 'TestFlight'
            ipaPath: '$(Build.ArtifactStagingDirectory)/*.ipa'
            shouldSkipWaitingForProcessing: true
            appIdentifier: '$(betaAppIdentifier)'
            appType: 'iOS'
            appSpecificId: '$(AppStoreSpecificId)'
            teamId: '$(teamId)'
            teamName: '$(teamName)'
            installFastlane: true
    ```

    ## Conclusion
    Automating continuous deployment for Xcode projects can be overwhelming but at the end it doesn't only save valuable time, but also helps others to easily contribute to the project by leaving the signing and deployment headache to the pipeline to deal with. In addition, many of these steps can be handled seamlessly with advanced Fastlane configuration, but to know how to do it manually with Xcode is valuable in my honest opinion.


---
# TL;DR
The complete Yaml file:
```yml
# Environement variables
variables:
  - group: testflight-variables
  - name: configuration
    value: 'BETA'
  - name: sdk
    value: 'iphoneos'
  - name: scheme
    value: 'BETA'
  - name: entitlement-path
    value: MyProject/project.entitlements
  - name: app-path
    value: Products/Applications/*.app
  - name: export-options
    value: export.plist


trigger:
- none


pool:
  vmImage: "macOS-12"


steps:


- task: InstallAppleCertificate@2
  displayName: "Install distribution certificate"
  inputs:
   certSecureFile: '$(p12FileName)'
   certPwd: '$(p12Password)'
   keychain: 'temp'
   deleteCert: true


- task: InstallAppleProvisioningProfile@1
  displayName: "Install Provisioning Profile"
  inputs:
    provisioningProfileLocation: 'secureFiles'
    provProfileSecureFile: '$(betaProvisioningProfile)'
    removeProfile: true


- task: Bash@3
    displayName: 'Create export options file'
    inputs:
        targetType: 'inline'
        script:
        /usr/libexec/PlistBuddy -c "Add :method string app-store" $(Pipeline.Workspace)/$(export-options) &&
        /usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" $(Pipeline.Workspace)/$(export-options) &&
        /usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$(betaAppIdentifier) string $(APPLE_PROV_PROFILE_UUID)" $(Pipeline.Workspace)/$(export-options) &&
        /usr/libexec/PlistBuddy -c "Add :signingCertificate string $(APPLE_CERTIFICATE_SIGNING_IDENTITY)" $(Pipeline.Workspace)/$(export-options) &&
        /usr/libexec/PlistBuddy -c "Add :signingStyle string manual" $(Pipeline.Workspace)/$(export-options) &&
        /usr/libexec/PlistBuddy -c "Add :teamID string $(teamId)" $(Pipeline.Workspace)/$(export-options) &&
        /usr/libexec/PlistBuddy -c "Add :stripSwiftSymbols bool true" $(Pipeline.Workspace)/$(export-options) &&
        /usr/libexec/PlistBuddy -c "Add :compileBitcode bool false" $(Pipeline.Workspace)/$(export-options)


- task: Xcode@5
  displayName: 'Xcode archive'
  inputs:
    actions: 'archive'
    configuration: '$(configuration)'
    sdk: '$(sdk)'
    scheme: '$(scheme)'
    xcodeVersion: '14'
    signingOption: 'default'
    packageApp: false
    useXcpretty: false
    args: '-destination generic/platform=iOS -archivePath $(Pipeline.Workspace)/$(scheme).xcarchive -verbose CODE_SIGNING_ALLOWED=No'


- task: Bash@3
  displayName: 'Code signing'
  inputs:
    targetType: 'inline'
    script:
      codesign --entitlements $(Build.Repository.LocalPath)/$(entitlement-path) -f -s "$(APPLE_CERTIFICATE_SIGNING_IDENTITY)" $(Pipeline.Workspace)/$(scheme).xcarchive/$(app-path)


- task: Bash@3
  displayName: 'Xcode export'
  inputs:
    targetType: 'inline'
    script:
      /usr/bin/xcodebuild -exportArchive -archivePath $(Pipeline.Workspace)/$(scheme).xcarchive -exportPath $(Build.ArtifactStagingDirectory) -exportOptionsPlist $(Pipeline.Workspace)/$(export-options)


- task: AppStoreRelease@1
  inputs:
    authType: 'UserAndPass'
    username: '$(username)'
    password: '$(password)'
    isTwoFactorAuth: true
    appSpecificPassword: '$(appSpecificPassword)'
    releaseTrack: 'TestFlight'
    ipaPath: '$(Build.ArtifactStagingDirectory)/*.ipa'
    shouldSkipWaitingForProcessing: true
    appIdentifier: '$(betaAppIdentifier)'
    appType: 'iOS'
    appSpecificId: '$(appSpecificId)'
    teamId: '$(teamId)'
    teamName: '$(teamName)'
    installFastlane: true  
```