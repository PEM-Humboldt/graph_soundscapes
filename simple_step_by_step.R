# Simple step by step
## Load libraries
library(viridis)
library(tuneR)
library(seewave)

source('graph_soundscape_fcns.R')
setwd('/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/VALLES/V6DA/')
path_files = '/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/VALLES/V6DA/'  # Folder location of acoustic dataset
# ---------------

flist = list.files(path_files, recursive = T, pattern = '.WAV', ignore.case = T)

# Read an audio file
fname = flist[1]
fname_path = paste(path_files, fname, sep='')
s = readWave(fname_path)

oscillo(s)

spec(s, wl = 512)

mspec = meanspec(s, wl = 256, wn = 'hanning', norm = F, plot=T)
peaks = fpeaks(mspec, threshold = 0.003, freq = 0, plot=T)

spectro(s, wl=512, ovlp=0.5)

# batch process a directory
df = metadata_audio(flist, path_files, verbose = T, rec_model = 'SM')

plot_sampling(df, y_axis_factor = df$sm_model, color_factor = df$sm_model, 
              shape_factor = factor(df$sample.rate), plot_title = df$sensor_name[1])

ggplot(df, aes(y=hour)) + geom_bar(width=0.3, alpha=0.5) + theme_minimal()

ggplot(df, aes(y=day)) + geom_bar(width=0.3, alpha=0.5)

gs = graphical_soundscape(df, spec_wl=256, fpeaks_th=0.003, fpeaks_f=0, verbose=T) # inicial 0.002
plot_graphical_soundscape(gs)

# save
write.csv(gs, file='/Volumes/lacie_exfat/BST_ejemplo_PPII/graphical_soundscapes/V8DA.csv', row.names = F)

png('/Volumes/lacie_exfat/BST_ejemplo_PPII/figures/V8DA.png')
plot_graphical_soundscape(gs)
dev.off()