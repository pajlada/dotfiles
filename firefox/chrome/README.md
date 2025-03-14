Custom user chrome for Firefox

Symlink in your profile dir

You can figure out your default profile dir by opening `~/.mozilla/firefox/profiles.ini` and looking for `Default=1`

Then symlink with:

```
cd ~/.mozilla/firefox/asdasdasd.default && ln -s ~/git/dotfiles/firefox/chrome .
```
