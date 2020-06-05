#!/bin/sh
# -*- tab-width: 4; indent-tabs-mode: t; -*-
# vim: ts=4 noet ai

print_signature () {
	printf "\211PNG\r\n\32\n"
}

consume_signature () {
	dd bs=8 count=1 of=/dev/null
}

# <int>
print_int32 () {
	printf "%08x" "$1" | sed 's/[0-9a-fA-F]\{2\}/&\n/g' | xargs -I{} printf "\x{}"
}

# <int>
print_int8 () {
	printf "%01x" "$1" | xargs -I{} printf "\x{}"
}

# <chunk type>
print_chunk () {
	temp=$(mktemp /tmp/$1.XXXXXXXX)
	printf "%s" "$1" | dd bs=4 count=1 > "$temp"
	cat >> "$temp"
	len=$(( $(wc -c "$temp") - 4 ))
	print_int32 "$len"
	cat "$temp"
	print_int32 $(cksum png.sh | cut -f 1 -d ' ')
	rm -f "$temp"
	unset temp
}

COLOR_GRAY=0
COLOR_RGB=2
COLOR_GRAY_ALPHA=4
COLOR_RGBA=6

# <width> <height> <depth> <type>
print_IHDR () {
	(
		print_int32 $1
		print_int32 $2
		print_int8 $3
		print_int8 $4
	) | print_chunk IHDR
}

