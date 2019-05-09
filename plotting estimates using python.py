# -*- coding: utf-8 -*-


"""
Created on Mon Apr 15 10:25:55 2019

@author: Robert Schuldt
@email: rschuldt@uams.edu

Plotting the Zscores for paper with Landes, Chen, and I using python
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


df = pd.read_csv("C:\\Users\\3043340\\Desktop\\Box Sync\\Schuldt Research Work\\HHBVP\\11-5-2018 2016 Redux\\plottingpython2.csv", header = 0)

df2 = df[['MSR', 'URB_RUR', 'Estimate', 'Upper', 'Lower']]
df2 = df2.drop(['Estimate'], axis = 1)
df2 = df2.rename(columns={'Upper':'Estimate'})

df3 = df[['MSR', 'URB_RUR', 'Estimate', 'Upper', 'Lower']]
df3 = df3.drop(['Estimate'], axis = 1)
df3 = df3.rename(columns={'Lower':'Estimate'})

df = df.append(df2)
df = df.append(df3)



sns.set(rc={'figure.figsize':(11.7, 8.27)})
ax=sns.pointplot(x='MSR', y= 'Estimate', hue='URB_RUR', size= 'RUR_URB', join= False,  data= df, dodge=.5 ,order= [ 'HOSPITAL','EMERGENCY', 'HARM','DAILY', 'WOUND','PAIN','STAR'])
ax.set_title('Comparison of Z Scores of Home Health Quality Measurements by Rurality')
ax.set(xlabel= 'Quality Measurements', ylabel= 'Z Scores with Confidence Intervals')
ax.legend().set_title('Rurality Level')

plt.show()