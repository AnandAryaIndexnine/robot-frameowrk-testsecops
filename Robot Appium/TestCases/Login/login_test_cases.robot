*** Settings ***
Library     AppiumLibrary
Resource    ../../Resources/Login/login_keywords.resource
library     ../../Utilities/user_keywords.py
Test Setup      Open Application
Test Teardown    Close Application


*** Variables ***
${login_TD}    ${CURDIR}${/}..${/}..${/}TestData${/}login_test_data.xlsx

*** Test Cases ***

TC_01 Verify user is able to add product to cart
    Set Test Documentation    Login
    ${pos_data}=    Fetch Data By Id    ${LOGIN_TD}    TC_01
    Login With Valid Username And Password   ${pos_data}
    Click On Catalog Button
    Search Product    ${pos_data}
    Click On Add Product Button
    Click On Go To Cart Button
    Verify Product Added To Cart    ${pos_data}
     [Teardown]    Logout From Application

TC_02 Verify user is able to tag customer to bill
    Set Test Documentation    Login
    ${pos_data}=    Fetch Data By Id    ${LOGIN_TD}    TC_01
    Login With Valid Username And Password    ${pos_data}
    Click On Tag Customer Button
    Search And Tag Customer To Bill    ${pos_data}
    Verify Customer Added To Bill    ${pos_data}
    [Teardown]    Logout From Application


TC_03 Verify user is able to add Product and make payment
    Set Test Documentation    Login
    ${pos_data}=    Fetch Data By Id    ${LOGIN_TD}    TC_01
    Login With Valid Username And Password   ${pos_data}
    Click On Catalog Button
    Search Product    ${pos_data}
    Click On Add Product Button
    Verify Product Added To Cart    ${pos_data}
    Click On Go To Cart Button
    Click On Tag Customer Button
    Search And Tag Customer To Bill    ${pos_data}
    Verify Customer Added To Bill    ${pos_data}
    ${payable_amount}=    Get Payable Amount    
    Click On Checkout Button 
    Select Cash Option
    Enter Customer Paid Amount    ${payable_amount}
    Click On Collect Button
    Verify Payment Successfully Made
    [Teardown]    Logout From Application


TC_04 Verify After Payment Invoice Is Visible In Transaction Invoices Screen
    Set Test Documentation    Login
    ${pos_data}=    Fetch Data By Id    ${LOGIN_TD}    TC_01
    Login With Valid Username And Password    ${pos_data}
    Click On Catalog Button
    Search Product    ${pos_data}
    Click On Add Product Button
    Verify Product Added To Cart    ${pos_data}
    Click On Go To Cart Button
    Click On Tag Customer Button
    Search And Tag Customer To Bill    ${pos_data}
    Verify Customer Added To Bill    ${pos_data}
    ${payable_amount}=    Get Payable Amount    
    Click On Checkout Button 
    Select Cash Option
    Enter Customer Paid Amount    ${payable_amount}
    Click On Collect Button
    ${invoice_number}=    Verify Payment Successfully Made
    Navigate To Transaction Invoices Screen
    Verify Invoice Is Visible In Transaction Invoices Screen    ${invoice_number}
    [Teardown]    Logout From Application

TC_05 Verify user is able to make payment by splitting amount
    Set Test Documentation    Login
    ${pos_data}=    Fetch Data By Id    ${LOGIN_TD}    TC_05
    Login With Valid Username And Password    ${pos_data}
    Click On Catalog Button
    Search Product    ${pos_data}
    Click On Add Product Button
    Verify Product Added To Cart    ${pos_data}
    Click On Go To Cart Button
    Click On Tag Customer Button
    Search And Tag Customer To Bill    ${pos_data}
    Verify Customer Added To Bill    ${pos_data}
    ${payable_amount}=    Get Payable Amount
    Click On Checkout Button
    ${payable_amount}=  Edit Payable Amount    ${payable_amount}
    Select Cash Option
    Enter Customer Paid Amount    ${payable_amount}
    Click On Collect Button
    Payment By Gpay
    ${invoice_number}=    Verify Payment Successfully Made
    [Teardown]    Logout From Application

TC_06 Verify user is able to apply bill discount
    Set Test Documentation    Login
    ${pos_data}=    Fetch Data By Id    ${LOGIN_TD}    TC_06
    Login With Valid Username And Password    ${pos_data}
    Click On Catalog Button
    Search Product    ${pos_data}
    Click On Add Product Button
    Verify Product Added To Cart    ${pos_data}
    Click On Go To Cart Button
    Click On Tag Customer Button
    Search And Tag Customer To Bill    ${pos_data}
    Verify Customer Added To Bill    ${pos_data}
    ${payable_amount}=    Get Payable Amount
    Click On Checkout Button
    ${discount_value}=  Apply Bill Discount
    Verify Discount Is Applied  ${payable_amount}  ${discount_value}
     [Teardown]    Logout From Application



    


