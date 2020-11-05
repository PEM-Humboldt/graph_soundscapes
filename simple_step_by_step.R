# Simple step by step
## Load libraries
library(viridis)
library(tuneR)
library(seewave)
source('graph_soundscape_fcns.R')

# Set variables 
path_files = '/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/VALLES/V6DA/'  # location of audio dataset
path_save_gs = './dataframes_gs/example_gs.csv'  # location to save the dataframe
path_save_fig = './figures/example_gs.png'  # location to save the figure
# -----------------

flist = list.files(path_files, recursive = T, pattern = '.WAV', ignore.case = T)

# Read an audio file
fname = flist[1]
fname_path = paste(path_files, fname, sep='')
s = readWave(fname_path)

# Check audio and set thrsehold for fpeaks
oscillo(s)
mspec = meanspec(s, wl = 256, wn = 'hanning', norm = F, plot=T)
peaks = fpeaks(mspec, threshold = 0.003, freq = 0, plot=T)

# Batch process a directory
df = metadata_audio(flist, path_files, verbose = T, rec_model = 'SM')

plot_sampling(df, y_axis_factor = df$sm_model, color_factor = df$sm_model, 
              shape_factor = factor(df$sample.rate), plot_title = df$sensor_name[1])

ggplot(df, aes(y=hour)) + geom_bar(width=0.3, alpha=0.5) + theme_minimal()

ggplot(df, aes(y=day)) + geom_bar(width=0.3, alpha=0.5)

# Set full path on dataframe, column path_audio
df$fname = df$path_audio
df$path_audio = paste(path_files,df$fname,sep='')

# Compute graphical soundscape
gs = graphical_soundscape(df, spec_wl=256, fpeaks_th=0.003, fpeaks_f=0, verbose=T) 
plot_graphical_soundscape(gs)

# Save dataframe and plot
write.csv(gs, file=path_save_gs, row.names = F)
png(path_save_fig)
plot_graphical_soundscape(gs)
dev.off()