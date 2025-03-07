*** Settings ***
Library      AppiumLibrary
Variables    ../../PageObjects/Login/login_locators.py
Library       ../../Utilities/user_keywords.py
Library       ../../Utilities/utilities.py
Library    String
Library    XML
Library    RequestsLibrary


*** Variables ***

${android_environment}      ${CURDIR}${/}..${/}..${/}Environment${/}environment.json
${APPIUM SERVER TIMEOUT}    60000

*** Keywords ***

Open Application
    ${env_data}  Get Environment Data    ${android_environment}
    ${env_data}  Create Dictionary  &{env_data}
    Open Application    ${env_data.host}    platformName=${env_data.platformName}   deviceName=${env_data.deviceName}   app=${env_data.application_sdk}      autoGrantPermissions=true    automationName=${env_data.automationName}    noReset=true    newCommandTimeout=${APPIUM SERVER TIMEOUT}

Login With Valid Username And Password | MPOS
    [Arguments]    ${search_data}
#    Inject JavaScript For Fetch
#    Inject JavaScript For XHR
    ${my_dict}=    Create Dictionary    &{search_data}
    Wait Until Element Is Visible    id=${serial_key_id}    timeout=15s
    Click Element    id=${serial_key_id}
    Sleep    10s
    Input Text    id=${serial_key_id}    ${my_dict.serial_key}
    Click Element    ${authenticate_button}
    Wait Until Element Is Visible    ${username_field}    timeout=15s
    Click Element    ${username_field}
    Input Text    ${username_field}    ${my_dict.username}
#    Click Button    ${pos_continue_button}
    Wait Until Element Is Visible    ${pin_field}    timeout=35s
    Click Element    ${pin_field}
    Input Text    ${pin_field}    ${my_dict.password}
    Hide Keyboard
    Click Element    ${login_button}
    Wait Until Element Is Visible    id=${homepage_heading_id}   timeout=30s


Login With Valid Username And Password
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}
    Wait Until Element Is Visible    ${username_field}    timeout=15s
    Click Element    ${username_field}
    Input Text    ${username_field}    ${my_dict.username}
    Wait Until Element Is Visible    ${pin_field}    timeout=35s
    Click Element    ${pin_field}
    Input Text    ${pin_field}    ${my_dict.password}
    Hide Keyboard
    Click Element    ${login_button}
    ${status}=  Run Keyword And Return Status    Wait Until Element Is Visible  ${homepage_heading_id}  timeout=15s
    IF    ${status}==False
        Clear Text    ${entered_pin_field}
        Click Element    ${pin_field}
        Input Text    ${pin_field}    ${my_dict.password}
        Hide Keyboard
        Click Element    ${login_button}
    END
    Wait Until Element Is Visible    id=${homepage_heading_id}   timeout=30s
    

Click On Catalog Button
    Wait Until Element Is Visible    ${catalog_button_id}    timeout=15s
    Click Element    ${catalog_button_id}

Search Product
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}        
    Wait Until Element Is Visible    id=${search_product_button_id}    timeout=15s
    Click Element    id=${search_product_button_id}
    Wait Until Element Is Visible    id=${search_product_field_id}    timeout=15s
    Click Element    id=${search_product_field_id}
    Input Text    id=${search_product_field_id}    ${my_dict.product_name}
    Hide Keyboard    
    Wait Until Element Is Visible    id=${add_product_button_id}    timeout=15s

Click On Add Product Button
    Wait Until Element Is Visible    id=${add_product_button_id}    timeout=15s
    Click Element    id=${add_product_button_id}

Click On Go To Cart Button
    Wait Until Element Is Visible    ${go_to_cart_button}    timeout=15s
    Click Element    ${go_to_cart_button}    

Verify Product Added To Cart
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}
    Wait Until Element Is Visible    id=${product_name_id}    timeout=15s
    ${product_name}=    Get Text    id=${product_name_id}
    Should Be Equal    ${product_name}    ${my_dict.product_name}

Click On Tag Customer Button
    Wait Until Element Is Visible    id=${tag_customer_button_id}    timeout=15s
    Click Element    id=${tag_customer_button_id}

Search And Tag Customer To Bill
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}
    Wait Until Element Is Visible    id=${search_customer_field_id}    timeout=15s
    Click Element    id=${search_customer_field_id}
    Input Text    id=${search_customer_field_id}    ${my_dict.customer_name}
    Click Element    id=${search_button_id}
    ${searched_customer_name}=    Replace String   ${searched_customer}    value    ${my_dict.customer_name}
    Wait Until Element Is Visible    ${searched_customer_name}    timeout=15s
    Click Element    ${searched_customer_name}
    Wait Until Element Is Visible    id=${add_to_bill_button_id}    timeout=15s
    Click Element    id=${add_to_bill_button_id}    

Verify Customer Added To Bill
    [Arguments]    ${search_data}
    ${my_dict}=    Create Dictionary    &{search_data}
    ${status}=      Run Keyword And Return Status    Wait Until Element Is Visible    ${add_items_from_previous_session_heading}    timeout=10s
    IF    ${status}
        Wait Until Element Is Visible    ${discard_items_button}
        Click Element    ${discard_items_button}
    END
    Wait Until Element Is Visible    id=${tagged_customer_name_id}    timeout=15s
    ${tagged_customer_name}=    Get Text    id=${tagged_customer_name_id}
    Should Be Equal    ${tagged_customer_name}    ${my_dict.customer_name}

Get Payable Amount
    Wait Until Element Is Visible    id=${payable_amount}    timeout=15s
    ${payable_amount}=    Get Text    id=${payable_amount}
    ${payable_amount}=    Remove Characters    ${payable_amount}
    ${payable_amount}=    Convert To Number    ${payable_amount}
    [Return]    ${payable_amount}    

Click On Checkout Button
    Wait Until Element Is Visible    id=${checkout_button_id}    timeout=15s
    Click Element    id=${checkout_button_id}   
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${open_session_screen_heading}    timeout=15s
    IF    ${status}
        Open Session
    END
    ${status}=  Run Keyword And Return Status    Wait Until Element Is Visible    ${add_items_from_previous_session_heading}    timeout=10s
    IF    ${status}
         Wait Until Element Is Visible    ${discard_items_button}
         Click Element    ${discard_items_button}
    END
    # 
    # Click Element    id=${checkout_button_id}  
        

Edit Payable Amount
    [Arguments]     ${payable_amount}
    Wait Until Element Is Visible    id=${edit_payable_amount}  timeout=15s
    ${payable_amount}=  Evaluate    ${payable_amount}/2
    ${payable_amount}=  Convert To Number    ${payable_amount}
    Click Element    id=${edit_payable_amount}
    Input Text    id=${edit_payable_amount}    ${payable_amount}
    RETURN  ${payable_amount}

Select Cash Option
    Wait Until Element Is Visible    ${cash_option}    timeout=15s
    Click Element    ${cash_option}    

Apply Bill Discount
    Wait Until Element Is Visible    id=${bill_discount_button}    timeout=10s
    Click Element    id=${bill_discount_button}
    Wait Until Element Is Visible    ${custom_discount_button}  timeout=10s
    Click Element    ${custom_discount_button}
    Wait Until Element Is Visible    id=${discount_value_field}
    Click Element    id=${discount_value_field}
    Input Text    id=${discount_value_field}    50
    Hide Keyboard
    Wait Until Element Is Visible    id=${apply_discount_button}
    Click Element    id=${apply_discount_button}
    RETURN  50
    
Verify Discount Is Applied 
    [Arguments]     ${payable_amount}  ${discount_value}
    ${amount_after_discount}=   Evaluate    ${payable_amount} - ${discount_value}
    ${amount_after_discount}=   Convert To Number    ${amount_after_discount}
    Wait Until Element Is Visible    id=${payment_summary_icon}    timeout=15s
    Click Element    id=${payment_summary_icon}
    Wait Until Element Is Visible    xpath=${payable_amount_split}    timeout=15s
    ${amount_due}=  Get Text    xpath=${payable_amount_split}
    ${amount_due}=  Remove Characters    ${amount_due}
    ${amount_due}=  Convert To Number    ${amount_due}
    Should Be Equal As Numbers    ${amount_due}    ${amount_after_discount}
    Click Element    id=${hide_button}
    Wait Until Element Is Visible    id=${go_back_arrow}
    Click Element    id=${go_back_arrow}



Payment By Gpay
    Wait Until Element Is Visible    ${gpay_option}     timeout=10s
    Click Element    ${gpay_option}
    Wait Until Element Is Visible    id=${continue_button}     timeout=10s
    Click Element    id=${continue_button}

Enter Customer Paid Amount
    [Arguments]    ${payable_amount}
    Wait Until Element Is Visible    id=${customer_paid_amount}    timeout=15s
    Click Element    id=${customer_paid_amount}
    Input Text    id=${customer_paid_amount}    ${payable_amount}    
    Hide Keyboard

Click On Collect Button
    Wait Until Element Is Visible    id=${collect_button}    timeout=15s
    Click Element    id=${collect_button}            

Verify Payment Successfully Made
    Wait Until Element Is Visible    id=${payment_success_screen}    timeout=15s
    Page Should Contain Element    id=${payment_success_screen}
    ${invoice_number}=    Get Text    id=${invoice_number_id}
    Click Element    id=${home_button}
    [Return]    ${invoice_number}


Navigate To Transaction Invoices Screen
    Wait Until Element Is Visible    id=${hamberger_menu_id}    timeout=15s
    Click Element    id=${hamberger_menu_id}
    Wait Until Element Is Visible    xpath=${transaction_option}    timeout=15s
    Click Element    xpath=${transaction_option}
    Wait Until Element Is Visible    ${invoices_option}    timeout=15s
    Click Element    ${invoices_option}    

Verify Invoice Is Visible In Transaction Invoices Screen
    [Arguments]    ${invoice_number}
    Wait Until Element Is Visible    id=${invoice_search_button}    timeout=15s
    Click Element    id=${invoice_search_button}
    Wait Until Element Is Visible    id=${invoice_search_field_id}    timeout=15s
    Click Element    id=${invoice_search_field_id}
    Input Text    id=${invoice_search_field_id}    ${invoice_number}
    Wait Until Page Contains   ${invoice_number}    timeout=15s


Logout From Application
    Navigate To Hamburger Menu
    Wait Until Element Is Visible    id=${logout_button_id}    timeout=15s
    Click Element    id=${logout_button_id}
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${close_session_button_id}    timeout=10s
    IF    ${status}
        Click Element    ${close_session_button_id}
        Wait Until Element Is Visible    id=${closing_balance_field}    timeout=15s
        Click Element    id=${closing_balance_field}
        ${closing_balance}=    Generate Random Number 
        Input Text    id=${closing_balance_field}    ${closing_balance}
        Hide Keyboard
        Wait Until Element Is Visible    ${swipe_to_close_arrow}    timeout=15s
        Swipe    ${46}    ${1447}    ${690}    ${1438}
        Wait Until Element Is Visible    id=${session_close_done_button}    timeout=15s
        Click Element    id=${session_close_done_button}
        Navigate To Hamburger Menu
        Wait Until Element Is Visible    id=${logout_button_id}    timeout=15s
        Click Element    id=${logout_button_id}
    END
    Wait Until Element Is Visible    id=${yes_logout_button_id}    timeout=15s
    Click Element    id=${yes_logout_button_id}

    
Navigate To Hamburger Menu
    Wait Until Element Is Visible    id=${hamberger_menu_id}    timeout=15s
    Click Element    id=${hamberger_menu_id}    

Open Session
    Wait Until Element Is Visible    id=${opening_balance_field}    timeout=15s
    Click Element    id=${opening_balance_field}
    ${opening_balance}=    Generate Random Number 
    Input Text    id=${opening_balance_field}    ${opening_balance}    
    Hide Keyboard
    Sleep    5s
    # Wait Until Element Is Visible    id=${swipe_to_open_arrow}    timeout=15s
    Swipe    ${46}    ${1447}    ${690}    ${1438}
    Sleep    3s
    Wait Until Page Does Not Contain    ${opening_balance_field}    timeout=5s

Clear Cart
    Wait Until Element Is Visible    id=${kebab_menu_id}    timeout=15s
    Click Element    id=${kebab_menu_id}
    Wait Until Element Is Visible    xpath=${clear_cart_button_id}    timeout=15s
    Click Element    xpath=${clear_cart_button_id}
    Sleep    5s
        

        