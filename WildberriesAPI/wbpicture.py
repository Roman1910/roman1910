import requests
import json
import pytz
import csv
from bs4 import BeautifulSoup
import requests
url = 'http://fotothings.ru/wb/'
def listFD(url):
    page = requests.get(url).text
    
    soup = BeautifulSoup(page, 'html.parser')
    return [url  + node.get('href') for node in soup.find_all('a') if not node.get('href').startswith(('?', '/'))]
    




def goods(nmid):
 photos=(listFD(url+str(nmid)+'/photo/'))
 print(photos)  
 



 data = {"id":"8a31f7a8-6ed1-4910-bbd3-ac83e214e845","jsonrpc":"2.0","params":{"supplierID": "c9a97b7d-b7c8-5a08-8772-897ca3987d34","card":{}}}

 
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
            "limit": 10
           
        }
    }
})
 bodyup=""
 headers={ 'Content-type':'application/json;' , 'Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NJRCI6IjgzNDQxMmRhLTA2ZjItNDczYS04ZDVlLTk2NzBiMzg2Yzc4OSJ9.XUjF-e1QTSiyttp3ySr6Mt2HyNpoFV9jHoy8p8Xz5cg'} 
 



 requestcard = requests.post(urlist, data=body,headers=headers)

 try:
     updata=json.loads(requestcard.content)
 except:
     logwb=open('wblog.txt','a')
     logwb.write(str(nmid)+'\n')
     logwb.close()   
     

 
 #updata['result']['cards'][0]['nomeclatures']['variations'].pop('barcodes')
 updata['result']['cards'][0].pop('createdAt')
 updata['result']['cards'][0].pop('updatedAt')
 updata['result']['cards'][0].pop('uploadID')

 #if len(photos)!= 0:
 #  if (updata['result']['cards'][0]['addin'][0]['type']=="Ключевые слова"):
 #      updata['result']['cards'][0]['addin'][0]['params']=[] 
 #       for keys in listkeys:
 #          updata['result']['cards'][0]['addin'][0]['params'].append({"value": keys})
 #  else:   
 #      updata['result']['cards'][0]['addin'].insert(0,{"type": "Ключевые слова", "params": []})
  #     for keys in listkeys:
 #          updata['result']['cards'][0]['addin'][0]['params'].append({"value": keys})
 #if len(name)!= 0:
    
 #      for types in updata['result']['cards'][0]['addin']:
 #          if (str(types['type'])=="Наименование"):
 #              
 #              types['params'][0]['value']= str(name)
               
 if len(photos)!= 0:
       for nomenc in  updata["result"]["cards"][0]["nomenclatures"]:
            if(nomenc["nmId"]==nmid):
                
                for types in nomenc['addin']:
            
                 if (str(types['type'])=="Фото"):
                   
                   types['params']=[]
                   for photo in photos:
                      types['params'].append({"value": photo})
                 else:   
                   nomenc['addin'].append({"type": "Фото", "params": []})
                   
                   for types in nomenc['addin']:
                       if (str(types['type'])=="Фото"):
                          
                          for photo in photos:
                             types['params'].append({"value": photo})
            
 cards=""
 cards=str(updata['result']['cards'])
 data1=cards.split('[', 1)[1].lstrip()
 data1=data1.rsplit(']',1)[0].lstrip()
 data['params']['card']=eval(data1)
 

 print(nmid)
 


 
 data=json.dumps(data)
 
 requestupdate = requests.post(urlupdate,headers=headers, data=data)
 print(requestupdate.content)

 


 

 if(str(json.loads(requestupdate.content))!="{'id': '8a31f7a8-6ed1-4910-bbd3-ac83e214e845', 'jsonrpc': '2.0', 'result': {}}"):
      logwb=open('wblog.txt','a')
      logstr=str(json.loads(requestupdate.content))
      print(logstr)
      print(requestupdate.content) 
      logwb.write(str(nmid)+' '+logstr+'\n')
      logwb.close()   
                  
 else:
      print(str(json.loads(requestupdate.content)))
          
         
 

for file in listFD(url):
    nmid=int(''.join(file.split('/')[-2:]))
    try:
        goods(nmid)
    except:
        continue




