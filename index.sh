#!/usr/bin/env bash
__schoolkit_dir="$HOME/dev/schoolkit" # TODO: make sure this is right
__schoolkit_work_dir="$HOME/School"

function __schoolkit_get_real_name() {
	if [ -n "$SCHOOLKIT_REAL_NAME" ]; then
		echo "$SCHOOLKIT_REAL_NAME"
	elif [[ "Darwin" == "$(uname)" ]]; then
		dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p'
	else
		echo "Unable to detect real name! Please set \$SCHOOLKIT_REAL_NAME to your real-world name." >&2
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

function __schoolkit_select_note() {
	if [ -z "$1" ]; then
		echo "$(__schoolkit_notes_list | fzf)"
	else
		if [ "$1" == "latest" ]; then
			echo "$(__schoolkit_notes_list | head -1)"
		else
			echo "$1"
		fi
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

function __schoolkit_notes_edit() {
	filename="$(__schoolkit_select_note "$1")"
	# https://superuser.com/a/1002826
	if [[ "${@#-p}" = "$@" ]]; then
		__schoolkit_edit "$filename"
	else
		echo "$filename"
	fi
}

function __schoolkit_notes_cornell() {
	filename="$(__schoolkit_select_note "$1")"

	export SCHOOLKIT_REAL_NAME="$(__schoolkit_get_real_name)"

	dataurl="$(
		cat "$filename" |
		"$__schoolkit_dir/markdown-cornell/run.js" --data-uri
	)" &&
	osascript -e "tell application \"Safari\" to activate" &&
	osascript -e "tell application \"Safari\" to open location \"$dataurl\""
}

function __schoolkit_notes_mla() {
	filename="$(__schoolkit_select_note "$1")"
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
		__schoolkit_notes_list
	else
		case "$1" in
			list)
				__schoolkit_notes_list "${@:2}"
				;;
			new)
				__schoolkit_notes_new "${@:2}"
				;;
			edit)
				__schoolkit_notes_edit "${@:2}"
				;;
			cornell)
				__schoolkit_notes_cornell "${@:2}"
				;;
			mla)
				__schoolkit_notes_mla "${@:2}"
				;;
			help)
				echo "Usage:"
				echo "	$0 [class] list|new"
				echo "	$0 [class] edit|cornell|mla [latest|filename.md]"
				echo ""
				echo "[class] - change to the class's folder before executing the command"
				echo "list - list notes"
				echo "new ... - create a new note, using all remaining arguments as a name (spaces are OK!)"
				echo "edit [latest|./path/to/note.md]- edit a note in \$EDITOR (currently $EDITOR). Defaults to prompting you to select a note. Pass 'latest' as the first argument to edit the latest note."
				echo "cornell [latest|./path/to/note.md] - convert a markdown note to an HTML cornell note and open it in a browser. Defaults to prompting you to select a note. Pass 'latest' as the first argument to convert the latest note."
				echo "mla [latest|./path/to/note.md] - convert a markdown note to an MLA-formatted word document. Defaults to prompting you to select a note. Pass 'latest' as the first argument to convert the latest note."
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

