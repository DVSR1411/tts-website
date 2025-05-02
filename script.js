const submitForm = (event) => {
    event.preventDefault();
    const data = { 
        text: document.getElementById('text').value 
    };
    fetch('MyAPI', {
        method: 'POST',
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        const resultDiv = document.getElementById('result');
        if (result && result.body) {
            resultDiv.innerHTML = `<p>Generated Audio:</p>
                <audio controls>
                    <source src="${result.body}" type="audio/mpeg">
                    Your browser does not support the audio element.
                </audio>`;
        } else {
            resultDiv.textContent = "Error: Could not generate audio.";
        }
    })
    .catch(() => alert("An error occurred while submitting the form"));
};