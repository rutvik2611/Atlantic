document.getElementById('url').addEventListener('input', function() {
    var url = this.value;
    var filename = url.split('/').pop() || 'downloaded_file';
    document.getElementById('filename').value = filename;
});

document.getElementById('downloadForm').addEventListener('submit', function(event) {
    event.preventDefault();
    var form = event.target;
    var data = new FormData(form);
    var progressBar = document.getElementById('progressBar');

    fetch(form.action, {
        method: form.method,
        body: data
    }).then(response => response.json())
      .then(result => {
          // Simulate progress bar for demonstration purposes
          var progress = 0;
          var interval = setInterval(function() {
              progress += 10;
              progressBar.style.width = progress + '%';
              progressBar.innerHTML = progress + '%';
              if (progress >= 100) {
                  clearInterval(interval);
                  alert('Download Complete!');
              }
          }, 200);
      });
});
