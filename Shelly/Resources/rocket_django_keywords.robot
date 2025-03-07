*** Settings ***
Library    SeleniumLibrary
Library    XML
Variables    ../PageObjects/dashboard.py
Variables    ../PageObjects/Tasks/tasks_page_locators.py
Variables    ../PageObjects/sidebar.py
Variables    ../PageObjects/login/login_locators.py
Variables    ../PageObjects/UserProfile/userprofile.py

*** Variables ***
${url}    http://localhost:5085/

*** Keywords ***
Open Dashboard
    Open Browser    ${url}      Chrome
    Maximize Browser Window
    Reload Page
    Wait Until Page Contains Element    ${dashboard_name}    timeout=10
    Sleep    2

Verify Sidebar Contains File Manager And Search Option
    Wait Until Page Contains Element    ${dashboard_name}    timeout=10
    Page Should Contain Element    ${file_manager_locator}
    Page Should Contain Element    ${sidebar_search_option}

Navigate To Transaction Section
    Sleep    0.5
    Scroll Element Into View   ${transaction_row2}
    Wait Until Page Contains Element    ${transaction_filter_locator}    timeout=10
    Click Element    ${transaction_filter_locator}

Verify Transaction Section Header Is Visible
    Wait Until Page Contains Element    ${transaction_header_locator}    timeout=10
    Page Should Contain Element    ${transaction_header_locator}

Navigate To Tasks Section
    Sleep    0.5
    Scroll Element Into View   ${sidebar_option_tasks}
    Click Element    ${sidebar_option_tasks}

Verify Tasks Section Header Is Visible
    Wait Until Page Contains Element    ${args_input_locator}    timeout=10
    Page Should Contain Element    ${args_input_locator}

Verify Dark Mode Toggle Is Visible
    Wait Until Page Contains Element    ${dark_mode_toggle_locator}    timeout=10
    Page Should Contain Element    ${dark_mode_toggle_locator}

Navigate To Sign In Page | File Manager
    Wait Until Page Contains Element    ${dashboard_name}    timeout=10
    Page Should Contain Element    ${file_manager_locator}
    Click Element    ${file_manager_locator}


Sign In | Rocket PR
    sleep    2
    Switch Window    url=https://rocket-django-pro.onrender.com/users/signin/?next=/file-manager/
    sleep    1
    wait until page contains element    ${username_input_locator}    timeout=10
    clear element text    ${username_input_locator}
    input text    ${username_input_locator}    admin 
    clear element text    ${password_input_locator}
    input text    ${password_input_locator}    Pass12__
    click element    ${login_button_locator}
    sleep    1

Sign Into Admin Account
    sleep    1
    wait until page contains element    ${username_input_locator}    timeout=10
    clear element text    ${username_input_locator}
    input text    ${username_input_locator}    admin 
    clear element text    ${password_input_locator}
    input text    ${password_input_locator}    Pass12__
    click element    ${login_button_locator}

Sign Into User Account
    sleep    1
    wait until page contains element    ${username_input_locator}    timeout=10
    clear element text    ${username_input_locator}
    input text    ${username_input_locator}    test 
    clear element text    ${password_input_locator}
    input text    ${password_input_locator}    Pass12__
    click element    ${login_button_locator}

click on User Profile Icon
    Wait Until Page Contains Element    ${user_icon}    timeout=10
    Page Should Contain Element    ${user_icon}
    Click Element    ${user_icon}

Click on Sign In Option
    Wait Until Page Contains Element    ${signin_option}    timeout=10
    Page Should Contain Element    ${signin_option}
    Click Element    ${signin_option}


Verify File Name Label Is Visible
    Wait Until Page Contains Element    ${file_name_label}    timeout=10
    Page Should Contain Element    ${file_name_label}

Navigate To File Manager | Switch Window
    Wait Until Page Contains Element    ${dashboard_name}    timeout=10
    Page Should Contain Element    ${file_manager_locator}
    Click Element    ${file_manager_locator}
    sleep    1
    Switch Window    url=https://rocket-django-pro.onrender.com/file-manager/
    sleep    1
    Wait Until Page Contains Element    ${sidebar_profile_icon}    timeout=10

Navigate To User Profile
    Wait Until Page Contains Element    ${sidebar_profile_icon}    timeout=10
    Page Should Contain Element    ${sidebar_profile_icon}
    Click Element    ${sidebar_profile_icon}

Verify Input Filds of User Profile
    Wait Until Page Contains Element    ${full_name_input}    timeout=10
    Page Should Contain Element    ${full_name_input}
    Wait Until Page Contains Element    ${phone_input}    timeout=10
    Page Should Contain Element    ${phone_input}
    Clear Element Text    ${full_name_input}
    Input Text    ${full_name_input}    Samarth
    Clear Element Text    ${phone_input}
    Input Text    ${phone_input}    9876543210


Navigate To Users Page
    Wait Until Page Contains Element    ${sidebar_users_icon}    timeout=10
    Page Should Contain Element    ${sidebar_users_icon}
    Click Element    ${sidebar_users_icon}

Verify Search Box Is Visible
    Wait Until Page Contains Element    ${search_box_input}    timeout=10
    Page Should Contain Element    ${search_box_input}
    Clear Element Text    ${search_box_input}
    Input Text    ${search_box_input}    Samarth

Verify Add New User Button Is Visible
    Wait Until Page Contains Element    ${add_new_user_button}    timeout=10
    Page Should Contain Element    ${add_new_user_button}
    Click Element    ${add_new_user_button}


Verify Statistics Header Is Visible
    Wait Until Page Contains Element    ${statistics_header_locator}    timeout=10
    Page Should Contain Element    ${statistics_header_locator}


Navigate To Charts Section
    Wait Until Page Contains Element    ${sidebar_option_charts}    timeout=10
    Page Should Contain Element    ${sidebar_option_charts}
    Click Element    ${sidebar_option_charts}

Verify Sales Report Link Is Clickable
    Wait Until Page Contains Element    ${sales_report_link}    timeout=10
    Page Should Contain Element    ${sales_report_link}
    Click Element    ${sales_report_link}


Verify From Date Input Field Is Working
    Wait Until Page Contains Element    ${from_date_input}    timeout=10
    Page Should Contain Element    ${from_date_input}
    Click Element    ${from_date_input}
    Input Text    ${from_date_input}    2024-01-01


# Collect Test Case Summary
#     # Extract and process locators
#     ${locators}=    Get Locators From Dashboard
#     FOR    ${locator_info}    IN    @{locators}
#         ${xpath}=    Set Variable    ${locator_info}[locator]
#         ${source}=    Set Variable    ${locator_info}[source_file]
#         Log    Found locator ${xpath} in file ${source}
#         Extract Element Attributes By XPath    ${xpath}
#     END
