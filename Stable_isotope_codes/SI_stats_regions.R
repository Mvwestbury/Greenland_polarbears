
## Geographical differences in stable isotopes values

## load the data
data1<-read.table("PB_WG.txt", header=T)

### Carbon

## create subset by area (Baffin Bay: BB and Kane Basin: KB)
PB_BB<-subset(data1, group == "BB_PB")
PB_KB<-subset(data1, group == "KB_PB")

hist(data1$iso1,breaks=5)

## Normality test

shapiro.test(PB_BB$iso1) 
#Shapiro-Wilk normality test
#data:  PB_BB$iso1
#W = 0.9415, p-value = 0.6713

shapiro.test(PB_KB$iso1)
# 	Shapiro-Wilk normality test
#data:  PB_KB$iso1
#W = 0.98904, p-value = 0.9913

## test for homogeneity of variance

var.test(data1$iso1~data1$group)

#F test to compare two variances
#data:  data1$iso1 by data1$group
#F = 23.866, num df = 5, denom df = 6, p-value = 0.001363
#alternative hypothesis: true ratio of variances is not equal to 1
#95 percent confidence interval:
#  3.98588 166.52784
#sample estimates:
#  ratio of variances 
#23.86571 

## transform data to numeric
data1$iso1<-as.numeric(data1$iso1)

## Statistic comparison
# As variance are not homogenous, we use Mann Whitney wilcox test
wilcox.test(data1$iso1 ~ group, data=data1) 

#	Wilcoxon rank sum exact test
#data:  data1$iso1 by group
#, p-value = 0.4452
#alternative hypothesis: true location shift is not equal to 0


### Nitrogen

## Normality test
shapiro.test(PB_BB$iso2) 
#Shapiro-Wilk normality test

#data:  PB_BB$iso2
#W = 0.97716, p-value = 0.9366


shapiro.test(PB_KB$iso2)
#Shapiro-Wilk normality test

#data:  PB_KB$iso2
#W = 0.89449, p-value = 0.2989

data1$iso2<-as.numeric(data1$iso2)

## test for homogeneity of variance

var.test(data1$iso2~data1$group)
#F test to compare two variances
#data:  data1$iso2 by data1$group
#F = 1.062, num df = 5, denom df = 6, p-value = 0.9254
#alternative hypothesis: true ratio of variances is not equal to 1
#95 percent confidence interval:
#  0.177364 7.410170
#sample estimates:
#  ratio of variances 
#1.061979 


## Statistic comparison
# student t-test
t.test(data1$iso2~data1$group)

#Welch Two Sample t-test
#data:  data1$iso2 by data1$group
#t = -1.6227, df = 10.583, p-value = 0.134
#alternative hypothesis: true difference in means is not equal to 0
#95 percent confidence interval:
#  -1.7817477  0.2736525
#sample estimates:
#  mean in group BB_PB mean in group KB_PB 
#21.00167            21.75571 


