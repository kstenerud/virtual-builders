INCLUDED_SH=INCLUDED_e7bec90191844db89743809e5cfb01f5; if [ ! -z ${!INCLUDED_SH} ]; then return 0; fi; eval ${INCLUDED_SH}=true

# Options
# =======
#
# Functions to facilitate option parsing and information in shell scripts.
# Note: This script sets -e and -u flags.
#
#
# By Karl Stenerud (kstenerud@gmail.com)
#
#
# Example usage:
#
#   #!/bin/bash
#   source options.sh
#   options_set_usage "$0 [options] <some arg>"
#   options_add_switch a number "Set the A value" 100
#   options_add_flag b "Set the B flag"
#   options_add_switch c name "Set the C value"
#   options_read_arguments $@
#   echo "a = $(options_get_value a), b = $(options_get_value b), c = $(options_get_value c)"
#   echo
#   options_d_print_current_values


# =======
# GLOBALS
# =======

OPTIONS_SH_SWITCH_CHARS=()
OPTIONS_SH_SWITCH_CODES=()
declare -A OPTIONS_SH_SWITCH_CHARS_BY_CODE
declare -A OPTIONS_SH_REQUIRED_ARGS
declare -A OPTIONS_SH_ARG_NAMES
declare -A OPTIONS_SH_DESCRIPTIONS
declare -A OPTIONS_SH_DEFAULT_VALUES
OPTIONS_SH_FREE_ARGUMENTS=()
OPTIONS_SH_USAGE=
OPTIONS_SH_HELP_FLAG=UNSET
OPTIONS_SH_HELP_DESCRIPTION=



# ===
# API
# ===


# Set the usage format
#
# @param usage The usage format
#
options_set_usage() {
    OPTIONS_SH_USAGE="$1"
}

# Add an option switch
#
# @param switch_char A single letter to use as a switch
# @param arg_name The name to print for the argument portion when printing the switch list
# @param description The description to display when printing the switch list
# @param required Mark the switch as "optional" or "required"
# @param variable_name The name of the variable that will hold the value of this switch
#
options_add_switch()
{
    switch_char="$1"
    switch_code="$(options_i_get_switch_code $switch_char)"
    arg_name="$2"
    description="$3"
    required="$4"
    set +u
    default_value="$5"

    OPTIONS_SH_SWITCH_CHARS+=($switch_char)
    OPTIONS_SH_SWITCH_CODES+=($switch_code)
    OPTIONS_SH_SWITCH_CHARS_BY_CODE[$switch_code]="$switch_char"
    OPTIONS_SH_ARG_NAMES[$switch_code]="$arg_name"
    OPTIONS_SH_DESCRIPTIONS[$switch_code]="$description"
    OPTIONS_SH_REQUIRED_ARGS[$switch_code]="$required"
    OPTIONS_SH_DEFAULT_VALUES[$switch_code]="$default_value"
    options_i_define_array OPTIONS_SH_CURRENT_VALUES_$switch_code
    set -u
}

# Add an option flag (holds true or false)
#
# @param switch_char A single letter to use as a switch
# @param description The description to display when printing the switch list
# @param required Mark the switch as "optional" or "required"
# @param variable_name The name of the variable that will hold the value of this switch
#
options_add_flag()
{
    switch_char="$1"
    description="$2"
    options_add_switch $switch_char "" "$description" optional false
}

# Read a list of arguments and fill out any options found.
# Also stores any free arguments (arguments after the switches).
# Exits with code 1 if argument reading fails.
#
# @param options-list A list of options (usually $@)
#
options_read_arguments()
{
    options_i_read_arguments $@ || true
    if [ $? -ne 0 ]; then
        echo
        options_print_usage
        exit 1
    fi
}

# Get the value for a switch. It will either be the value set by the user or the default value.
# If the switch has been set multiple times, this function will return the last value set.
#
# @param switch_char The switch whose value to get.
# @return The value
#
options_get_value()
{
    switch_char="$1"
    options_i_get_value $(options_i_get_switch_code $switch_char)
}

options_get_existing_directory()
{
    directory="$(options_get_value $@)"
    if [ ! -d "$directory" ]; then
        >&2 echo "$directory: Expected directory not found"
        return 1
    fi
    switch_char="$1"
    options_i_get_value $(options_i_get_switch_code $switch_char)
}

# Get all values for a switch.
#
# @param switch_char The switch whose values to get.
# @return The values
#
options_get_values()
{
    switch_char="$1"
    options_i_get_values $(options_i_get_switch_code $switch_char)
}


# Cuount the number of free arguments from the last call of options_read_arguments.
#
# @return The count of free arguments
#
options_count_free_arguments()
{
    set +u
    echo "${#OPTIONS_SH_FREE_ARGUMENTS[@]}"
    set -u
}

# Get any free arguments from the last call of options_read_arguments.
#
# @return The list of free arguments
#
options_get_free_arguments()
{
    echo "${OPTIONS_SH_FREE_ARGUMENTS[@]}"
}

# Get a free argument by index.
#
# @param index The argument index
# @return The list of free arguments
#
options_get_free_argument()
{
    index="$1"
    echo "${OPTIONS_SH_FREE_ARGUMENTS[$index]}"
}

options_set_help_flag_and_description()
{
    options_add_flag H "Print help"
    OPTIONS_SH_HELP_FLAG="$1"
    OPTIONS_SH_HELP_DESCRIPTION="$2"
}

# Print the help and usage screen
#
options_print_help()
{
    echo "$OPTIONS_SH_HELP_DESCRIPTION"
    echo
    options_print_usage
}

# Print the help and usage screen and then exit with the supplied return code.
#
# @param return_code The return code (0 for success, nonzero for error)
#
options_print_help_and_exit()
{
    return_code="$1"
    options_print_help
    exit $return_code
}

# Print the usage screen.
#
options_print_usage() {
    echo "Usage: $OPTIONS_SH_USAGE"
    options_i_get_switches | column -s ^ -t
}



# ===============
# DEBUG FUNCTIONS
# ===============


# DEBUG: Print all switch and free argument values.
#
# @return the switch and free argument values.
#
options_d_print_current_values()
{
    IFS=$'\n' switch_chars=($(sort <<<"${OPTIONS_SH_SWITCH_CHARS[*]}"))
    unset IFS
    echo "Switches:"
    for switch_char in ${switch_chars[@]}; do
        set +u
        echo "    $switch_char: $(options_get_value $switch_char)    all=($(options_get_values $switch_char))"
        set -u
    done

    echo "Args:"
    if [ ${#OPTIONS_SH_FREE_ARGUMENTS[@]} -gt 0 ]; then
        for arg in ${OPTIONS_SH_FREE_ARGUMENTS[@]}; do
            echo "    $arg"
        done
    fi
}



# ==================
# INTERNAL FUNCTIONS
# ==================


# Read a list of arguments and fill out any options found.
# Also stores any free arguments (arguments after the switches).
#
# @param options-list A list of options (usually $@)
# @return code 1 if reading arguments fails
#
options_i_read_arguments()
{
    while getopts "$(options_i_get_optstring)" switch_char $@; do
        if [ "$switch_char" == "?" ]; then
            return 1
        fi
        if [ "$switch_char" == "$OPTIONS_SH_HELP_FLAG" ]; then
            options_print_help_and_exit 0
        fi
        switch_code="$(options_i_get_switch_code $switch_char)"
        set +u
        if [ "X${OPTIONS_SH_DESCRIPTIONS[$switch_code]}" == "X" ]; then
            return 1
        fi
        set -u

        value=
        if [ "X${OPTIONS_SH_ARG_NAMES[$switch_code]}" == "X" ]; then
            value=true
        else
            value="$OPTARG"
        fi
        values_ref="$(options_i_get_current_values_ref $switch_code)"
        options_i_array_append $values_ref "$value"
    done
    shift $((OPTIND-1))
    set +u
    [ "$1" = "--" ] && shift
    while [ "X$1" != "X" ]; do
        OPTIONS_SH_FREE_ARGUMENTS+=($1)
        shift
    done
    set -u

    failure=false
    for switch_code in ${OPTIONS_SH_SWITCH_CODES[@]}; do
        values_ref="$(options_i_get_current_values_ref $switch_code)"
        if [ $(options_i_get_array_length $values_ref) -eq 0 ]; then
            options_i_array_append $values_ref "${OPTIONS_SH_DEFAULT_VALUES[$switch_code]}"
        fi
        if [ $(options_i_get_array_length $values_ref) -eq 0 ]; then
            if [ "${OPTIONS_SH_REQUIRED_ARGS[$switch_code]}" == required ]; then
                switch_char="${OPTIONS_SH_SWITCH_CHARS_BY_CODE[$switch_code]}"
                echo "-$switch_char is a required argument."
                failure=true
            fi
        fi
    done

    if [ $failure == true ]; then
        return 1
    fi
}

# Convert a switch character to a switch code
#
# @param switch_char The switch character
# @return The switch code
#
options_i_get_switch_code()
{
    switch_char="$1"
    echo -n "$switch_char" | hexdump -v -e '/1 "%02X"'
}

# Get a "current value" array's textual name to use as a reference.
#
# @param switch_code The command line switch code whose array to reference.
#
options_i_get_current_values_ref()
{
    switch_code="$1"
    echo "OPTIONS_SH_CURRENT_VALUES_$switch_code"
}

# Indirectly define an array.
#
# @param array_ref The textual name of the array
#
options_i_define_array()
{
    array_ref="$1"
    eval "$array_ref=()"
}

# Get an indirect array's length
#
# @param array_ref The textual name of the array
# @return The length of the array
#
options_i_get_array_length()
{
    array_ref="$1"
    local -a 'array_keys=("${!'"$array_ref"'[@]}")'
    echo ${#array_keys[*]}
}

# Append to an indirect array
#
# @param array_ref The textual name of the array
# @value The value to append
#
options_i_array_append()
{
    array_ref="$1"
    value="$2"
    eval "${array_ref}+=(\$value)"
}

# Get the last entry of an indirect array
#
# @param array_ref The textual name of the array
# @return The last entry in the array or an empty string if the array is empty
#
options_i_get_last_entry()
{
    array_ref="$1"
    count="$(options_i_get_array_length $array_ref)"
    if [ $count -gt 0 ]; then
        last_entry_ref=$array_ref"[$count - 1]"
        echo ${!last_entry_ref}
    else
        echo ""
    fi
}

# Get all entries in an indirect array
#
# @param array_ref The textual name of the array
# @return A list of entries
#
options_i_get_all_entries()
{
    array_ref="$1"
    all_ref=$array_ref"[@]"
    echo ${!all_ref}
}

# Get the value for a switch. It will either be the value set by the user or the default value.
# If the switch has been set multiple times, this function will return the last value set.
#
# @param switch_code The switch code whose value to get.
# @return The value
#
options_i_get_value()
{
    switch_code="$1"
    array_ref="$(options_i_get_current_values_ref $switch_code)"
    count="$(options_i_get_array_length $array_ref)"
    if [ count == "0" ]; then
        echo ""
        return
    fi

    options_i_get_last_entry $array_ref
}

# Get all values for a switch.
#
# @param switch_code The switch code whose values to get.
# @return The values
#
options_i_get_values()
{
    switch_code="$1"
    array_ref="$(options_i_get_current_values_ref $switch_code)"
    options_i_get_all_entries $array_ref
}

# Generate an option string for use in getopts.
#
# @return the option string
#
options_i_get_optstring()
{
    for switch_code in ${OPTIONS_SH_SWITCH_CODES[@]}; do
        switch_char="${OPTIONS_SH_SWITCH_CHARS_BY_CODE[$switch_code]}"
        printf "$switch_char"
        if [ "X${OPTIONS_SH_ARG_NAMES[$switch_code]}" != "X" ]; then
            printf ":"
        fi
    done
}

# Get a list of switches in a format suitable for the column command.
# The separator character is "^".
#
# @return The columnar data
#
options_i_get_switches()
{
    IFS=$'\n' switch_chars=($(sort <<<"${OPTIONS_SH_SWITCH_CHARS[*]}"))
    unset IFS
    for switch_char in ${switch_chars[@]}; do
        switch_code="$(options_i_get_switch_code $switch_char)"
        arg_name="${OPTIONS_SH_ARG_NAMES[$switch_code]}"
        if [ "X$arg_name" != "X" ]; then
            arg_name=" ${arg_name}"
        else
            arg_name=" "
        fi
        default_value="${OPTIONS_SH_DEFAULT_VALUES[$switch_code]}"
        if [ "X$default_value" != "X" ]; then
            default_value=" (default $default_value)"
        elif [ "${OPTIONS_SH_REQUIRED_ARGS[$switch_code]}" == required ]; then
            default_value=" [required]"
        fi
        if [ "X${OPTIONS_SH_ARG_NAMES[$switch_code]}" == "X" ]; then
            default_value=
        fi
        description="${OPTIONS_SH_DESCRIPTIONS[$switch_code]}"

        echo "-${switch_char}^${arg_name}^:^${description}^${default_value}"
    done
}
