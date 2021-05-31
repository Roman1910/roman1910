import requests
import json
import pytz
import csv




def goods(nmid,listkeys):
 data = {"id":"8a31f7a8-6ed1-4910-bbd3-ac83e214ec45","jsonrpc":"2.0","params":{"supplierID": "c9a97b7d-b7c8-5a08-8772-897ca3987d34","card":{}}}

 
 urlist = 'https://suppliers-api.wildberries.ru/card/list'
 urlupdate= 'https://suppliers-api.wildberries.ru/card/update' 
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
            "limit": 10,
            "offset": 0
        }
    }
})
 bodyup=""
 headers={ 'Content-type':'application/json; charset=utf-8','Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NJRCI6IjgzNDQxMmRhLTA2ZjItNDczYS04ZDVlLTk2NzBiMzg2Yzc4OSJ9.XUjF-e1QTSiyttp3ySr6Mt2HyNpoFV9jHoy8p8Xz5cg'} 
 



 requestcard = requests.post(urlist, data=body,headers=headers)
 
 updata=json.loads(requestcard.content)
 updata['result']['cards'][0].pop('nomenclatures')
 updata['result']['cards'][0].pop('createdAt')
 updata['result']['cards'][0].pop('updatedAt')
 updata['result']['cards'][0].pop('uploadID')
 
 if len(listkeys)!= 0:
   if (updata['result']['cards'][0]['addin'][0]['type']=="Ключевые слова"):
       updata['result']['cards'][0]['addin'][0]['params']=[] 
       for keys in listkeys:
           updata['result']['cards'][0]['addin'][0]['params'].append({"value": keys})
   else:   
       updata['result']['cards'][0]['addin'].insert(0,{"type": "Ключевые слова", "params": []})
       for keys in listkeys:
           updata['result']['cards'][0]['addin'][0]['params'].append({"value": keys})
     
       
 cards=""
 cards=str(updata['result']['cards'])
 data1=cards.split('[', 1)[1].lstrip()
 data1=data1.rsplit(']',1)[0].lstrip()
 data['params']['card']=eval(data1)

 
 print(nmid)

 data=json.dumps(data)
 requestupdate = requests.post(urlupdate,headers=headers, data=data)
        

 if(str(json.loads(requestupdate.content))!="{'id': '8a31f7a8-6ed1-4910-bbd3-ac83e214ec45', 'jsonrpc': '2.0', 'result': {}}"):
         logwb=open('wblog.txt','a')
         logstr=str(json.loads(requestupdate.content))
         print(logstr)        
         logwb.write(str(nmid)+' '+logstr+'\n')
         
                  
 else:
         print(requestupdate.content)
         
         
 logwb.close()



csvFilePath='wb.csv'
with open(csvFilePath) as csvf:
    csvReader = csv.DictReader(csvf, delimiter=';')
  
    for rows in csvReader:
        try:
            goods(int(rows["nmid"]),rows["Keys"].split(','))
        except:
            continue
        



