*** Settings ***
Library             SeleniumLibrary
Library             RequestsLibrary
Resource            ../Resources/login_keywords.resource

Test Setup          Open Application | POS
Test Teardown       Close All Browsers

*** Variables ***
${STAGING_TD}       ${CURDIR}${/}..${/}..${/}..${/}..${/}TestData${/}Staging${/}Web_POS${/}Billing${/}add_to_cart_test_data.xlsx

*** Test Cases ***
Test_O_1 Login test with valid data
    ${POS_TD}=    Get Test Data File    ${ENV}    ${STAGING_TD}    ${PROD_TD}
    ${pos_data}=    Fetch Testdata By Id    ${POS_TD}    TC_01
    ${response}=    Login With Valid Username And Password | POS    ${pos_data}

Test_O_2 Login test with invalid data
    [Tags]    retry
    ${POS_TD}=    Get Test Data File    ${ENV}    ${STAGING_TD}    ${PROD_TD}
    ${pos_data}=    Fetch Testdata By Id    ${POS_TD}    TC_02
    ${response}=    Login With Valid Username And Password | POS    ${pos_data}

