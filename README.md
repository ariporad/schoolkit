# Schoolkit
## A Simple Toolkit for Managing Schoolwork

I wanted an easy way to manage my schoolwork, so I wrote some bash scripts. These are them. They're very heavily customized to the way that I work, and as such are not guaranteed to work (or keep working) for anyone else. They may break at any time. You have been warned.

## Installation

Schoolkit requires [`fzf`](https://github.com/junegunn/fzf), so please install it first. Schoolkit will probably explode on non-macOS devices.

```bash
git clone https://github.com/ariporad/schoolkit.git ~/.schoolkit
echo "[ -f ~/.schoolkit/index.sh ] && source ~/.schoolkit/index.sh" >> ~/.zshrc
```

## Usage

Schoolkit expects schoolwork to be stored in `~/School/SUBJECT`. Within that folder, files are named as `YYYY-MM-DD Very Interesting Title.ext`, where `ext` is usually `md`.

The primary schoolkit command is (currently) `sn`, which stands for 'school notes'. Usage:

```bash
sn history new World War II # cd to ~/School/history and create + edit "YYYY-MM-DD World War II.md"
sn new Adverbs # the subject can be ommited if you're already in the right dir
sn science list # list notes
sn edit latest # edit the latest note
sn english edit # prompt to select a note to edit
sn english edit "2018-04-23 Grammar.md" # edit a specific note
sn cornell [latest|note.md] # render the note to HTML Cornell notes (same filename behevior as `sn edit`, see below)
sn mla [latest|note.md] # render the note to an MLA-formatted(ish) word document (same filename behevior as `sn edit`, see below)
```

## Cornell Notes

I have to/like to take Cornell notes frequently, but I want to take notes in markdown. To solve this problem, schoolkit has a (somewhat hacky) way to render markdown notes to HTML Cornell notes.

Here's the format in markdown:

```markdown
#### Class, Teacher

# Title Goes Here

This is a summary of the thing which I'm taking notes on. Blah Blah Blah.

* What is the answer to life, the universe, and everything?
	* 42
	* We know this because of the mice
* What is the ultimate question?
	* What do you get when you multiply six by nine?
```

Here's the output (your name and the date are added automagically):

![Cornell Notes Example Output](cornell_example.png)

## MLA Formatting

I like to write things in markdown for many reasons, but the academic world really likes things to be turned in with the MLA format. To facilitate this, schoolkit contains a method to convert markdown to something very close to MLA. (It doesn't have the teacher's name or the class in the header, but is otherwise correct.)

## Caviats
* Schoolkit occasionally needs to know your 'real' name (ex. `Ari Porad`, not `ariporad`). It tries to guess, but might not always be able to. If it can't figure yours out (or it gets it wrong), set `$SCHOOLKIT_REAL_NAME` to your name, and everything will work. (A `~/.bashrc` or `~/.zshrc` would be a good place to put this.)

## License
[MIT License](https://ariporad.mit-license.org)
