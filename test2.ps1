# Star Wars Theme
$starWarsTheme = @(
    440, 440, 440, 349, 523, 440, 349, 523, 440, 0, 659, 659, 659, 698, 523, 415,
    349, 523, 440, 0, 880, 440, 440, 880, 830, 784, 740, 698, 740, 698, 740, 440,
    659, 523, 587, 659, 698, 523, 415, 349, 523, 440, 0, 880, 440, 440, 880, 830,
    784, 740, 698, 740, 698, 740, 440, 659, 523, 587, 659, 698, 523, 415, 349
)

# Beep duration in milliseconds
$beepDuration = 250

# Function to play a note
function Play-Note($frequency) {
    [Console]::Beep($frequency, $beepDuration)
    Start-Sleep -Milliseconds $beepDuration
}

# Play the Star Wars theme
foreach ($note in $starWarsTheme) {
    Play-Note $note
}
