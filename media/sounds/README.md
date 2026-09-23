# AOL mail sound

`aol-youve-got-mail.wav` is the classic AOL “You've got mail!” recording,
downloaded from [The Sound Archive](https://www.thesoundarchive.com/email.asp).
The recording retains its original copyright.

The Darwin `mail` module installs it in the primary user's `~/Library/Sounds`
and selects it as Apple Mail's new-message sound during `darwin-rebuild switch`.
Quit Mail before applying and reopen it afterward.

If macOS blocks access to Mail preferences, select **AOL You've Got Mail** once
in **Mail → Settings → General → New message sound**. Mail must be running and
receiving messages; this does not change webmail or other mail applications.

Preview from the repository: `afplay media/sounds/aol-youve-got-mail.wav`.
