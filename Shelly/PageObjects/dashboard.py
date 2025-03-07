
file_manager_locator = "//*[@id='sidebar']/div/div[1]/div/ul/li[7]/a/span[contains(text(),'File Manager')]"

dashboard_name = "//div[@class='flex items-center justify-start']"
dark_mode_toggle_locator = "//button[@id='dark-theme-toggle' and @type='button']"
statistics_header_locator = '//h3[@id="statistics-this-month" and @name="statistics-this-month"]'

#charts sectiion
sales_report_link = "//a[@id='sales-report-button' and contains(text(),'Sales Report')]"

#transaction section
from_date_input = "//input[@name='from-date-input' and @placeholder='From-date']"
transaction_filter_locator = "//button[@id='dropdownDefault']"
transaction_header_locator = "//div[contains(@class, 'ztx_transaction_title_wrapper_q7y9v5p2m4') and contains(text(), 'Transactions')]"
# Solution: Updated the locator to match the new class name and ensure it looks for the text 'Transactions' in a more flexible way, allowing for potential variations in the header text.
transaction_row2=  "(//tr[@class='bg-gray-50 dark:bg-gray-700'])[2]"


