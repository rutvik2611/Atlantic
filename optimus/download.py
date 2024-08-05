import os
import requests


def handle_download(url, filename):
    response = requests.get(url, stream=True)
    total_size = int(response.headers.get('content-length', 0))
    block_size = 1024
    progress_bar = []

    with open(filename, 'wb') as file:
        for data in response.iter_content(block_size):
            progress_bar.append(len(data))
            file.write(data)

    return {'status': 'success', 'filename': filename, 'size': total_size}
