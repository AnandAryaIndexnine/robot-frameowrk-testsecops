*** Settings ***
Library    AppiumLibrary
Library    OperatingSystem
Library    Collections
Library    String


*** Variables ***
${LAMBDATEST_USERNAME}      YOUR_USER_NAME
${LAMBDATEST_ACCESSKEY}     YOUR_ACCESS_KEY
${LT_REMOTE_URL}            https://${LAMBDATEST_USERNAME}:${LAMBDATEST_ACCESSKEY}@mobile-hub.lambdatest.com/wd/hub
${PLATFORM_NAME}            android
${APP_PACKAGE}              android-lambdatest
${APP_ACTIVITY}             your.app.activity
${deviceName}               Galaxy S22 5G
${platformVersion}          14.0
${app}                      APP_ID



*** Keywords ***
Open Android Application On Lamda Test
    open application
        ...    ${LT_REMOTE_URL}
        ...    deviceName=${deviceName}
        ...    platformVersion=${platformVersion}
        ...    platformName=${PLATFORM_NAME}
        ...    isRealMobile=true
        ...    app=${app}
        ...    build=Android_Build_new
        ...    name=LT_Demo
        ...    automationName=UiAutomator2

Open IOS Application On Lamda Test
    open application
        ...    ${LT_REMOTE_URL}
        ...    deviceName=${deviceName}
        ...    platformVersion=${platformVersion}
        ...    platformName= iOS
        ...    ${lt_host}
        ...    deviceName=${deviceName}
        ...    platformVersion=${platformVersion}
        ...    platformName=${platformName}
        ...    isRealMobile=true
        ...    app=${lt_app_url}
        ...    name=IOS
        ...    automationName= XCUITest
        ...    appProfiling=true
        ...    network=true