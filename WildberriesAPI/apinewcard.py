import requests
import json
import pytz
import csv




def goods(category, brand, suparticle, colarticle, pol, razm, rosrazm, barcode, price, sostav, komplekt, country, tnved,  opis ):
 
 sostav=sostav.replace(',', '').replace('%','')


 sostavs= sostav.split(' ')
 sostavs=list(filter(None, sostavs))

 params=[]

 body=json.dumps({
  "params": {
    "card": {
      "countryProduction": country,
      "object": category,
      "supplierVendorCode": suparticle, 
      "addin": [
        {
          "type": "Состав",
          "params": [
            {
              "value": sostavs[0],
              "count": int(sostavs[1])
            }
          ]
        },
        {
          "type": "Бренд",
          "params": [
            {
              "value": brand
            }
          ]
        },
        {
          "type": "Комплектация",
          "params": [
            {
              "value": komplekt
            }
          ]
        },
        {
          "type": "Тнвэд",
          "params": [
            {
              "value": tnved
            }
          ]
        },
        {
          "type": "Пол",
          "params": [
            {
              "value": pol
            }
          ]
        }
      ],
      "nomenclatures": [
        {
          "vendorCode": colarticle,
          "variations": [
            {
              "barcode": barcode,
              "addin": [
                {
                  "type": "Розничная цена",
                  "params": [
                    {
                      "count": price
                    }
                  ]
                },
                {
                  "type": "Размер",
                  "params": [
                    {
                      "value": razm
                    }
                  ]
                },
                {
                  "type": "Рос. размер",
                  "params": [
                    {
                      "value": rosrazm
                    }
                  ]
                }
              ]
            }
          ],
          "addin": [
            {
              "type": "Фото",
              "params": []
            },
            {
              "type": "Фото360",
              "params": []
            },
            {
              "type": "Видео",
              "params": []
            }
          ]
        }
      ]
    }
  },
  "jsonrpc": "2.0",
  "id": "json-rpc_8"
})
 
 if (len(sostavs) > 2):
    params.append({"value":sostavs[0], "count":int(sostavs[1])})
    params.append({"value":sostavs[2], "count":int(sostavs[3])})
    body=json.loads(body)
    body["params"]["card"]["addin"][0]["params"]=params
    body=json.dumps(body)
 url = 'https://suppliers-api.wildberries.ru/card/create'
 headers={ 'Content-type':'application/json;' , 'Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NJRCI6IjgzNDQxMmRhLTA2ZjItNDczYS04ZDVlLTk2NzBiMzg2Yzc4OSJ9.XUjF-e1QTSiyttp3ySr6Mt2HyNpoFV9jHoy8p8Xz5cg'} 
 

 

 requestcard = requests.post(url, data=body,headers=headers)

 updata=json.loads(requestcard.content)
 print(suparticle,',', colarticle )
 print(updata)
     
 
 

 

 
 
   

 if(str(updata)!="{'id': 'json-rpc_8', 'jsonrpc': '2.0', 'result': {}}"):
      logwb=open('wbcardlog.txt','a')
      logstr=str(updata)
      print(logstr)
      print(requestcard.content) 
      logwb.write(str(suparticle)+' '+str(colarticle)+' '+logstr+'\n')

      if (str(requestcard.content).find("Следующие комбинации характеристик")):
        print('')
      else:
        with open('errorcard.csv', 'a', newline ='') as file:
          writer = csv.writer(file, delimiter=';')
          
          writer.writerow([category, brand, suparticle, colarticle, pol, razm, rosrazm, barcode, price, sostav, komplekt, country, tnved,  opis])
                
         
 logwb.close()


header = ['Категория товара', 'Бренд', 'Артикул поставщика', 'Артикул цвета','Пол','Размер','Рос. размер','Штрихкод товара','Розничная цена','Состав','Комплектация','Страна производства','Тнвэд','Описание']        
with open('errorcard.csv', 'a', newline ='') as file:
          writer = csv.writer(file, delimiter=';')
          writer.writerow(header)     



def goods_size(category, brand, suparticle, colarticle, pol, razm, rosrazm, barcode, price, sostav, komplekt, country, tnved,  opis ):
 
 sostav=sostav.replace(',', '').replace('%','')


 sostavs= sostav.split(' ')
 sostavs=list(filter(None, sostavs))

 params=[]

 body=json.dumps({
  "params": {
    "card": {
      "countryProduction": country,
      "object": category,
      "supplierVendorCode": suparticle, 
      "addin": [
        {
          "type": "Состав",
          "params": [
            {
              "value": sostavs[0],
              "count": int(sostavs[1])
            }
          ]
        },
        {
          "type": "Бренд",
          "params": [
            {
              "value": brand
            }
          ]
        },
        {
          "type": "Комплектация",
          "params": [
            {
              "value": komplekt
            }
          ]
        },
        {
          "type": "Тнвэд",
          "params": [
            {
              "value": tnved
            }
          ]
        },
        {
          "type": "Пол",
          "params": [
            {
              "value": pol
            }
          ]
        }
      ],
      "nomenclatures": [
        {
          "vendorCode": colarticle,
          "variations": [
            {
              "barcode": barcode,
              "addin": [
                {
                  "type": "Розничная цена",
                  "params": [
                    {
                      "count": price
                    }
                  ]
                },
                {
                  "type": "Размер",
                  "params": [
                    {
                      "value": razm
                    }
                  ]
                },
                {
                  "type": "Рос. размер",
                  "params": [
                    {
                      "value": rosrazm
                    }
                  ]
                }
              ]
            }
          ],
          "addin": [
            {
              "type": "Фото",
              "params": []
            },
            {
              "type": "Фото360",
              "params": []
            },
            {
              "type": "Видео",
              "params": []
            }
          ]
        }
      ]
    }
  },
  "jsonrpc": "2.0",
  "id": "json-rpc_8"
})
 
 if (len(sostavs) > 2):
    params.append({"value":sostavs[0], "count":int(sostavs[1])})
    params.append({"value":sostavs[2], "count":int(sostavs[3])})
    body=json.loads(body)
    body["params"]["card"]["addin"][0]["params"]=params
    body=json.dumps(body)
 url = 'https://suppliers-api.wildberries.ru/card/update'
 headers={ 'Content-type':'application/json;' , 'Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NJRCI6IjgzNDQxMmRhLTA2ZjItNDczYS04ZDVlLTk2NzBiMzg2Yzc4OSJ9.XUjF-e1QTSiyttp3ySr6Mt2HyNpoFV9jHoy8p8Xz5cg'} 
 

 

 requestcard = requests.post(url, data=body,headers=headers)

 updata=json.loads(requestcard.content)
 print(suparticle,',', colarticle )
 print(updata)
     
 
 

 

 
 
   

 if(str(updata)!="{'id': 'json-rpc_8', 'jsonrpc': '2.0', 'result': {}}"):
      logwb=open('wbcardlog.txt','a')
      logstr=str(updata)
      print(logstr)
      print(requestcard.content) 
      logwb.write(str(suparticle)+' '+str(colarticle)+' '+logstr+'\n')

      if (str(requestcard.content).find("Следующие комбинации характеристик")):
        print('')
      else:
        with open('errorcard.csv', 'a', newline ='') as file:
          writer = csv.writer(file, delimiter=';')
          
          writer.writerow([category, brand, suparticle, colarticle, pol, razm, rosrazm, barcode, price, sostav, komplekt, country, tnved,  opis])
                
         
 logwb.close()















csvFilePath='newcard.csv'
with open(csvFilePath) as csvf:
    csvReader = csv.DictReader(csvf, delimiter=';')
  
    for rows in csvReader:
        try:
            goods_size(rows["Категория товара"],rows["Бренд"],rows["Артикул поставщика"], rows["Артикул цвета"], rows["Пол"],rows["Размер"], rows["Рос. размер"], rows["Штрихкод товара"], int(rows["Розничная цена"]), rows["Состав"], rows["Комплектация"], rows["Страна производства"], rows["Тнвэд"], rows["Описание"])
        except:
            continue
                                                                                   


