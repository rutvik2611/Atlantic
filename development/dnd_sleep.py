import time
import requests

# Define the maximum runtime in seconds (10 hours)
MAX_RUNTIME = 10 * 60 * 60  # 10 hours in seconds


def ping_url(url, interval=300):
    start_time = time.time()
    count = 0
    while True:
        count += 1
        try:
            response = requests.get(url)
            if response.status_code == 200:
                print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Ping #{count} successful: {response.status_code}")
            else:
                print(
                    f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Ping #{count} received unexpected status code: {response.status_code}")
        except requests.RequestException as e:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Ping #{count} - An error occurred: {e}")

        # Check if the maximum runtime has been exceeded
        elapsed_time = time.time() - start_time
        if elapsed_time > MAX_RUNTIME:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Maximum runtime exceeded. Exiting.")
            break

        time.sleep(interval)


if __name__ == "__main__":
    url_to_ping = "https://clipsync-o8nc.onrender.com/index"
    initial_interval = 10  # Interval in seconds for initial pings
    ping_interval = 300  # Interval in seconds for regular pings
    import bcrypt

    password = "admin".encode('utf-8')
    # Force bcrypt to generate the $2y$ hash instead of $2b$
    hashed = bcrypt.hashpw(password, bcrypt.gensalt(5)).replace(b"$2b$", b"$2y$")
    print(hashed.decode())

    print(
        f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Starting initial pings every {initial_interval} seconds until successful.")
    while True:
        try:
            response = requests.get(url_to_ping)
            if response.status_code == 200:
                print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Initial ping successful: {response.status_code}")
                break
            else:
                print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Received unexpected status code: {response.status_code}")
        except requests.RequestException as e:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] An error occurred: {e}")

        time.sleep(initial_interval)

    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Switching to regular pings every {ping_interval} seconds.")
    ping_url(url_to_ping, ping_interval)
