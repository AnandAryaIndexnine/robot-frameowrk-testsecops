*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Resource          ../Resources/rocket_django_keywords.robot
Library           XML

Test Teardown    Close Browser
# Suite Teardown    Collect Test Case Summary
*** Variables ***

*** Test Cases ***
TC_01 File manager is visible at sidebar
    Open Dashboard
    Verify Sidebar Contains File Manager And Search Option

TC_02 Verify transaction Section Header Is Visible
    Open Dashboard
    Navigate To Transaction Section
    Verify Transaction Section Header Is Visible

TC_03 Verify Navigation To Tasks Section
    Open Dashboard
    Navigate To Tasks Section
    Verify Tasks Section Header Is Visible

# TC_04 Verify Dark Mode Toggle
#     [Documentation]    changed: dark-theme-toggle -> dark-theme-toggle-button
#     ...                navigation.html
#     Open Dashboard
#     Verify Dark Mode Toggle Is Visible
    

# TC_05 Verify Sign In Page | File Manager
#     Open Dashboard
#     Navigate To Sign In Page | File Manager
#     Sign In | Rocket PR
#     Verify File Name Label Is Visible


# TC_06 Verify search box on users page
#     [Documentation]    changed: products-search -> products-search-bar
#     ...                users.html
#     Open Dashboard
#     click on User Profile Icon
#     Click on Sign In Option
#     Sign Into Admin Account
#     Navigate To Users Page
#     Verify Search Box Is Visible

# TC_07 Verify add new user button is clickable
#     [Documentation]    changed: Add new user->new Add user
#     ...                users.html
#     Open Dashboard
#     click on User Profile Icon
#     Click on Sign In Option
#     Sign Into Admin Account
#     Navigate To Users Page
#     Verify Add New User Button Is Visible

# TC_08 Verify Input Filds of User Profile
#     Open Dashboard
#     click on User Profile Icon
#     Click on Sign In Option
#     Sign Into User Account
#     Navigate To User Profile
#     Verify Input Filds of User Profile

# TC_08 Verify from date input field of transaction section
#     [Documentation]    changed: from-date-input-transaction -> from-date-input-field
#     ...                index.html
#     Open Dashboard
#     Navigate To Transaction Section
#     Verify From Date Input Field Is Working


# TC_09 Verify Statistics Header Is Visible
#     [Documentation]    changed: statistics-this-month -> statistics-this-month-header
#     ...                dashboard.html
#     Open Dashboard
#     Verify Statistics Header Is Visible


  
# TC_10 Verify sales report link is clickable
#     [Documentation]    changed: Sales Report text to -> Report Sales
#     ...                index.html
#     Open Dashboard
#     Verify Sales Report Link Is Clickable






























