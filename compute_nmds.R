# COMPUTE NMDS AND PLOT RESULT
library(vegan)
library(ade4)
path_gs = './dataframes_gs/'
sites = c("C1BO","C2BO","C3GU","C4GU","C5GU","C6CE","V1TO","V2TO","V3HU","V4HU","V5DA","V6DA")

# load data and organize as a community matrix (sites as rows, soundscape component (species) as columns)
tf_bins = list()
for(site in sites){
  gs = read.csv(paste(path_gs,site,'.csv',sep=''))
  tf_bins[[site]] = as.vector(t(gs[,-1]))
}

# list to dataframe
tf_bins = as.data.frame(do.call(rbind, tf_bins))

# Compute NMDS
tf_bins_nmds = metaMDS(tf_bins, distance = 'bray')
stressplot(tf_bins_nmds)  # validate model fit
tf_bins_nmds$stress

# Plot results in 2D space
plot(tf_bins_nmds, type='t',  display = 'sites')
plt_data = tf_bins_nmds$points
s.class(plt_data, fac=factor(c(rep('C',6),rep('V',6))), col = c('red','blue'))

# Use a non parametric test to evaluate significance of the groups
xdata = data.frame(x=tf_bins_nmds$points[,1], y=tf_bins_nmds$points[,2], region=factor(substr(row.names(tf_bins),1,1)))
dist = vegdist(tf_bins, 'bray')
adonis(dist~xdata$region, permutations = 1000)

# Example when groups are not significant
#s.class(plt_data, fac=factor(c('C','V','C','V','C','V','C','V','C','V','C','V')), col=c('red','blue'))
#xdata = data.frame(x=tf_bins_nmds$points[,1], y=tf_bins_nmds$points[,2], region=c('C','V','C','V','C','V','C','V','C','V','C','V')) # with random samples
#dist = vegdist(tf_bins, 'bray')
#adonis(dist~xdata$region, permutations = 1000)
