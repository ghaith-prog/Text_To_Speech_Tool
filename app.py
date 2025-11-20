import os
import sys
import tempfile
import time
from typing import Optional
from urllib.parse import parse_qs, urlparse
from zipfile import ZipFile

import requests
import streamlit as st
from yt_dlp import YoutubeDL
from yt_dlp.utils import DownloadError, UnsupportedError

st.markdown('# 📝 **Transcriber App**')
bar = st.progress(0)

if sys.version_info < (3, 10):
    st.warning(
        "Cette application fonctionne mieux avec Python 3.10+. "
        "Merci d'envisager une mise à jour (avertissement de yt-dlp)."
    )

# Custom functions 

# Helpers
def normalize_youtube_url(url: str) -> Optional[str]:
    if not url:
        return None

    parsed = urlparse(url.strip())

    if parsed.netloc.endswith("youtu.be"):
        video_id = parsed.path.lstrip("/")
    elif "shorts" in parsed.path:
        video_id = parsed.path.rstrip("/").split("/")[-1]
    else:
        query = parse_qs(parsed.query)
        video_id = query.get("v", [None])[0]

    if not video_id:
        return None

    return f"https://www.youtube.com/watch?v={video_id}"


# 2. Retrieving audio file from YouTube video
def get_yt(URL, cookie_path: Optional[str] = None):
    if not URL:
        st.error('Merci de fournir une URL YouTube.')
        return None

    clean_url = normalize_youtube_url(URL)
    if not clean_url:
        st.error("URL YouTube invalide ou non prise en charge.")
        return None

    download_dir = os.getcwd()
    ydl_opts = {
        "format": "bestaudio/best",
        "noplaylist": True,
        "quiet": True,
        "no_warnings": True,
        "outtmpl": os.path.join(download_dir, "%(title)s.%(ext)s"),
        "retries": 3,
        "http_headers": {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/129.0.0.0 Safari/537.36"
            )
        },
    }

    if cookie_path:
        ydl_opts["cookiefile"] = cookie_path

    try:
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(clean_url, download=True)
            audio_path = ydl.prepare_filename(info)
    except (DownloadError, UnsupportedError) as err:
        st.error(
            "Téléchargement impossible. Merci de vérifier le lien "
            "ou de mettre à jour yt-dlp (pip install -U yt-dlp)."
        )
        st.text(err)
        return None

    bar.progress(10)
    st.session_state["audio_path"] = audio_path
    return audio_path

# 3. Upload YouTube audio file to AssemblyAI
def transcribe_yt(audio_path):
    if not audio_path or not os.path.exists(audio_path):
        st.error("Aucun fichier audio à transcrire.")
        return

    bar.progress(20)

    def read_file(filename, chunk_size=5242880):
        with open(filename, 'rb') as _file:
            while True:
                data = _file.read(chunk_size)
                if not data:
                    break
                yield data
    headers = {'authorization': api_key}
    response = requests.post(
        'https://api.assemblyai.com/v2/upload',
        headers=headers,
        data=read_file(audio_path)
    )
    audio_url = response.json()['upload_url']
    #st.info('3. YouTube audio file has been uploaded to AssemblyAI')
    bar.progress(30)

    # 4. Transcribe uploaded audio file
    endpoint = "https://api.assemblyai.com/v2/transcript"

    json = {
    "audio_url": audio_url
    }

    headers = {
        "authorization": api_key,
        "content-type": "application/json"
    }

    transcript_input_response = requests.post(endpoint, json=json, headers=headers)

    #st.info('4. Transcribing uploaded file')
    bar.progress(40)

    # 5. Extract transcript ID
    transcript_id = transcript_input_response.json()["id"]
    #st.info('5. Extract transcript ID')
    bar.progress(50)

    # 6. Retrieve transcription results
    endpoint = f"https://api.assemblyai.com/v2/transcript/{transcript_id}"
    headers = {
        "authorization": api_key,
    }
    transcript_output_response = requests.get(endpoint, headers=headers)
    #st.info('6. Retrieve transcription results')
    bar.progress(60)

    # Check if transcription is complete
    from time import sleep

    while transcript_output_response.json()['status'] != 'completed':
        sleep(5)
        st.warning('Transcription is processing ...')
        transcript_output_response = requests.get(endpoint, headers=headers)
    
    bar.progress(100)

    # 7. Print transcribed text
    st.header('Output')
    st.success(transcript_output_response.json()["text"])

    # 8. Save transcribed text to file

    # Save as TXT file
    with open('yt.txt', 'w', encoding='utf-8') as yt_txt:
        yt_txt.write(transcript_output_response.json()["text"])

    # Save as SRT file
    srt_endpoint = endpoint + "/srt"
    srt_response = requests.get(srt_endpoint, headers=headers)
    with open("yt.srt", "w") as _file:
        _file.write(srt_response.text)
    
    zip_file = ZipFile('transcription.zip', 'w')
    zip_file.write('yt.txt')
    zip_file.write('yt.srt')
    zip_file.close()
#####

# The App

# 1. Read API from text file
api_key = st.secrets['api_key']

#st.info('1. API is read ...')
st.warning('Awaiting URL input in the sidebar.')


# Sidebar
st.sidebar.header('Input parameter')


cookie_upload = st.sidebar.file_uploader("Fichier cookies.txt (optionnel)")

temp_cookie_path: Optional[str] = None
if cookie_upload is not None:
    temp_cookie = tempfile.NamedTemporaryFile(delete=False, suffix=".txt")
    temp_cookie.write(cookie_upload.read())
    temp_cookie.flush()
    temp_cookie_path = temp_cookie.name

with st.sidebar.form(key='my_form'):
    URL = st.text_input('Enter URL of YouTube video:')
    submit_button = st.form_submit_button(label='Go')

# Run custom functions if URL is entered 
if submit_button:
    audio_file = get_yt(URL, temp_cookie_path)
    if audio_file:
        transcribe_yt(audio_file)

        with open("transcription.zip", "rb") as zip_download:
            btn = st.download_button(
                label="Download ZIP",
                data=zip_download,
                file_name="transcription.zip",
                mime="application/zip"
            )
