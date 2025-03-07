*** Settings ***
Library         Browser
Variables       ../Environment/environment.py
Variables       ../PageObjects/login_locators.py

*** Variables ***
${ENV}          Staging
${BROWSER}      chromium
${HEADLESS}     ${False}

*** Keywords ***
Open Application | POS
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page    ${${ENV}_URL}

Login With Valid Username And Password | POS
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}
    # Using more robust Playwright selectors
    Get Element    "${serial_key}"
    Fill Text    "${serial_key}"    ${my_dict.serial_key}
    Click    "${register_button}"
    
    # Wait and fill username
    Wait For Elements State    "${pos_username}"    state=visible    timeout=35s
    Fill Text    "${pos_username}"    ${my_dict.username_pos}
    Click    "${pos_continue_button}"
    
    # Wait and fill password
    Wait For Elements State    "${pos_password}"    state=visible    timeout=35s
    Fill Text    "${pos_password}"    ${my_dict.password_pos}
    Click    "${pos_continue_button}"
    
    # Wait for navigation
    Wait For Elements State    "${pos_continue_button}"    hidden    timeout=60s

Login Again With Same User Id And Password
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}
    Get Element    "${serial_key}"
    Fill Text    "${serial_key}"    ${my_dict.serial_key}
    Click    "${register_button}"
    
    Wait For Elements State   "${pos_username}"    state=visible    timeout=20s
    Fill Text    "${pos_username}"    ${my_dict.username_pos}
    Click    "${pos_continue_button}"
    
    Wait For Elements State    "${pos_password}"    state=visible    timeout=20s
    Fill Text    "${pos_password}"    ${my_dict.password_pos}
    Click    "${pos_continue_button}"

Get Test Data File
    [Arguments]    ${env}    ${STAGING_TD}    ${PROD_TD}
    IF    '${env}' == 'PROD'
        ${test_data_file}=    Set Variable    ${PROD_TD}
    ELSE
        ${test_data_file}=    Set Variable    ${STAGING_TD}
    END
    Log    ${test_data_file}
    RETURN    ${test_data_file}
