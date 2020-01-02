# Override postinst and prerm to avoid to start/stop model service

systemd_postinst() {
OPTS=""

if [ -n "$D" ]; then
    OPTS="--root=$D"
fi

if type systemctl >/dev/null 2>/dev/null; then
	if [ -z "$D" ]; then
		systemctl daemon-reload
	fi

	for service in ${SYSTEMD_SERVICE_ESCAPED}; do
		case "${service}" in
		*@*)	;;
		*)
			systemctl $OPTS ${SYSTEMD_AUTO_ENABLE} "${service}";;
		esac
	done

	if [ -z "$D" -a "${SYSTEMD_AUTO_ENABLE}" = "enable" ]; then
		for service in ${SYSTEMD_SERVICE_ESCAPED}; do
			case "${service}" in
			*@*)	;;
			*)
				systemctl --no-block restart "${service}";;
			esac
		done
	fi
fi
}

systemd_prerm() {
OPTS=""

if [ -n "$D" ]; then
    OPTS="--root=$D"
fi

if type systemctl >/dev/null 2>/dev/null; then
	if [ -z "$D" ]; then
		for service in ${SYSTEMD_SERVICE_ESCAPED}; do
			case "${service}" in
			*@*)	;;
			*)
				systemctl stop "${service}";;
			esac
		done
	fi

	systemctl $OPTS disable ${SYSTEMD_SERVICE_ESCAPED}
fi
}

