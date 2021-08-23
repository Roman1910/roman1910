import json
import csv
import requests
import glob
import os

splitfiles=[]
b = {"token": "0e418283ededd518600c318ec2a5b160d0a898b62ec91ef6e31d8437b0b2ceab", "data": [{ "nmId": 25619101, "stocks": [{ "chrtId": 59589340, "price": 23, "quantity": 0, "storeId": 849 }]}]}
url1= 'https://wbxgate.wildberries.ru/stocks'

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
 k=0

 with open(csvFilePath, ) as csvf:
     csvReader = csv.DictReader(csvf, delimiter=';')
     for rows in csvReader:
        if(rows["nmId"]==b["data"][k]["nmId"]):
            b["data"][k]["stocks"].append({"chrtId": int(rows["chrtId"]), "price" : int(rows["price"]), "quantity" : int(rows["quantity"]), "storeId": int(rows["storeId"])},)
        else:
            b["data"].append({"nmId": int(rows["nmId"]), "stocks": [{"chrtId": int(rows["chrtId"]), "price" : int(rows["price"]), "quantity" : int(rows["quantity"]), "storeId": int(rows["storeId"])},]})
            k=k+1
 b["data"].pop(0)        
 print(b)

 answer = requests.post(url1, data=json.dumps(b))
 print(answer)
 with open('response.txt', 'w', encoding='utf-8') as resp:
        resp.write(str(answer))
 


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
