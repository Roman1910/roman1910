import requests
import json
import pytz
import csv




def goods(nmid):
 data = {"id":"8a31f7a8-6ed1-4910-bbd3-ac83e214e845","jsonrpc":"2.0","params":{"supplierID": "c9a97b7d-b7c8-5a08-8772-897ca3987d34","card":{}}}
 inforow=[]
 strkeys=""
 listkey=[]
 urlist = 'https://suppliers-api.wildberries.ru/card/list'
  
 body=json.dumps({
    "id": "11",
    "jsonrpc": "2.0",
    "params": {
        "supplierID": "c9a97b7d-b7c8-5a08-8772-897ca3987d34",
        "filter": {
            "find": [
                {
                    "column": "nomenclatures.nmId",
                    "search": nmid
                }
            ]
        },
        "query": {
            "limit": 10
           
        }
    }
})
 headers={ 'Content-type':'application/json;' , 'Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NJRCI6IjgzNDQxMmRhLTA2ZjItNDczYS04ZDVlLTk2NzBiMzg2Yzc4OSJ9.XUjF-e1QTSiyttp3ySr6Mt2HyNpoFV9jHoy8p8Xz5cg'} 
 



 requestcard = requests.post(urlist, data=body,headers=headers)

 updata=json.loads(requestcard.content)


 inforow.append(nmid)
 
 
      

 for types in updata['result']['cards'][0]['addin']:
       if (str(types['type'])=="Наименование"):
           inforow.append(types['params'][0]['value'])
               
 for types in updata['result']['cards'][0]['addin']:
       if (str(types['type'])=="Описание"):
           inforow.append(types['params'][0]['value'])
 for types in updata['result']['cards'][0]['addin']:
       if (str(types['type'])=="Ключевые слова"):
           for keys in types['params']:
               
               listkey.append(keys['value'])
           strkeys= ','.join(listkey)    
           inforow.append(strkeys)
         
  

 

 print(nmid)
 
   

          
         
 
 with open('wbgetinfo.csv', 'a', newline='') as f:
     csvWriter = csv.writer(f, delimiter=';')
     csvWriter.writerow(inforow)
 return inforow

with open('wbgetinfo.csv', 'a',  newline='') as f:
    csvWriter = csv.writer(f, delimiter=';')
    csvWriter.writerow( ['nmid', 'name', 'opis', 'Keys'])


csvFilePath='wb.csv'
with open(csvFilePath) as csvf:
    csvReader = csv.DictReader(csvf, delimiter=';')
  
    for rows in csvReader:
        try:
            goods(int(rows["nmid"]))
            
        except:
            continue
        

