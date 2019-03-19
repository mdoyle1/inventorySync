//
//  pythonScript.swift
//  inventorySync
//
//  Created by Doyle, Mark(Information Technology Services) on 3/15/19.
//  Copyright © 2019 Doyle, Mark(Information Technology Services). All rights reserved.
//

import Foundation
func pythonScriptRun(){
let path = "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3"
let arguments = ["""
import time
import os
import csv
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys


#Get curent logged in user
currentUser = os.getlogin()
username = 'doylema@easternct.edu'
password = 'Spring2016!'
ztag = 'Z000'
cpuListPath = '/Users/'+str(currentUser)+'/Downloads/AssetTemplate_81_1.csv'
computerList = '/Applications/inventorySync.app/csv/computerList.csv'
url = 'https://ecsu.e-isg.com/eQuip/Login.aspx'
driver = webdriver.Chrome("/Applications/inventorySync.app/webdriver/chromedriver")
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
if os.path.exists("/Applications/inventorySync.app/csv/computerList.csv"):
os.remove("/Applications/inventorySync.app/csv/computerList.csv")
else:
print("the file doesn't exist")

#Check for and remove previous computer list form Downloads folder
if os.path.exists(cpuListPath):
os.remove(cpuListPath)
else:
print("the file doesn't exist")

#Download the Master Computer List!
driver.find_element_by_id("ctl00_ContentPlaceHolder1_uimodules_assetsearch_ascx_btnExportAssetDataForImporter").click()

#Wait for file to download, time can be adjusted as needed...
time.sleep(4)
exists = os.path.isfile(cpuListPath)
if exists:
print("the file exists")
os.rename(cpuListPath,'/Applications/inventorySync.app/csv/computerList.csv')
print("renamed and moved file")
else:
print("the file doesn't exist, check the file name or Chrome download location")

#Set the complete list of computers to a variable and sort
time.sleep(4)
completeList = open(computerList)

completeList.close()
"""
]
let task = Process.launchedProcess(launchPath: path, arguments: arguments)
task.waitUntilExit()
}
