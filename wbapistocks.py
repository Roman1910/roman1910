import json
import csv
import requests
import glob
import os
bar=""
splitfiles=[]
b = [{" barcode": 25619101, "stock": 1, "warehouseId": 849 }]
url1= 'https://suppliers-api.wildberries.ru/api/v2/stocks'

#CSV SPLIT
def split(filehandler, delimiter=';', row_limit=40000,
          output_name_template='output_%s.csv', output_path='.', keep_headers=True):
    import csv
    reader = csv.reader(filehandler, delimiter=delimiter)
    current_piece = 1
    current_out_path = os.path.join(
        output_path,
        output_name_template % current_piece
    )
    current_out_writer = csv.writer(open(current_out_path, 'w'), delimiter=delimiter)
    current_limit = row_limit
    if keep_headers:
        headers = next(reader)
        current_out_writer.writerow(headers)
    for i, row in enumerate(reader):
        if i + 1 > current_limit:
            current_piece += 1
            current_limit = row_limit * current_piece
            current_out_path = os.path.join(
                output_path,
                output_name_template % current_piece
            )
            current_out_writer = csv.writer(open(current_out_path, 'w'), delimiter=delimiter)
            if keep_headers:
                current_out_writer.writerow(headers)
        current_out_writer.writerow(row)

split(open('wb.csv', 'r'));

#CSV UPLOAD
def wbapi(csvFilePath):
 k=1
 urlist = 'https://suppliers-api.wildberries.ru/card/list'
 headers1={ 'Accept':'*/*','Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NJRCI6IjgzNDQxMmRhLTA2ZjItNDczYS04ZDVlLTk2NzBiMzg2Yzc4OSJ9.XUjF-e1QTSiyttp3ySr6Mt2HyNpoFV9jHoy8p8Xz5cg'} 
 with open(csvFilePath, ) as csvf:
     csvReader = csv.DictReader(csvf, delimiter=';')
     b.pop(0)
     for rows in csvReader:
        nmid=int(rows["nmId"])
        
        
        body=json.dumps({
        "id": "1",
        "jsonrpc": "2.0",
        "params": {
            "filter": {
              
                "find": [
                  {
                    "column": "nomenclatures.nmId", 
                    "search": nmid 
                  }
                ],
            
                "order": {                                                      
                    "column": "createdAt",
                    "order": "asc"
                    } 
                },
                
                "query": {                                                          
                "limit": 10
                
            }
           
        }
    })
        requestcard = requests.post(urlist, data=body,headers=headers1)
        bar=" "
        updata=json.loads(requestcard.content.decode("utf-8").replace("'",'"'))
        for nomenc in  updata["result"]["cards"][0]["nomenclatures"]:
            if(nomenc["nmId"]==nmid):
                bar=nomenc["variations"][0]["barcodes"][0]
            #bar=str(updata["result"]["cards"][0]["nomenclatures"][0]["variations"][0]["barcodes"][0])
        print(nmid)
        print(bar)
        b.append({"barcode": bar, "stock" : int(rows["quantity"]), "warehouseId": int(rows["storeId"])},)
      
        k=k+1
              
 
        headers={ 'Content-type':'application/json','Accept': '*/*', 'Authorization':'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NJRCI6ImJlM2E0NTg0LWJkOGYtNDM5YS1hMTA0LTdmNDdkZTQ0NDBiOSJ9.tN75i_H6kz1CjTTj_2Nc-NeJ4SyCkc-quh9j-C1fdCM'} 

 
        answer = requests.post(url1, data=json.dumps(b), headers=headers)
        print(answer)
        if (str(answer) != "<Response [200]>"):
           with open('response.txt', 'a', encoding='utf-8') as resp:
                resp.write(nmid+str(answer.content)+'\n')
                


#START UPLOAD
os.chdir(".")
for file in glob.glob("output_*.csv"):
    splitfiles.append(file)

for file in splitfiles:
    wbapi(file)
#DELETEFILES
os.chdir(".")
for file in glob.glob("output_*.csv"):
    os.remove(file)
