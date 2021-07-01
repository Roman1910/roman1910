from pdfminer.layout import LAParams, LTTextBox
from pdfminer.pdfpage import PDFPage
from pdfminer.pdfinterp import PDFResourceManager
from pdfminer.pdfinterp import PDFPageInterpreter
from pdfminer.converter import PDFPageAggregator
import pdfminer
from PyPDF2 import PdfFileWriter
import re
from tkinter import *
import glob
import sys

pdf_writer=PdfFileWriter
from PyPDF2 import PdfFileWriter, PdfFileReader 


words={}
#list of keyword in lines remember that the csv file (Encode in UTF-8)
#with open("111.csv","r", encoding="utf-8") as file:
#    searchwords = [l.strip() for l in file]






def pdfsearch(swords,file):


 rsrcmgr = PDFResourceManager()
 laparams = LAParams()
 device = PDFPageAggregator(rsrcmgr, laparams=laparams)
 interpreter = PDFPageInterpreter(rsrcmgr, device)
 infile = PdfFileReader(open(file, 'rb'))
 
 fp = open(file, 'rb')


 pages = PDFPage.get_pages(fp)
 for word in swords:
    w="\\"
    out=""
    k=0
    for i in word:
       if(i in ">)(*\=/<"".^+?-!;:#%_,'&"):
        out+=w + word[k]
       else:
        out+=word[k]   
       k=k+1
 swords=[out]   
 countpg=0   
 with open('FoundWordsList.csv', 'w') as f:
    #f.write('{0},{1}\n'.format("Sheet Number", "Search Word"))
    for page in pages:
        #print('Processing next page...')
        countpg=countpg+1
       # print(countpg)
        interpreter.process_page(page)
        layout = device.get_result()
        for word in swords:
            for lobj in layout:
                    if isinstance(lobj, LTTextBox):
                        x, y, text = lobj.bbox[0], lobj.bbox[3], lobj.get_text()
                        ResSearch = re.search(word, text)
                        if bool(ResSearch):
                                print('text: %s' % (word))
                                
                                #f.write('{0},{1}\n'.format(countpg, word))
                                pg=int(countpg)
                                p = infile.getPage(pg-1)
                                outfile = PdfFileWriter()
                                outfile.addPage(p)
                                with open('.\out\page-%02d.pdf' % pg, 'wb') as fpdf:
                                   outfile.write(fpdf)
                                sys.exit() 
                        #print('At %r is text: %s' % ((x, y), text))


search=["rrr"]
master = Tk()
e = Entry(master)
e.pack()

e.focus_set()
def callback():
    # This is the text you may want to use later
    d=e.get()
    search=[d]
    
    for file in glob.glob(".\in\*.pdf"):
        print(file)  
        pdfsearch(search,file)
        
      
b = Button(master, text = "OK", width = 10, command = callback)

b.pack()
mainloop()




  
