# Justin 2019
# Code is from the python notebooks.

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

def get_S(x, sr):
    x = np.array(x)
    return librosa.feature.melspectrogram(y=x, sr=sr, n_mels=128, fmax=8000)

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


def preprocess(t, sr):
    s = get_S(t, sr)
    rms = librosa.feature.rms(S = s)
    threshold =  np.heaviside(rms[0] - 0.025,1)

    i = 0
    min_len = 0.1
    epsilon = min_len *2/5  # the smallest silence possible is 0.1,
                            # which means we can pad sounds by epsilon
                            # in case this algorithm cuts too early or too late
                            # the constant has to be in [0, 0.5)
    silence = (threshold[i] == 1.0)
    sounds = []
    curr_sound = []

    # 1. Deduce sounds based on threshold
    for i in range(1, len(threshold)):
        if threshold[i] == 1.0 and threshold[i-1] < 1.0:
            #start of sound
            if not curr_sound:
                curr_sound.append(i*512/sr)
        elif threshold[i] == 0.0 and threshold[i-1] > 0.0:
            #end of sound
            if curr_sound:
                curr_sound.append(i*512/sr)
                sounds.append(curr_sound)
                curr_sound = []

    # 2. Silence must be greater than min_len for silence
    print("before: len = ", len(sounds))
    i = 1
    while i < len(sounds):
        if sounds[i][0]-sounds[i-1][1] < min_len:
            # this silence is too short
            sounds[i-1][1] = sounds[i][1]
            sounds.pop(i)
            i -= 1
        i += 1

    i = 1
    while i < len(sounds):
        if sounds[i][1] - sounds[i][0] < min_len:
            # this sound is also too short
            sounds.pop(i)
            i -= 1
        i += 1

    # 3. Pad sounds by epsilon so we avoid cutting off the sounds due to the
    #    algorithm's inaccuracy.
    i = 1
    while i < len(sounds):
        sounds[i][0]-=epsilon
        sounds[i][1]+=epsilon

    print("now, sounds: ", len(sounds))
    return t, rms, threshold, sounds

# silence cutting operations
def delete(sounds, index, sound=True):
    if sound:
        sounds.pop(index)
        return sounds
    else: #sound == False:
        # the n-th silence is after the n-th sound
        if n > len(sounds):
            # out of index, dont delete anything
            return sounds
        sounds[index][1] = sounds[index][0]
        sounds.pop(index+1)
        return sounds





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
            # if int(filename[0]) < args.start_range or int(filename[0]) > args.end_range:
            #     print("pass")
            #     continue
            x, sr = load_file(cur_file)
            x = dc_removal(x, sr)
            t = high_pass_filter(x, sr, cutOff=300)
            s = get_S(t, sr)
            rms = librosa.feature.rms(S = s)
            threshold =  np.heaviside(rms[0] - 0.025,1)

            # 1. Using threshold, determine where the silences and sound are
            i = 0
            silence = (threshold[i] == 1.0)
            sounds = []
            curr_sound = []
            for i in range(1, len(threshold)):
                if threshold[i] == 1.0 and threshold[i-1] < 1.0:
                    #start of sound
                    if not curr_sound:
                        curr_sound.append(i*512/sr)
                elif threshold[i] == 0.0 and threshold[i-1] > 0.0:
                    #end of sound
                    if curr_sound:
                        curr_sound.append(i*512/sr)
                        sounds.append(curr_sound)
                        curr_sound = []
            # 2.1. Silence must have a minimum length of min_len
            print("before: len = ", len(sounds))
            i = 1
            min_len = 0.09
            while i < len(sounds):
                if sounds[i][0]-sounds[i-1][1] < min_len:
                    # this silence is too short
                    sounds[i-1][1] = sounds[i][1]
                    sounds.pop(i)
                    i -= 1
                i += 1

            # 2.2. Sounds must have a minimum length of min_len
            i = 1
            while i < len(sounds):
                if sounds[i][1] - sounds[i][0] < min_len:
                    # this silence is also too short
                    sounds.pop(i)
                    i -= 1
                i += 1

            # 3. Pad sounds by episilon, a fraction of min_len to ensure we keep
            #    as much of the sound as possible, and avoid cutting out anything
            #    episilon must be in [0,0.5)
            epsilon = min_len * 0.45
            i = 1
            while i < len(sounds):
                sounds[i][0]-=epsilon
                sounds[i][1]+=epsilon
                i += 1

            print("now, sounds: ", len(sounds))
            print(sounds[:int(len(sounds)/10)], "...")

            # save the text file for later use
            import csv

            # find filename
            filename = cur_file[len(args.input_dir):-4] #includes the previous directory's forward slash
            print(filename + "< THIS IS IT")
            with open(args.output_dir + filename + ".txt", "w", newline="") as f:
                writer = csv.writer(f)
                writer.writerows(sounds)
            continue
