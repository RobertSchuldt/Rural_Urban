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
import numpy as np

df = pd.read_csv("C:\\Users\\3043340\\Box\\Schuldt Research Work\\HHBVP\\11-5-2018 2016 Redux\\plottingpython2.csv", header = 0)

df2 = df[['MSR', 'URB_RUR', 'Estimate', 'Upper', 'Lower']]
df2 = df2.drop(['Estimate'], axis = 1)
df2 = df2.rename(columns={'Upper':'Estimate'})

df3 = df[['MSR', 'URB_RUR', 'Estimate', 'Upper', 'Lower']]
df3 = df3.drop(['Estimate'], axis = 1)
df3 = df3.rename(columns={'Lower':'Estimate'})

df = df.append(df2)
df = df.append(df3)
r1 = np.random.random()



ax=sns.pointplot(x='MSR', y= 'Estimate', hue='URB_RUR', size= 'RUR_URB', join= False,  data= df, dodge=.4, capsize = .1, linestyles=["-", "--", "-.", ":" ],
                 order= [ 'Hospitalizations','ED Visits', 'Patient-experience Star Ratings', 'ADL Improvement', 'Pain Management Improvement', 'Harm Prevention', 'Treating Wounds'])
ax.set_title("Figure  Model Means (and 95% Confidence Intervals) of Quality Performance z-scores for Home Health Agencies by Rurality Level")
ax.set(xlabel= 'Quality Performance Outcome', ylabel= 'Model mean (SD units)')
ax.legend().set_title('Rurality Level')
ax.text(-.9, -.70, "Comparing each rural category to urban, * indicates $p$ < .05, ** $p$ < .01, and *** $p$ < .001; $p$-values not adjusted for multiple comparisons. ", ha = 'left')

for item in ax.get_xticklabels():
    item.set_rotation(45)
plt.show()

ax.figure.savefig("C:\\Users\\3043340\\Box\\Rural Urban Project\\output.png", bbox_inches= 'tight', dpi= 500)
