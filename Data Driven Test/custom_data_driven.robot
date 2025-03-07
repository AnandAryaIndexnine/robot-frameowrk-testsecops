*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    DataDriver    data_driven_search.xlsx    sheet_name=search_flights

Test Setup    Open Air Application
Test Teardown   Close Browser
Test Template    TC_1 Verify One Way Domestic search results

*** Variables ***
${search_td}        ${CURDIR}${/}..${/}..${/}DataDriven-TestData${/}SearchFlights${/}data_driven_search.xlsx
${sheet_name}=    search_flights

*** Test Cases ***
TC_1 Verify One Way Domestic search results ${TC_ID}
    [Tags]    Search-Flight

*** Keywords ***
QAT-75 Verify One Way Domestic search results
    [Arguments]    ${TC_ID}
    ${search_data}=    Fetch Testdata By Id    ${search_td}    ${sheet_name}    ${TC_ID}
    Login With Valid Agent Username And Password    ${search_data}
    Search One Way Flights    ${search_data}
    Verify Flight Search Details     ${search_data}