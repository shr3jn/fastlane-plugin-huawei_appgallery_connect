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

```
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
    phase_release_description: "<DESCRIPTION>"
)
```

You can retreive app id by making use of the following action

```
huawei_appgallery_connect_get_app_id(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    package_id: "<PACKAGE_ID>"
)
```

The following action can be used to submit the app for review if submit_for_review was set to false during the upload of apk

```
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
    phase_release_description: "<DESCRIPTION>"
)
```
You can also retreive app info by making use of the following action

```
huawei_appgallery_connect_get_app_info(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>"
)
```

To update the app's metadata like release notes, app name, brief info and app description you can make use of the following action

```
huawei_appgallery_connect_update_app_localization(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",
    metadata_path: "<METADATA PATH>" # defaults to fastlane/metadata/huawei
)
```

To update the GMS dependency of the app, use the following action

```
huawei_appgallery_connect_set_gms_dependency(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",
    gms_dependency: 1 #Indicates whether an app depends on GMS. 1: Yes, 0: No
)
```

Your folder structure for applying multiple languages for the metadata should look like this:

```
└── fastlane
    └── metadata
        └── huawei
            ├── en-US
            │   ├── app_name.txt
            │   └── app_description.txt
            │   └── introduction.txt
            │   └── release_notes.txt
            └── fr-FR
                ├── app_name.txt
                └── app_description.txt
                └── introduction.txt
                └── release_notes.txt
```

