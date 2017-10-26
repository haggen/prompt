<p align="center"><img alt="Prompt" src="screenshot.png"></p>

---

This is my custom zsh prompt.

- No framework dependency (oh-my-zsh, prezto, etc).
- Minimalistic but fast and a small profile.
- Displays elapsed time after command execution.
- Displays cues when inside a Git repository.

To install simply source it in your rc script:

```shell
$ git clone https://github.com/haggen/prompt.git ~/.prompt
$ echo "source ~/.prompt/prompt.sh" >> .zshrc
```

If you use a framework like oh-my-zsh remember to disable any prompts theme you have active.
