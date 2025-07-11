# Continuous Deployment Setup Guide

This document provides instructions for setting up the CD pipeline for deploying to TestFlight and Google Play Internal Track.

## Overview

The CD pipeline is triggered when you push a version tag (e.g., `v1.0.0`) to the repository. It will:

1. Deploy iOS app to TestFlight
2. Deploy Android app to Google Play Internal Track
3. Complete both deployments within 20 minutes

## Prerequisites

### iOS Setup

1. **Apple Developer Account**: Ensure you have an active Apple Developer account
2. **App Store Connect API Key**: Create an API key in App Store Connect
3. **Match Repository**: Set up a private Git repository for storing certificates
4. **App Configuration**: Update the app identifier and team information

### Android Setup

1. **Google Play Console**: Ensure you have access to Google Play Console
2. **Service Account**: Create a service account with Play Console access
3. **Keystore**: Generate a keystore for app signing
4. **App Configuration**: Update the package name and signing configuration

## GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

### iOS Secrets

| Secret Name                    | Description                                    | Example                                |
| ------------------------------ | ---------------------------------------------- | -------------------------------------- |
| `APP_STORE_CONNECT_API_KEY`    | App Store Connect API key content              | `-----BEGIN PRIVATE KEY-----...`       |
| `APP_STORE_CONNECT_API_KEY_ID` | API key ID                                     | `ABC123DEFG`                           |
| `APP_STORE_CONNECT_ISSUER_ID`  | Issuer ID from App Store Connect               | `12345678-1234-1234-1234-123456789012` |
| `MATCH_SSH_PRIVATE_KEY`        | Private SSH key for accessing Match repository | `-----BEGIN RSA PRIVATE KEY-----...`   |
| `MATCH_PASSWORD`               | Password for encrypting Match certificates     | `your-secure-password`                 |

### Android Secrets

| Secret Name                        | Description                      | Example                            |
| ---------------------------------- | -------------------------------- | ---------------------------------- |
| `ANDROID_KEYSTORE_BASE64`          | Base64 encoded keystore file     | `base64-encoded-keystore-content`  |
| `ANDROID_KEYSTORE_PASSWORD`        | Keystore password                | `your-keystore-password`           |
| `ANDROID_KEY_ALIAS`                | Key alias in the keystore        | `your-key-alias`                   |
| `ANDROID_KEY_PASSWORD`             | Key password                     | `your-key-password`                |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Google Play service account JSON | `{"type": "service_account", ...}` |

## Configuration Files

### iOS Configuration

1. **Update `ios/fastlane/Appfile`**:

   ```ruby
   app_identifier("com.yourcompany.travelassistantai")
   apple_id("your-apple-id@example.com")
   team_id("YOUR_TEAM_ID")
   itc_team_id("YOUR_ITC_TEAM_ID")
   ```

2. **Update `ios/fastlane/Matchfile`**:
   ```ruby
   git_url("https://github.com/your-username/certificates")
   app_identifier("com.yourcompany.travelassistantai")
   team_id("YOUR_TEAM_ID")
   username("your-apple-id@example.com")
   ```

### Android Configuration

1. **Update `android/fastlane/Appfile`**:

   ```ruby
   package_name("com.yourcompany.travelassistantai")
   json_key_file("play-store-service-account.json")
   ```

2. **Update `android/app/build.gradle`**:
   ```gradle
   android {
       signingConfigs {
           release {
               storeFile file("keystore.jks")
               storePassword System.getenv("ANDROID_KEYSTORE_PASSWORD")
               keyAlias System.getenv("ANDROID_KEY_ALIAS")
               keyPassword System.getenv("ANDROID_KEY_PASSWORD")
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

## Initial Setup Steps

### iOS Setup

1. Create a private Git repository for storing certificates (Match repository)
2. Run `match init` to initialize the Match repository
3. Run `match appstore` to generate certificates and provisioning profiles
4. Create an App Store Connect API key and download the `.p8` file
5. Add the API key content to GitHub secrets

### Android Setup

1. Generate a keystore:

   ```bash
   keytool -genkey -v -keystore android/app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your-key-alias
   ```

2. Encode the keystore to base64:

   ```bash
   base64 -i android/app/keystore.jks | pbcopy
   ```

3. Create a Google Play service account and download the JSON key
4. Add all credentials to GitHub secrets

## Deployment Process

1. **Tag a Release**:

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Monitor Deployment**:

   - Check GitHub Actions for deployment status
   - iOS builds will appear in TestFlight
   - Android builds will appear in Play Console Internal Track

3. **Verify Deployment**:
   - Test the iOS build in TestFlight
   - Test the Android build in Play Console Internal Track

## Troubleshooting

### Common Issues

1. **iOS Code Signing Errors**: Ensure Match repository is properly configured and SSH key has access
2. **Android Build Failures**: Verify keystore credentials and Google Play service account permissions
3. **API Authentication**: Check that API keys and service accounts have proper permissions

### Logs and Debugging

- Check GitHub Actions logs for detailed error messages
- Use `fastlane ios beta --verbose` locally to debug iOS issues
- Use `fastlane android internal --verbose` locally to debug Android issues

## Security Considerations

- Never commit sensitive credentials to the repository
- Use GitHub's encrypted secrets for all sensitive information
- Regularly rotate API keys and service account credentials
- Monitor access logs for unauthorized usage

## Support

For issues with the CD pipeline, check:

1. GitHub Actions logs
2. Fastlane documentation
3. Apple Developer and Google Play Console documentation
