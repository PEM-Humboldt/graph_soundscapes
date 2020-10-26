# Simple step by step
## Load libraries
library(viridis)
library(tuneR)
library(seewave)

source('/Volumes/lacie_macosx/numerical_analysis_toolbox/graph_soundscape_analysis/graph_soundscape_fcns.R')
setwd('/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/VALLES/tmp/')
path_files = '/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/VALLES/tmp/'  # Folder location of acoustic dataset
# ---------------

flist = list.files(path_files, recursive = T, pattern = '.WAV', ignore.case = T)
df = metadata_audio(flist, path_files, verbose = T, rec_model = 'SM')
gs = graphical_soundscape(df, spec_wl=256, fpeaks_th=0.003, fpeaks_f=0, verbose=T) # inicial 0.002
plot_graphical_soundscape(gs)

# save
write.csv(gs, file='/Volumes/lacie_exfat/BST_ejemplo_PPII/graphical_soundscapes/V8DA.csv', row.names = F)

png('/Volumes/lacie_exfat/BST_ejemplo_PPII/figures/V8DA.png')
plot_graphical_soundscape(gs)
dev.off()