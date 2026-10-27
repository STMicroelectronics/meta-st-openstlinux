#!/bin/bash -

debug() {
	if [ "$DEBUG" ]; then
		echo ""
		echo "[DEBUG]: $*"
	fi
}

get_devices_id() {
	pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Device" and .info.props."media.class" == "Audio/Device")' | jq -r '.id'
}

get_device_number() {
	pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Device" and .info.props."media.class" == "Audio/Device")' | jq -r '.id' | wc -l
}
get_list_of_profile_of_a_device() {
	local id=$1
	local profile_searched=$2
	pw-dump | jq -r ".[] | select(.id == $id)" | jq -r '.info.params.EnumProfile'  | jq -r '.[] | [ .index, .name] | @tsv' | grep "$profile_searched" | wc -l
}
get_index_of_profile_for_a_device() {
	local id=$1
	local profile_searched=$2
	pw-dump | jq -r ".[] | select(.id == $id)" | jq -r '.info.params.EnumProfile' | jq -r '.[] | .index, .name'| paste --delimiters="#" - -| grep "$profile_searched\$" | cut -d'#' -f 1
}


search_sink_associated_to_device() {
	local device_id=$1
	DEVICE=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Device" and .info.props."media.class" == "Audio/Device")' | jq -r '.id,.info.props."device.description"' | paste --delimiters="#" - -|  grep "$device_id")

	sink_found=""
	old_IFS=$IFS
	IFS=$'\n'
	for d in $DEVICE;
	do
		# list device
		id=$(echo $d | cut -d'#' -f1)
		name=$(echo $d | cut -d'#' -f2)
		list_of_sink=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Audio/Sink")' | jq -r '.id,.info.props."node.description"'| paste --delimiters="#" - - )
		for s in $list_of_sink;
		do
			sink_id=$(echo $s | cut -d'#' -f1)
			sink_name=$(echo $s | cut -d'#' -f2)
			if $(echo $sink_name | grep -q "$name" > /dev/null) ; then
				sink_found=$sink_id
				break;
			fi
		done
		if [ -n "$sink_found" ]; then
			echo $sink_found
			break;
		fi
	done
	IFS=$old_IFS
}

DEFAULT_PROFILE="output:hdmi-stereo"

if [ $# -gt 0 ]; then
	if [ "$1" = -"-h" ]; then
		echo "$0 [output:analog-stereo|output:hdmi-stereo]"
	fi
	DEFAULT_PROFILE=$1
fi
debug "Force to set sink with $DEFAULT_PROFILE"

list_of_device=$(get_devices_id)

#find device which have "output:hdmi-stereo" profile available
for d in $list_of_device; do
	debug ">> $d $(get_list_of_profile_of_a_device $d $DEFAULT_PROFILE)"
	if [ $(get_list_of_profile_of_a_device $d $DEFAULT_PROFILE) -gt 0 ]; then
			# search sink associated
			sink_id=$(search_sink_associated_to_device $d)
			debug "wpctl set-default $sink_id"
			wpctl set-default $sink_id
			# force the profile to output:hdmi-stereo
			profile_id=$(get_index_of_profile_for_a_device $d $DEFAULT_PROFILE)
			debug "wpctl set-profile $d $profile_id"
			wpctl set-profile $d $profile_id
			break;
	fi
done
