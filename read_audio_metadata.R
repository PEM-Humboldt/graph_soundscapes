# Get list of audio files and associated metadata
# Author: Juan Sebastián Ulloa (julloa[at]humboldt.org.co)

# Load functions
source('graph_soundscape_fcns.R')
# set variables
path_files = '/Volumes/lacie_exfat/BST_ejemplo_PPII/audio/'  # Folder location of acoustic dataset
fpath_save = '/Volumes/lacie_exfat/BST_ejemplo_PPII/metadata/audio_metadata.csv' # Filename of csv that will store the metadata
# ---------------

flist = list.files(path_files, recursive = T, pattern = '.WAV', ignore.case = T)
df = metadata_audio(flist, path_files, verbose = T, rec_model = 'SM')

## post-process to include factors or sites
aux = strsplit(df$path_audio, split = '/')
aux_df = as.data.frame(do.call(rbind, aux))
head(aux_df)
# set treatment, site and short file name
df['treatment'] = aux_df$V1
df['site'] = aux_df$V2
df['fname_audio'] = aux_df$V3

# Check dataframe manually
head(df)
tail(df)
table(df$site)  # number of recordings per site

# plot sampling
plot_sampling(df, y_axis_factor = df$site, color_factor = df$site, shape_factor = df$treatment, plot_title = 'Example')

# save dataframe to csv
write.table(df, fpath_save, sep=',', col.names = TRUE, row.names = FALSE)
