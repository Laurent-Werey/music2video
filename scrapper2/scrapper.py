from __future__ import unicode_literals
import pandas as pd
import youtube_dl
import datetime
import json
import subprocess
import os
import io
import requests
from pytube import YouTube
from pydub import AudioSegment
from datetime import datetime, timedelta
from moviepy.editor import AudioFileClip

class Logger(object):
    def __init__(self):
        self.log = open("log.txt", "a")

    def debug(self, msg):
        print(msg)
        self.log.write(msg.strip())

    def warning(self, msg):
        self.log.write(msg.strip())

    def error(self, msg):
        self.log.write(msg.strip())

ydl_rootlink = "https://www.youtube.com/watch?v="



def download_specific_audio(link, start_time, end_time):

    output_filename = './audio-files/' + link + ".mp3"

    # Récupérer les informations de la vidéo
    yt = YouTube(ydl_rootlink + link)

    # Calculer la plage de bytes correspondante à l'horodatage de début et de fin spécifié
    bitrate = 128  # débit binaire de l'audio en kbps
    start_time = int(start_time * bitrate * 1000 / 8)
    end_time = int(end_time * bitrate * 1000 / 8)


    # Récupérer l'URL de la piste audio spécifique
    audio_url = yt.streams.filter(only_audio=True).first().url

    # Extraire la partie spécifique de l'audio en fonction de l'horodatage de début et de fin spécifié
    audio_request = requests.get(audio_url, stream=True, headers={"Range": f"bytes={start_time}-{end_time}"})

    # Charger les données binaires de l'audio dans un objet AudioSegment de pydub
    audio_segment = AudioSegment.from_file(io.BytesIO(audio_request.content), format="webm")

    # Convertir l'objet AudioSegment en format MP3
    audio_segment.export(output_filename, format="mp3")



def main():
    df = pd.read_csv(r'./musiccaps-public.csv')
    for index, row in df[['ytid', 'start_s', 'end_s']].iterrows():
        print(f'[{index}/{len(df.index)}]')
        download_specific_audio(row['ytid'], row['start_s'], row['end_s'])


if __name__ == "__main__":
    main()
#%%

#%%

#%%
