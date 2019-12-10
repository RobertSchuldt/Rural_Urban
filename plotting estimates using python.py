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

df = pd.read_csv("Z:\\DATA\\Rural Urban Project\\Journal of Rural Health - Revisions\\plottingpython.csv", header = 0)

df2 = df[['MSR', 'URB_RUR', 'Estimate', 'Upper', 'Lower']]
df2 = df2.drop(['Estimate'], axis = 1)
df2 = df2.rename(columns={'Upper':'Estimate'})

df3 = df[['MSR', 'URB_RUR', 'Estimate', 'Upper', 'Lower']]
df3 = df3.drop(['Estimate'], axis = 1)
df3 = df3.rename(columns={'Lower':'Estimate'})

df = df.append(df2)
df = df.append(df3)




ax=sns.pointplot(x='MSR', y= 'Estimate', hue='URB_RUR', size= 'RUR_URB', join= False,  data= df, dodge=.5, capsize = .1, linestyles=["-", "--", "-.", ":" ],
                 order= [ 'Hospitalizations','ED Visits', 'Patient-experience', 'ADL Improvement', 'Pain Management', 'Harm Prevention', 'Treating Wounds'])
ax.set_title("Appendix B.  Model Means (95% Confidence Intervals) of Quality Performance z-scores for Home Health Agencies by Rurality Level")
ax.set(xlabel= '', ylabel= 'Model Mean (SD units)')
ax.legend(bbox_to_anchor= (1.05, 1), loc= 2).set_title('Rurality Level')
'''ax.text(-1.9, -2, "Comparing each rural category to urban, * indicates $p$ < .05, ** $p$ < .01, and *** $p$ < .001; $p$-values not adjusted for multiple comparisons. ", ha = 'left')
'''
for item in ax.get_xticklabels():
    item.set_rotation(60)
plt.show()

ax.figure.savefig("Z:\\DATA\\Rural Urban Project\\Journal of Rural Health - Revisions\\10-22 QQ Plot Normality\\output.pdf", bbox_inches= 'tight', dpi= 500)

