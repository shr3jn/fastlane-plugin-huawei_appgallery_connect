# huawei_appgallery_connect plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-huawei_appgallery_connect)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-huawei_appgallery_connect`, add it to your project by running:

```bash
fastlane add_plugin huawei_appgallery_connect
```

## About huawei_appgallery_connect

Huawei AppGallery Connect Plugin can be used to upload Android application on the Huawei App Gallery using fastlane.

## Usage

To get started you will need the client id, client Secret & app ID which can be obtained from your Huawei AppGallery Connect account OR can be obtained with huawei_appgallery_connect_get_app_id action (please see example below).

```ruby
huawei_appgallery_connect(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",
    apk_path: "<APK_PATH>",
    
    # Optional, Parameter beyond this are optional
    
    # If you are facing errors when submitting for review, increase the delay time before submitting the app for review using this option:
    delay_before_submit_for_review: 20,

    # if you're uploading aab instead of apk, specify is_aab to true and specify path to aab file on apk_path
    is_aab: true, 
    
    submit_for_review: false,

    privacy_policy_url: "https://example.com",
    changelog_path: "<PATH_TO_CHANGELOG_FILE>",

    # release time to release app on specific date
    release_time: "2019-12-25T07:05:15+0000",

    # For phase wise release: set these parameters
    phase_wise_release: true,
    phase_release_start_time: "2019-12-25T07:05:15+0000",
    phase_release_end_time: "2019-12-28T07:05:15+0000",
    phase_release_percent: "10.00",
    phase_release_description: "<DESCRIPTION>",

    # For open testing configuration
    use_testing_version: true,                           # Enable open testing
    skip_manual_review: true,                           # Skip manual review for internal testing (default: true)
    test_start_time: "2024-03-20T10:00:00+0000",       # Optional: Test start time (defaults to 1 hour from now)
    test_end_time: "2024-06-08T10:00:00+0000",         # Optional: Test end time (defaults to 80 days from start)
    feedback_email: "test@example.com"                  # Email for test feedback
)
```

You can retrieve app id by making use of the following action

```ruby
huawei_appgallery_connect_get_app_id(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    package_id: "<PACKAGE_ID>"
)
```

The following action can be used to submit the app for review if submit_for_review was set to false during the upload of apk

```ruby
huawei_appgallery_connect_submit_for_review(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",

    # Optional, Parameter beyond this are optional

    # release time to release app on specific date
    release_time: "2019-12-25T07:05:15+0000",

    # For phase wise release: set these parameters
    phase_wise_release: true,
    phase_release_start_time: "2019-12-25T07:05:15+0000",
    phase_release_end_time: "2019-12-28T07:05:15+0000",
    phase_release_percent: "10.00",
    phase_release_description: "<DESCRIPTION>",

    # For open testing configuration
    use_testing_version: true,                           # Enable open testing
    skip_manual_review: true,                           # Skip manual review for internal testing (default: true)
    test_start_time: "2024-03-20T10:00:00+0000",       # Optional: Test start time (defaults to 1 hour from now)
    test_end_time: "2024-06-08T10:00:00+0000",         # Optional: Test end time (defaults to 80 days from start)
    feedback_email: "test@example.com"                  # Email for test feedback
)
```

You can also retrieve app info by making use of the following action

```ruby
huawei_appgallery_connect_get_app_info(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>"
)
```

To update the app's metadata like release notes, app name, brief info and app description you can make use of the following action

```ruby
huawei_appgallery_connect_update_app_localization(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",
    metadata_path: "<METADATA PATH>" # defaults to fastlane/metadata/huawei
)
```

To update the GMS dependency of the app, use the following action

```ruby
huawei_appgallery_connect_set_gms_dependency(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",
    gms_dependency: 1 #Indicates whether an app depends on GMS. 1: Yes, 0: No
)
```

Your folder structure for applying multiple languages for the metadata should look like this:

```
fastlane
└── metadata
    └── huawei
        ├── en-US
        │   ├── app_name
        │   ├── app_description
        │   ├── introduction
        │   └── release_notes
        └── zh-CN
            ├── app_name
            ├── app_description
            ├── introduction
            └── release_notes
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

