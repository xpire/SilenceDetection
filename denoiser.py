# Justin 2019
# Similar to silence_cutter.py, but only does dc normalisation and a 10Hz high pass filter.

import os
import numpy as np
import argparse
from tqdm import tqdm

import librosa
import soundfile as sf
import re



def load_file(input_filename, mono=True, sr=22050):
    # if mono is true, returns samples of shape (2, n, )
    # else returns samples of shape (n, )
    # sample rate refers to number of samples per second: default selected by None, librosa default is 22050
    x, sr = librosa.load(input_filename, mono=mono, sr=sr)
    return x, sr

def dc_removal(x, sr):
    x_mean = np.mean(x)
    x = [e - x_mean for e in x]
    return x

def high_pass_filter(x, sr, cutOff = 500):
    from scipy import signal

    #Creation of filter
    nyq = 0.5 * sr
    N  = 5    # Filter order
    fc = cutOff / nyq # Cutoff frequency normal
    b, a = signal.butter(N, fc, btype='high') # high pass filter

    #Apply the filter
    tempf = signal.filtfilt(b, a, x)

    return tempf


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_dir', default='input/')
    parser.add_argument('--output_dir', default='output/')
    parser.add_argument('--start_range', default=0, type=int)
    parser.add_argument('--end_range', default=9, type=int)
    parser.add_argument('--wait', default=0, type=int)

    args = parser.parse_args()
    print(args.input_dir)

    directory = os.fsencode(args.input_dir)
    count = 0
    for file in os.listdir(directory):
        filename = os.fsdecode(file)
        if filename.endswith(".wav"):

            cur_file = os.fsdecode(os.path.join(directory, file))
            print("Processing ", cur_file)
            count += 1
            if count <= args.wait:
                print("pass")
                continue
            filename = cur_file[len(args.input_dir):-4]
            x, sr = load_file(cur_file)
            t = dc_removal(x, sr)
            t = high_pass_filter(x, sr, cutOff=10)
            print("outputting to :", args.output_dir + filename + ".wav", sr)
            sf.write(args.output_dir+filename+".wav", t, sr)
