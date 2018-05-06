generate_uuid()
{
	cat /proc/sys/kernel/random/uuid
}

generate_partial_mac_address()
{
	num_bytes=$1
    od -txC -An -N${num_bytes} /dev/urandom|tr \  :| cut -c 2-
}

fix_mac_address()
{
	mac=$1
	first=$( echo "$mac" | cut -d: -f 1 )
	first=$( printf '%02x' $(( 0x$first & 254 | 2)) )
	last=$( echo "$mac" | cut -d: -f 2-6 )
	echo "$first:$last"
}

generate_mac_address()
{
	fix_mac_address $(generate_partial_mac_address 6)
}

try_copy() {
    src_file=$1
    dst_file=$2
    if [ ! -f "$dst_file" ]; then
        echo "copying $src_file to $dst_file"
        cp "$src_file" "$dst_file"
    fi
}

fill_placeholder() {
    placeholder="PLACEHOLDER_$1"
    replacement=$(echo "$2" | sed 's/\//\\\//g')
    sed "s/$placeholder/$replacement/g"
}
