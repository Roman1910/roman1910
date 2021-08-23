
from seleniumwire import webdriver 
import time
import requests
import json
from ast import literal_eval
import datetime
import csv



options = webdriver.ChromeOptions()
options.add_argument('ignore-certificate-errors')
driver = webdriver.Chrome(chrome_options=options)
driver.get('https://suppliers-portal.wildberries.ru/marketplace-orders/new-tasks')
time.sleep(300)







driver.header_overrides = {
    'Referer': 'https://suppliers-portal.wildberries.ru/marketplace-orders/new-tasks',
    'Content-type':'appliation/json',
    'Accept':'*/*'
}







url3='https://suppliers-portal.wildberries.ru/ns/marketplace-app/marketplace-remote-wh/api/private/portal/v1/gather_tasks_in_progress?isGrouped=false'
driver.get(url3)
data=driver.page_source.split('[', 1)[1].lstrip()
data=data.rsplit(']',1)[0].lstrip()
cont="{\"data\": [ "+data+" ]}"

data=json.loads(cont)
header = ['Номер задания', 'Дата создания', 'Артикул', 'Наименование', 'Цвет','Размер','Количество','Стикер 1', 'Стикер 2', 'Баркод стикера']
csvFilePath='./assembly-tasks.csv'
with open(csvFilePath, 'w', newline ="") as csvf:
    csvWriter = csv.writer(csvf, delimiter=';')
    csvWriter.writerow(header)
    for row in data["data"]:
       csvWriter.writerow([row["rows"][0]["id"],datetime.datetime.strptime(row["rows"][0]["creationDate"], '%Y-%m-%dT%H:%M:%S%z' ).replace(tzinfo=None),row["rows"][0]["supplierArticle"], row["rows"][0]["nameItem"],row["rows"][0]["color"],row["rows"][0]["size"], row["rows"][0]["count"]["total"], row["rows"][0]["stickers"][0]["parts"]["a"],row["rows"][0]["stickers"][0]["parts"]["b"],row["rows"][0]["stickers"][0]["encodedValue"]])


