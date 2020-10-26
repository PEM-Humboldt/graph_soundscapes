library(tuneR)
library(seewave)
library(ggplot2)


metadata_audio <- function(flist, path_files='.', verbose=T, rec_model='SM'){
  # Get metadata information from a list of files
  # Parameters
  # ----------
  # flist: file list with path to all files to be processed
  # path_files = path where audio files are located
  # verbose: boolean
  # rec_model: either 'SM' (songmeter) or 'AU' (audiomoth)
  
  audio_info = list()
  for(fname in flist){
    
    if(verbose){
      cat(paste(which(fname==flist),'/',length(flist),': ', fname,'\n', sep=''))
    }
      # get info from wave header
    fname_path = paste(path_files, fname, sep='')
    file_header = as.data.frame(readWave(fname_path, header = T))
    audio_info[[fname]] = file_header
    
    # get info from file
    audio_info[[fname]]$fsize = file.info(fname_path)$size
    audio_info[[fname]]$path_audio = fname
    
    # get info from filename
    if (rec_model=='SM')
      {
      cat('Songmeter recorder \t')
      sm_info = songmeter(gsub('__0__','_0_',fname))
      audio_info[[fname]]$sm_model = sm_info$model
      audio_info[[fname]]$sensor_name = sm_info$prefix
      audio_info[[fname]]$date = format(sm_info$time, format = "%Y-%m-%d %H:%M:%S")
      audio_info[[fname]]$time = format(sm_info$time, format = "%H:%M:%S")
      audio_info[[fname]]$length = round(file_header$samples/file_header$sample.rate,2)
      }
    else if (rec_model=='AU')
      {
      cat('Audiomoth recorder \t')
      aux = strsplit(fname,'/')[[1]]
      fname_audio_wav = aux[[length(aux)]] # name of file with no path to files
      rec_info = strsplit(fname_audio_wav,'_')[[1]]
      audio_info[[fname]]$recorder_model = 'Audiomoth'
      audio_info[[fname]]$sensor_name = rec_info[1]
      audio_info[[fname]]$date = strptime(paste(rec_info[2], substr(rec_info[3],1,6)), format = '%Y%m%d %H%M%S')
      audio_info[[fname]]$time = substr(rec_info[3],1,6)
      audio_info[[fname]]$length = round(file_header$samples/file_header$sample.rate,2)
      }
  }
  
  df = do.call(rbind, audio_info)
  row.names(df) <- NULL
  df = cbind(df['path_audio'],df[,-which(names(df)=='path_audio')])
  return(df)
}

# Plot sampling
plot_sampling <- function(xdata, y_axis_factor, color_factor, shape_factor, plot_title){
  xdata$date = as.POSIXct(strptime(xdata$date, format = "%Y-%m-%d %H:%M:%S"))
  base_plot <- ggplot(data = xdata) +
    geom_point(aes(x = date, y=y_axis_factor, color=color_factor, shape=shape_factor), 
               alpha = 0.4,
               size = 3) +
    labs(x = "Date", 
         y = "Recording",
         title = plot_title) +
    theme_minimal()
  
  base_plot
}

graphical_soundscape <- function(df, spec_wl=256, fpeaks_th=0.001, fpeaks_f=0, verbose=F){
  # Compute graphical soudscape for a list of audio files collected in a site
  
  # Parameters
  # ----------
  # df: Dataframe with file list and time of each recording.
  # spec_wl: int. Window length to compute the spectrum of audio
  # fpeaks_th: float. Amplitude threshold. Only peaks above this threshold will be considered. See fpeaks function.
  # fpeaks_f: float. Frequency threshold parameter (in Hz). If the frequency difference of two successive peaks is less than this threshold, then the peak of highest amplitude will be kept only. See fpeaks function.
  # verbose: boolean. Display progress of analysis.
  
  # Returns
  # -------
  # graph_spectro: a dataframe with graphical spectrogram mean peak values for each time-frequency value.
  
  # References
  # ----------
  # Campos‐Cerqueira, M., et al., 2020. How does FSC forest certification affect the acoustically active fauna in Madre de Dios, Peru? Remote Sensing in Ecology and Conservation 6, 274–285. https://doi.org/10.1002/rse2.120
  # Furumo, P.R., Aide, T.M., 2019. Using soundscapes to assess biodiversity in Neotropical oil palm landscapes. Landscape Ecology 34, 911–923.
  # Campos-Cerqueira, M., Aide, T.M., 2017. Changes in the acoustic structure and composition along a tropical elevational gradient. JEA 1, 1–1. https://doi.org/10.22261/JEA.PNCO7I
  
  features = list()
  for(idx in 1:nrow(df)){
    fname = df$path_audio[idx]
    if(verbose){ message(idx,'/',nrow(df), ': ',fname) }
    # load audio and normalize between -1 and 1
    s = readWave(fname)
    #s = normalize(s, unit='1')
    
    # compute fpeaks
    mspec = meanspec(s, wl = spec_wl, wn = 'hanning', norm = F, plot=F)
    peaks = fpeaks(mspec, threshold = fpeaks_th, freq = fpeaks_f, plot=F)
    
    # merge peaks in spectrogram
    colnames(mspec) <- c('freq', 'amp')
    colnames(peaks) <- c('freq', 'peak_amp')
    speak = as.data.frame(merge(mspec, peaks, by='freq', all=T))
    
    # make binary
    speak$peak_amp[is.na(speak$peak_amp)] <- 0
    speak$peak_amp[speak$peak_amp > 0] <- 1
    
    # save to dataframe
    features[[df$date[idx]]] = speak$peak_amp
  }
  
  # list to dataframe
  features = as.data.frame(do.call(rbind, features))
  colnames(features) = round(mspec[,1],2)
  
  ## AGGREGATE SAMPLES BY HOUR
  graph_spectro = aggregate(features, by = list(substr(df$time,1,2)), FUN = mean)
  colnames(graph_spectro)[1] = 'hour'
  colnames(graph_spectro)[2:129] = paste('F',colnames(graph_spectro)[2:129], sep='')
  return(graph_spectro)
}

plot_graphical_soundscape <- function(gs){
  # Plot Graphical Soundscape 
  # Note: This function requires the viridis package
  # Parameters
  # ----------
  # gs: DataFrame. A graphical soundscape dataframe computed using the function 'graphical_soundscape'
  # Returns
  # -------
  # Returns a plot of the Dataframe with time of day as x-axis, frequency as the y-axis, and proportion of peaks as intensity.
  # 
  nfeatures = ncol(gs)-1
  Hours = as.numeric(gs$hour) + 1
  Frequency = 1:nfeatures
  gs_frequency = as.numeric(substr(colnames(gs[,2:129]),2,6))
  image(x=Hours, y=Frequency, z=as.matrix(gs[,2:129]), col=viridis(256), axes=F)
  axis(1, at=1:24, labels=gs$hour)
  axis(2, at=seq(1,nfeatures,20), labels=gs_frequency[seq(1,nfeatures,20)])
}

