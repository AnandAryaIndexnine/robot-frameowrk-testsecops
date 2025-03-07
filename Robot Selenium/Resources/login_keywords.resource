*** Settings ***
Library         RequestsLibrary
Library         SeleniumLibrary
Variables       ../Environment/environment.py
Variables       ../PageObjects/login_locators.py

*** Variables ***
${ENV}    Staging

*** Keywords ***
Open Application | POS
    Open Browser    ${${ENV}_URL}    ${browser}
    Maximize Browser Window

Login With Valid Username And Password | POS
    [Arguments]    ${search_data}
    Inject JavaScript For Fetch
    Inject JavaScript For XHR
    ${my_dict}=    Create Dictionary    &{search_data}
    Input Text    ${serial_key}    ${my_dict.serial_key}
    Click Button    ${register_button}
    Wait Until Element Is Visible    ${pos_username}    timeout=35s
    Input Text    ${pos_username}    ${my_dict.username_pos}
    Click Button    ${pos_continue_button}
    Wait Until Element Is Visible    ${pos_password}    timeout=35s
    Input Text    ${pos_password}    ${my_dict.password_pos}
    Click Button    ${pos_continue_button}
    Wait Until Page Does Not Contain Element    ${pos_continue_button}    timeout=60s

Login Again With Same User Id And Password
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}
    Input Text    ${serial_key}    ${my_dict.serial_key}
    Click Button    ${register_button}
    Wait Until Element Is Visible    ${pos_username}    timeout=20s
    Input Text    ${pos_username}    ${my_dict.username_pos}
    Click Button    ${pos_continue_button}
    Wait Until Element Is Visible    ${pos_password}    timeout=20s
    Input Text    ${pos_password}    ${my_dict.password_pos}
    Click Button    ${pos_continue_button}

Get Test Data File
    [Arguments]    ${env}    ${STAGING_TD}    ${PROD_TD}
    IF    '${env}' == 'PROD'
        ${test_data_file}=    Set Variable    ${PROD_TD}
    ELSE
        ${test_data_file}=    Set Variable    ${STAGING_TD}
    END
    Log    ${test_data_file}
    RETURN    ${test_data_file}
