from __future__ import unicode_literals
import pandas as pd
import youtube_dl
import datetime
import json
import subprocess
import os
import time

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

def dl_from_url(link, start_time, end_time):
    output_filename = './audio-files/' + link + '/' + link
    ydl_opts = {
        'format': 'bestaudio/best',
        'quiet':True,
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'mp3',
            'preferredquality': '192',
        }],
        # 'simulate': True,
        'outtmpl': output_filename + 'full.%(ext)s',
        'max_retries': 10,
        'retry-on-error': True,
        'logger': Logger()
    }
    try:
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            meta = ydl.extract_info(ydl_rootlink + link, download=True)
            subprocess.run(['ffmpeg', '-y', '-i', output_filename + 'full.mp3', '-ss', str(start_time), '-t', str(end_time - start_time), '-acodec', 'copy', output_filename + '.mp3'])
            os.remove(output_filename + 'full.mp3')
            with open(output_filename + '.json', 'w') as metadata_file:
                json.dump(meta, metadata_file, indent=4)
            return True
    except Exception as e:
        Logger().error(f"Error downloading video {link}: {e}")
        return False

def main():
    df = pd.read_csv(r'./musiccaps-public.csv')
    for index, row in df[['ytid', 'start_s', 'end_s']].iterrows():
        print(f'[{index}/{len(df.index)}]')
        output_filename = './audio-files/' + row['ytid'] + '/' + row['ytid']
        if not os.path.exists(output_filename + '.mp3'):
            count = 0
            while not dl_from_url(row['ytid'], row['start_s'], row['end_s']) and count < 5:
                time.sleep(5)
                print("Retrying...")
                count += 1
            if count >= 5:
                Logger().error(f"Failed to download video {row['ytid']}")
        else:
            print(f"File already exists for video {row['ytid']}, skipping...")

if __name__ == "__main__":
    main()
