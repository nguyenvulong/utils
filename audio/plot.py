import numpy as np
import librosa
import librosa.display
import matplotlib.pyplot as plt
import IPython
import IPython.display as ipd
import soundfile as sf
from pydub import AudioSegment


%matplotlib inline

def plot_and_play(filePath):
    """
    input: file path to the audio file. 
    For .wav format, filePath can be used as direct input to waveshow().
    This function plots the & displays the audio 
    We would need to force the HTML to be displayed as Audio() is used inside a function
    """
    data, sr = librosa.load(filePath, sr=None)
    ax = plt.figure(figsize=(14, 5))
    plt.axis((None,7,-1,1))

    librosa.display.waveshow(data, sr=sr)
    IPython.core.display.display(ipd.Audio(data=data,rate=sr)) #force the function to render the HTML
    
def flac_to_mp3(filePath):
    sample = AudioSegment.from_file(filePath, format="flac")
    file_handle = sample.export(".".join(filePath.split(".")[:-1])  + ".mp3",
                           format="mp3",)
                           #bitrate="192k",)

def plot_melspectrogram(filePath):
    fig, ax = plt.subplots(figsize=(15,10))
    y, sr = librosa.load(filePath, sr=None)
    S = librosa.feature.melspectrogram(y=y, sr=sr, 
                                       n_mels=128, fmax=8000)
    S_dB = librosa.power_to_db(S, ref=np.max)
    img = librosa.display.specshow(S_dB, x_axis='time',
                                   y_axis='mel', sr=sr,
                                   fmax=8000, ax=ax)
    fig.colorbar(img, ax=ax, format='%+2.0f dB')
    ax.set(title='Mel-frequency spectrogram')
