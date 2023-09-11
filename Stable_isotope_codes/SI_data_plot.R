#=================================
#= Plot the stable isotope data =
#================================

#Adapted from https://gist.github.com/AndrewLJackson/b16fb216d8a9a96c20a4a979ec97e7b0


# load the packages
library(SIBER)
library(ggplot2)
library(dplyr)


# load the data
mydata <- read.table("PB_WG.txt", header=T)

# plot the data points
first.plot <- ggplot(data = mydata, aes(iso1, iso2)) +
  geom_point(aes(color = interaction(community, group)), size = 2)+
  ylab(expression(paste(delta^{15}, "N (\u2030)")))+
  xlab(expression(paste(delta^{13}, "C (\u2030)"))) + 
  theme(text = element_text(size=15)) +
  scale_colour_manual(values=c("orange","darkorange3"),drop=FALSE)+
  scale_fill_manual(values=c("orange","darkorange3"),drop=FALSE)

print(first.plot)

# change the plotting options (background without gridlines)
first.plot2 <-first.plot +  theme_classic() +
  theme(axis.text.x = element_text(size=16)) +
  theme(axis.text.y = element_text(size=16)) +
  theme(axis.title.x = element_text(size=17)) +
  theme(axis.title.y = element_text(size=17))


# Error-bar biplots - calculating mean and SD

sbg <- mydata %>% group_by(community, group) %>% 
  summarise(count = length(community),
            mC = mean(iso1), 
            sdC = sd(iso1), 
            mN = mean(iso2), 
            sdN = sd(iso2) )


# Add the mean and SD to the data plot
second.plot <- first.plot2 +
  geom_point(data = sbg, aes(mC, mN, group = interaction(community, group)), 
             color = c("orange","darkorange3"), shape = 22, size = 5,
             #fill=c("darkorchid1","darkorchid4","cyan3","darkcyan","darkolivegreen3","darkolivegreen4"),
             alpha = 1) + # to play with the transparence
  geom_errorbar(data = sbg, 
                mapping = aes(x = mC,
                              ymin = mN - sdN, 
                              ymax = mN + sdN), 
                color = c("orange","darkorange3"),
                width = 0, inherit.aes = FALSE)+
                geom_errorbarh(data = sbg, 
                 mapping = aes(y = mN,
                               xmin = mC - sdC,
                               xmax = mC + sdC),
                 color = c("orange","darkorange3"),
                 height = 0, inherit.aes = FALSE)
print(second.plot)


