INCLUDED_SH=INCLUDED_08cdee0d61b0481094f82f2bf197ca6b; if [ ! -z ${!INCLUDED_SH} ]; then return 0; fi; eval ${INCLUDED_SH}=true

generate_uuid()
{
	cat /proc/sys/kernel/random/uuid
}

generate_partial_mac_address()
{
	num_bytes="$1"
    od -txC -An -N${num_bytes} /dev/urandom|tr \  :| cut -c 2-
}

fix_mac_address()
{
	mac="$1"
	first="$( echo "$mac" | cut -d: -f 1 )"
	first="$( printf '%02x' $(( 0x$first & 254 | 2)) )"
	last="$( echo "$mac" | cut -d: -f 2-6 )"
	echo "$first:$last"
}

generate_mac_address()
{
	fix_mac_address $(generate_partial_mac_address 6)
}

try_copy()
{
    src_file="$1"
    dst_file="$2"
    if [ ! -f "$dst_file" ]; then
        echo "copying $src_file to $dst_file"
        cp "$src_file" "$dst_file"
    fi
}

fill_placeholder()
{
    placeholder="PLACEHOLDER_$1"
    replacement="$(echo "$2" | sed 's/\//\\\//g')"
    sed "s/$placeholder/$replacement/g"
}

get_colon_separated_arguments()
{
    subargcount="$1"
    argument="$2"

    pattern="\\(.*\\)"
    replace="\1"
    if [ $subargcount -gt 1 ]; then
        for i in $(seq 2 $subargcount); do
            pattern="\\([^:]*\\):$pattern"
            replace="$replace \\$i"
        done
    fi

    sed_cmd="s/$pattern/$replace/g"
    params="$(echo "$argument"|sed "$sed_cmd")"
    if [ "$params" != "$argument" ]; then
        echo "$params"
    else
        echo
    fi
}

is_numeric()
{
	case "$1" in
	    ''|*[!0-9]*) return 1 ;;
	    *) return 0 ;;
	esac
}

ensure_directory_exists()
{
    directory="$1"
    if [ ! -d "$directory" ]; then
        >&2 echo "$directory: Expected directory not found"
        return 1
    fi
}