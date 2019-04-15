import time
import os
import csv
import sys
import fileinput
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys


#Get curent logged in user
currentUser = os.getlogin()

#Set Equip username and password as arguments for script
username = str(sys.argv[1])
password = str(sys.argv[2])
active = str(sys.argv[3])
inactive = str(sys.argv[4])
computerList = str(sys.argv[5])
#username = str(firstarg)
#password = str(secondarg)

#CSV Data
#computerList = str("/Applications/inventorySync.app/Contents/Resources/csv/computerList.csv")
#active = str("/Applications/inventorySync.app/Contents/Resources/csv/ActiveMacs.csv")
#inactive = str("/Applications/inventorySync.app/Contents/Resources/csv/inActiveMacs.csv")
cpuListPath = str('/Users/'+str(currentUser)+'/Downloads/AssetTemplate_81_1.csv')

#Remove old CSV files
if os.path.exists(cpuListPath):
    os.remove(cpuListPath)
    print("Deleting "+str(cpuListPath))

if os.path.exists(inactive):
    os.remove(inactive)
    print("Deleting "+str(inactive))

if os.path.exists(active):
    os.remove(active)
    print("Deleting "+str(active))

#Equip search string
ztag = 'Z000'

#Setup Web Driver
url = 'https://ecsu.e-isg.com/eQuip/Login.aspx'
driver = webdriver.Chrome("/Applications/inventorySync.app/Contents/Resources/webdriver/chromedriver")
action = ActionChains(driver)
driver.get(url)

#logging in to the designated website
driver.find_element_by_id('rtbUserName').send_keys(username)
driver.find_element_by_id('rtbPassword').send_keys(password)
driver.find_element_by_id("btnLogin").click()
driver.implicitly_wait(3)

#dropdown menu selection
drop_down= driver.find_element_by_xpath('//*[@title="SEARCH"]')
drop_down.click()
actions = ActionChains(driver)
actions.send_keys(Keys.ARROW_DOWN)
actions.send_keys(Keys.ENTER)
actions.perform()
driver.implicitly_wait(5)

#applying the search filters
driver.find_element_by_id('C_F_217').send_keys(ztag)
driver.find_element_by_id("ctl00_ContentPlaceHolder1_uimodules_assetsearch_ascx_btnApplyFilter").click()
time.sleep(2)

#switching from Xlsx to CSV
driver.find_element_by_id("rdoCsv").click()
time.sleep(2)

#Check for and remove computer list from Application folder  
if os.path.exists(computerList):
    os.remove(computerList)
    print("Deleting "+str(computerList))

#Check for and remove previous computer list form Downloads folder
if os.path.exists(cpuListPath):
    os.remove(cpuListPath)
    print("Deleting "+str(cpuListPath))
    
#Download the Master Computer List!
driver.find_element_by_id("ctl00_ContentPlaceHolder1_uimodules_assetsearch_ascx_btnExportAssetDataForImporter").click()

#Wait for file to download, time can be adjusted as needed...    
time.sleep(4)

#Create empty CSV files to parse to
inActiveMacsCsv = open(inactive,'w')
ActiveMacsCsv = open(active,'w')
csv_ActiveComputers = csv.writer(ActiveMacsCsv)
csv_InactiveComputers = csv.writer(inActiveMacsCsv)

#Create headers
csv_InactiveComputers.writerow(["Serial Number", "Asset Tag", "Is-Active"])
csv_ActiveComputers.writerow(["Serial Number", "Asset Tag", "Is-Active"])

#CSV To Uppercase
for line in fileinput.input(cpuListPath, inplace=1):
    print(line.upper(), end='')

#Rename and move the downloaded file
exists = os.path.isfile(cpuListPath)
if exists:
    os.rename(cpuListPath, computerList)
    print("Moved master list to app folder.")
else:
    print("The file doesn't exist. Check the file name or Chrome download location")

#Set the complete list of computers to a variable and sort
time.sleep(4)
completeList = open(computerList)
completeListCSV = csv.reader(completeList)

#For Loop to append Macs to CSV
for row in completeListCSV:
    if "MAC" in row[1] and row[29] == "TRUE":
        #csv_ActiveComputers.writerow([row[3],row[2],row[29],row[1]])
        csv_ActiveComputers.writerow([row[3],row[2],row[29]])
        print(row[29])
    #activeMacs.append(row)
    elif "MAC" in row[1] and row[29] == "FALSE":
        csv_InactiveComputers.writerow([row[3],row[2],row[29]])

#close open csv
ActiveMacsCsv.close()
inActiveMacsCsv.close()
completeList.close()
