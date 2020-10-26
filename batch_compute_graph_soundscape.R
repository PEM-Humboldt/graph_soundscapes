## SOUNDSCAPE CHARACTERIZATION
# References
# Campos‐Cerqueira, M., et al., 2020. How does FSC forest certification affect the acoustically active fauna in Madre de Dios, Peru? Remote Sensing in Ecology and Conservation 6, 274–285. https://doi.org/10.1002/rse2.120
# Furumo, P.R., Aide, T.M., 2019. Using soundscapes to assess biodiversity in Neotropical oil palm landscapes. Landscape Ecology 34, 911–923.
# Campos-Cerqueira, M., Aide, T.M., 2017. Changes in the acoustic structure and composition along a tropical elevational gradient. JEA 1, 1–1. https://doi.org/10.22261/JEA.PNCO7I
source('audio_metadata_utilities.R')
library(viridis)
library(vegan)

## SET VARIABLES
path_dataset = '/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/'
path_metadata = '/Volumes/lacie_exfat/BST_ejemplo_PPII/metadata/audio_metadata.csv'
path_save = '/Volumes/lacie_exfat/BST_ejemplo_PPII/graphical_soundscapes/'
sites = c("C1BO","C2BO","C3GU","C4GU","C5GU","C6CE","V1TO","V2TO","V3HU","V4HU","V5DA","V6DA")

## COMPUTE MEAN FOR EACH RECORDING
df = read.csv(path_metadata)

for(site in sites){
    df_site = df[df$site==site,]
    gs = graphical_soundscape(df_site, spec_wl=256, fpeaks_th=0.003, fpeaks_f=0, verbose=T) # inicial 0.002
    fname_save = paste(path_save, site, '.csv', sep='')
    write.csv(gs, file=fname_save, row.names = F)
    }


## PLOT
path_gs = '/Volumes/lacie_exfat/BST_ejemplo_PPII/graphical_soundscapes/'
path_save_figure = '/Volumes/lacie_exfat/BST_ejemplo_PPII/figures/'
for(site in sites){
    gs = read.csv(paste(path_gs,site,'.csv',sep=''))
    png(paste(path_save_figure,site,'.png',sep=''))
    plot_graphical_soundscape(gs)
    dev.off()
    }

# COMPUTE NMDS AND PLOT RESULT
library(vegan)
path_gs = '/Volumes/lacie_exfat/BST_ejemplo_PPII/graphical_soundscapes/'

# load data and organize as a community matrix (sites as rows, soundscape component (species) as columns)
tf_bins = list()
for(site in sites){
    gs = read.csv(paste('/Volumes/lacie_exfat/BST_ejemplo_PPII/graphical_soundscapes/',site,'.csv',sep=''))
    tf_bins[[site]] = as.vector(t(gs))
    }

# list to dataframe
tf_bins = as.data.frame(do.call(rbind, tf_bins))

# Compute NMDS and plot
tf_bins_nmds = metaMDS(tf_bins, distance = 'bray')
tf_bins_nmds$stress
plot(tf_bins_nmds, type='t',  display = 'sites')

library(ade4)
plt_data = tf_bins_nmds$points
s.class(plt_data, fac=factor(c(rep('C',6),rep('V',6))))

# Dibujar clusters
?hclust
tf_clust = hclust(vegdist(tf_bins_nmds$points,'euclidean'), 'ward.D')
plot(tf_clust, labels=row.names(tf_bins))

# Evaluar estadísticamente
xdata = data.frame(x=tf_bins_nmds$points[,1], y=tf_bins_nmds$points[,2], region=factor(substr(row.names(tf_bins),1,1)))
xdata = data.frame(x=tf_bins_nmds$points[,1], y=tf_bins_nmds$points[,2], region=c('C','V','C','V','C','V','C','V','C','V','C','V')) # with random samples
dist = vegdist(xdata[,c('x','y')], 'euclidean')
dist = vegdist(tf_bins, 'jaccard')
adonis(dist~xdata$region, permutations = 1000)


