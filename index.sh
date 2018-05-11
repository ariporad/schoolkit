#!/usr/bin/env bash
__schoolkit_dir="$HOME/dev/schoolkit" # TODO: make sure this is right
__schoolkit_work_dir="$HOME/School"

function __schoolkit_get_real_name() {
	if [ -z "$SCHOOLKIT_REAL_NAME" ]; then
		echo "$SCHOOLKIT_REAL_NAME"
	elif [[ "Darwin" == "$(uname)" ]]; then
		dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p'
	else
		echo "Unable to detect real name!" >&2
	fi
}

function __schoolkit_edit() {
	if [[ "${1: -3}" = ".md" ]] || [[ "${1: -4}" = ".txt" ]]; then
		if [ "${EDITOR: -3}" = "vim" ]; then
			$EDITOR "+Goyo" "$1"
		else
			$EDITOR "$1"
		fi
	else
		open "$1"
	fi
}

function __schoolkit_notes_new() {
	filename="$(date +%Y-%m-%d) $@.md"
	touch "$filename"
	__schoolkit_edit "$filename"
}

function __schoolkit_notes_list() {
	ls | sort -nr
}

function __schoolkit_notes_latest() {
	filename="$(__schoolkit_notes_list | head -1)"
	# https://superuser.com/a/1002826
	if [[ "${@#-p}" = "$@" ]]; then
		__schoolkit_edit "$filename"
	else
		echo "$filename"
	fi
}

function __schoolkit_notes_cornell() {
	latestnote="$(__schoolkit_notes_latest -p)"
	filename="${1:-$latestnote}"

	export SCHOOLKIT_REAL_NAME="$(__schoolkit_get_real_name)"

	dataurl="$(
		cat "$filename" |
		SCHOOLKIT_ NAME"$__schoolkit_dir/markdown-cornell/run.js" --data-uri
	)" &&
	osascript -e "tell application \"Safari\" to activate" &&
	osascript -e "tell application \"Safari\" to open location \"$dataurl\""
}

function __schoolkit_notes_mla() {
	latestnote="$(__schoolkit_notes_latest -p)"
	filename="${1:-$latestnote}"
	outputname="$(basename "$filename" ".md").docx"
	prettydate="$(date -jf "%Y-%m-%d" "$(echo "$filename" | cut -d' ' -f1)" "+%B %d, %Y")"

	pandoc \
		--from=markdown \
		--to=docx \
		-M "author=$(__schoolkit_get_real_name)" \
		-M "date=$prettydate" \
		--reference-doc="$__schoolkit_dir/mla-reference.docx" \
		-o "$outputname" \
		"$filename" &&
	open "$outputname"
}

function sn() {
	if [ $# -eq 0 ]; then
		__schoolkit_notes_list "${@:2}"
	else
		case "$1" in
			list)
				__schoolkit_notes_list "${@:2}"
				;;
			latest)
				__schoolkit_notes_latest "${@:2}"
				;;
			new)
				__schoolkit_notes_new "${@:2}"
				;;
			cornell)
				__schoolkit_notes_cornell "${@:2}"
				;;
			mla)
				__schoolkit_notes_mla "${@:2}"
				;;
			help)
				echo "Usage: $0 [class] ls|latest|mk|cornell|mla"
				echo ""
				echo "[class] - change to the class's folder before executing the command"
				echo "ls - list notes"
				echo "latest [-p] - __schoolkit_edit the most recent note (print the filename if -p)"
				echo "mk ... - create a new note, using all remaining arguments as a name (spaces are OK!)"
				echo "cornell [./path/to/note.md] - convert a markdown note to an HTML cornell note and open it in a browser. Defaults to the most recent note."
				echo "mla [./path/to/note.md] - convert a markdown note to an MLA-formatted word document. Defaults to the most recent note."
				;;
			*)
				cd "$__schoolkit_work_dir/$1"
				if [[ $# -gt 1 ]]; then
					sn "${@:2}"
				fi
				;;
		esac
	fi
}

