#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors!
. ~/.dwm/bar/themes/onedark

cpu() {
	cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

	printf "^c$black^ ^b$green^ CPU"
	printf "^c$white^ ^b$grey^ $cpu_val"
}

pkg_updates() {
	# updates=$(doas xbps-install -un | wc -l) # void
	updates=$(paru -Qua | wc -l)   # arch , needs paru
	# updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

	if [ -z "$updates" ]; then
		printf "^c$green^๏น  Fully Updated"
	else
		printf "^c$green^๏น  $updates"" updates"
	fi
}

battery() {
	CHARGE=$(cat /sys/class/power_supply/BAT0/capacity)
        STATUS=$(cat /sys/class/power_supply/BAT0/status)
    
        if [ "$STATUS" = "Charging" ]; then
          printf "๐ %s%% %s" "$CHARGE" "$STATUS"
        else
          printf "๐ %s%% %s" "$CHARGE" "$STATUS"
        fi
}

brightness() {
	printf "^c$red^ ๏  "
	printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
	printf "^c$blue^^b$black^ ๎ฆ "
	printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ ๓ฐคจ ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ ๓ฐคญ ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^ ^b$darkblue^ ๓ฑ "
        printf "$(date "+%a %d-%m-%y %T")"
}

weather() {
        get_weather="$(curl -s https://wttr.in/Vahrn\?format\=4)"
        printf "^c$blue^ $get_weather"
}

vpn() {
    VPN=$(nmcli -a | grep 'VPN connection' | sed -e 's/\( VPN connection\)*$//g')
    
    if [ "$VPN" = "" ]; then
        VPN=$(nmcli connection | grep 'wireguard' | sed 's/\s.*$//')
    fi

    if [ "$VPN" != "" ]; then
        if [ "$IDENTIFIER" = "unicode" ]; then
            printf "๐ %s" "$VPN"
        else
            printf "VPN %s" "$VPN"
        fi
    fi
}

sound() {
    VOL=$(pamixer --get-volume)
    STATE=$(pamixer --get-mute)
    
    if [ "$IDENTIFIER" = "unicode" ]; then
        if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
            printf "๐"
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "๐ %s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf "๐ %s%%" "$VOL"
        else
            printf "๐ %s%%" "$VOL"
        fi
    else
        if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
            printf "MUTE"
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "VOL %s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf "VOL %s%%" "$VOL"
        else
            printf "VOL %s%%" "$VOL"
        fi
    fi
}

while true; do

	[ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
	interval=$((interval + 1))

        sleep 1 && xsetroot -name "$updates $(weather) $(battery) $(sound) $(brightness) $(cpu) $(mem) $(vpn) $(wlan) $(clock)"
done
