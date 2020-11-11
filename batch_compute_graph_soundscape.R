## SOUNDSCAPE CHARACTERIZATION
# References
# Campos‐Cerqueira, M., et al., 2020. How does FSC forest certification affect the acoustically active fauna in Madre de Dios, Peru? Remote Sensing in Ecology and Conservation 6, 274–285. https://doi.org/10.1002/rse2.120
# Furumo, P.R., Aide, T.M., 2019. Using soundscapes to assess biodiversity in Neotropical oil palm landscapes. Landscape Ecology 34, 911–923.
# Campos-Cerqueira, M., Aide, T.M., 2017. Changes in the acoustic structure and composition along a tropical elevational gradient. JEA 1, 1–1. https://doi.org/10.22261/JEA.PNCO7I
source('graph_soundscape_fcns.R')
library(viridis)
library(vegan)

## SET VARIABLES
path_dataset = '/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/'
path_metadata = '/Volumes/lacie_exfat/BST_ejemplo_PPII/metadata/audio_metadata.csv'
path_save = '/Volumes/lacie_exfat/BST_ejemplo_PPII/graphical_soundscapes/'
sites = c("C1BO","C2BO","C3GU","C4GU","C5GU","C6CE","V1TO","V2TO","V3HU","V4HU","V5DA","V6DA")

## COMPUTE GRAPH SOUNDSCAPE FOR EACH RECORDING
# Please follow the step by step presented in read_audio_metadata to get all
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
