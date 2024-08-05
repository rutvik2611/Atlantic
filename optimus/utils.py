import os
from urllib.parse import urlparse

def generate_default_filename(url):
    parsed_url = urlparse(url)
    return os.path.basename(parsed_url.path) or 'downloaded_file'
