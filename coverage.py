#!usr/bin/env python3

#This script should calculate the coverage for a target position.

import pandas as pd 
import matplotlib.pyplot as plt
from bokeh.plotting import figure, output_file, show
from bokeh.models import ColumnDataSource, NumeralTickFormatter


header_names=["Chromosome", 'Start', 'End', 'NumberofReads']
df = pd.read_csv("coverage.tab", sep="\t", skiprows=(0,1), names=header_names)

print(df.head())

targetname=[]
targetpos=[]
chromosome=[]
target_dict={}

def non_blanklines(f):      #this function deletes blank lines in the target file
    for l in f:
        line = l.rstrip().split()
        if line:
            yield line
        


with open("input/targets.bed") as f_in:
    for line in non_blanklines(f_in):
        targetname.append(line[3])
        targetpos.append(line[1] + "-" + line[2])
        chromosome.append(line[0])
        target_dict[line[3]]=line[0] + ":" + line[1] + "-" + line[2]
        

##extract data from df by the dic 

def extract_by_targets(chr, start, end, name):
    termdf=df.loc[(df['Chromosome'] == chr) & (df['Start'] >= start ) & (df['Start'] <= end)]
    #termdf['TargetName'] = name 
    #pd.concat([df,termdf])  
    return termdf

z=df

with open("input/targets.bed") as f_in:
    for line in non_blanklines(f_in):
        #L = line.strip().split()
        chromv=line[0]
        startv=int(line[1])
        endv=int(line[2])
        namev=line[3]
        x=extract_by_targets(chromv, startv, endv, namev)
        x['Name'] = namev
        z=pd.concat([z,x])

termz=z.loc[z['Name']=='TRPA1']

output_file("plot.html")

#source2=ColumnDataSource(data=nano)
#TOOLTIPS=[("methylation", "@methylated_frequency"), ("position", "@start")]
p=figure(title="Methylation frequency for...", plot_width=1600) #tooltips=TOOLTIPS)
p.line(x='Start', y='NumberofReads', source=termz, color="red")
p.xaxis.major_label_orientation = "vertical"
p.xaxis[0].formatter = NumeralTickFormatter(format="0000000")
show(p)



            
#dftwo.plot(x='Start', y='NumberofReads')
#plt.show()