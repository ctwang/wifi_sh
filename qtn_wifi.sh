#########################################################################
# Date		: 10/31/2012
# version number: 12
# 	Added dmesg -c commands so the commands can show output on a telnet window as well

#########################################################################
#List of Functions/Usage:
#wifi.sh cwwave [channel]   ./qtn_wifi_10.sh cwwave 36 
#wifi.sh cwwaveStop         ./qtn_wifi_10.sh cwwaveStop
#wifi.sh rxMode [channel] [bandwidth] [ctl sideband][ANTENNA][protocol] [mcs index/data rate] ./qtn_wifi_10.sh rxMode 36 40 1 4 n 2
#wifi.sh stopRxMode         ./qtn_wifi_10.sh stopRxMode 
#wifi.sh rxMeasure          ./qtn_wifi_11.sh rxMeasure
#wifi.sh rxPER [channel] [bandwidth] [ctl sideband][ANTENNA] [protocol] [mcs index/data rate] ./qtn_wifi_11.sh rxPER 38 40 -1 4 n 3 
#wifi.sh txMode [IPG][bpf][channel] [bandwidth] [ctl sideband] [ANTENNA][power] [protocol][mcs index/data rate] ./qtn_wifi_10.sh txMode 300 4000 36 40  0 15 16 n 4
#wifi.sh txModeStop         ./qtn_wifi_10.sh stopTxMode
#wifi.sh setPower [power]   ./qtn_wifi_10.sh  setPower 15
#qtn_wifi.sh getMode 
#qtn_wifi.sh setMode 3
#rxMode & rxPER
#channel, bandwidth, ctl sideband, ANTENNA, protocol, modulation
#txMode
#channel, bandwidth, ctl sideband, ANTENNA, power, protocol, modulation
#Antenna 127 all 4, 113 chain 1, 114 chain 2, 116 chain 3 120 chain 4.
#   111		ANT0	ANT1	ANT2	ANT3
#0	0000				
#1	0001	Enabled			
#2	0010		Enabled		
#3	0011	Enabled	Enabled		
#4	0100			Enabled	
#5	0101	Enabled		Enabled	
#6	0110		Enabled	Enabled	
#7	0111	Enabled	Enabled	Enabled	
#8	1000				Enabled
#9	1001	Enabled			Enabled
#10	1010		Enabled		Enabled
#11	1011	Enabled	Enabled		Enabled
#12	1100			Enabled	Enabled
#13	1101	Enabled		Enabled	Enabled
#14	1110		Enabled	Enabled	Enabled
#15	1111	Enabled	Enabled	Enabled	Enabled

########################################################################
#                               Functions                              #
########################################################################
#ORI
#=======================================================================
# Syntax: wifiTxMode [channel][bandwidth][ctl sideband][ANTENNA][power][protocol][mod index]
#
# Transmits a modulated signal on the selected channel
#
# Inputs:
# - channel: channel to use to transmit (for 40 MHz channels this is the center channel)
# - bandwidth: bandwidth to use, 20 or 40 MHz
# - ctl sideband: upper or lower control channel, 1 for upper, -1 for lower, 0 for 20 MHz channels
# - power: set Power of TxMode
# - protocol: 802.11 flavor:  a b g or n
# - modulation index: If 802.11n, which MCS index (0-15), if not 802.11n, enter data rate in Mbps
#=======================================================================
#NEW
#=======================================================================
# Syntax: wifiTxMode [IPG][bpf][channel][bandwidth][ctl sideband][antenna #][power][protocol][mod index]
#
# Transmits a modulated signal on the selected channel
#
# Inputs:
# - IPG: inter-packet gap, in microseconds
# - bpf: bytes per frame, in bytes, range from 100 to 4000
# - channel: channel to use to transmit (for 40 MHz channels this is the center)
# - bandwidth: bandwidth to use, 20 or 40 MHz
# - ctl sideband: upper or lower control channel, 1 for upper, -1 for lower, 0 for 20 MHz channels
# - antenna #: sets antennas to use,  
#    1111	Enabled	 Enabled	Enabled	        Enabled
#    0101     Disabled   Enabled	Disabled	Enabled
# - power: set Power of TxMode
# - protocol: 802.11 flavor:  a b g or n
# - modulation index: If 802.11n, which MCS index (0-15), if not 802.11n, enter data rate in Mbps
#=======================================================================


wifiTxMode()
{
    #Code goes here
    bpf=$(($2/100))
    channel=$3
    bandwidth=$4
    ctl_sideband=$5
    ant_base=112
    power=$7

    case "$5" in
    -1) writemem e6000000 3c87
    ;;
    1)  writemem e6000000 3c97
    ;;
    esac   
 
    antenna=$(($6+$ant_base))
       
    echo "antenna"
    echo $antenna
   

    if [ "$8" = "n" ]
    then
    protocol=1
    else
    protocol=0
    fi

    echo protocol
    echo $protocol  

    modulation_index=$9
    #disable the kernel to show errors at the console
    #echo 0 > /proc/sys/kernel/printk
    stop_test_packet
    set_test_mode $channel $antenna $modulation_index $bandwidth $bpf $protocol 0 
    
    echo "power "
    echo $power  
    set_tx_pow $power
    send_test_packet

    #restore
    #echo "15      4       1       7" > /proc/sys/kernel/printk	
    printInfo "TX Mode started on channel $channel with $bandwidth MHz BW"
}

#=======================================================================
# Syntax: wifiTxModeStop
# stopTxMode
# Stops transmission of modulated signal
#
# Inputs:
# - none
#=======================================================================
wifiTxModeStop()
{
    #Code goes here
    stop_test_packet
    printInfo "TX Mode stopped."
}


#=======================================================================
# Syntax: wifiRxMode [channel][bandwidth][ctl sideband][ANTENNA][protocol][mcs index]
#
# Sets chip to receive a modulated signal on the selected channel
#	Note: MAC address of wifi module for testing purposes is set to 00:11:22:33:44:55
#
# Inputs:
# - channel: channel to use to receive (for 40 MHz channels this is the center)
# - bandwidth: bandwidth to use, 20 or 40 MHz
# - ctl sideband: upper or lower control channel, 1 for upper, -1 for lower, 0 for 20 MHz channels
# - antenna #: sets antennas to use,  
#    1111	Enabled	 Enabled	Enabled	        Enabled
#    0101     Disabled   Enabled	Disabled	Enabled
# - protocol: 802.11 flavor:  a b g or n
# - mcs index: If 802.11n, which index (0-15), if not 802.11n, enter data rate in Mbps
#=======================================================================
wifiRxMode()
{
    #Code goes here
    #Do Nothing for wifiRxMode

    echo "calcmd 39 0 16 0 1 0 2 00 17 34 51 3 68 85 4 2" > /sys/devices/qdrv
    #Above command MUST be issued before issuing set_test_mode

    channel=$1
    bandwidth=$2
    ctl_sideband=$3

    case "$3" in
    -1) writemem e6000000 3c87
    ;;
    1)  writemem e6000000 3c97
    ;;
    esac   

 
    antenna=$(($4+112))    


    echo "antenna"
    echo $antenna
   
    
    if [ "$5" = "n" ]
    then
    protocol=1
    else
    protocol=0
    fi

    echo "protocol "
    echo $protocol  

    modulation_index=$6

    set_test_mode $channel $antenna $modulation_index $bandwidth 40 $protocol 0 
    printInfo "RX Mode started on channel $channel with $bandwidth MHz BW"
  
  
}

#=======================================================================
# Syntax: wifiRxModeStop 
#
# Stops reception of modulated signals
#
# Inputs:
# - none
#=======================================================================
wifiRxModeStop()
{
	#Code goes here
	#do nothing
	#read -p 'Press [Enter] key to continue...'
    printInfo "RX Mode stopped."
}




#=======================================================================
# Syntax: wifiRxPER [channel][bandwidth][ctl sideband][ANTENNA][protocol][mcs index]
#
# Sets chip to receive a modulated signal on the selected channel
#	Note: MAC address of wifi module for counting purposes is set to 00:11:22:33:44:55
#	Reports PER based on 10000 Packet input
#
# Inputs:
# - channel: channel to use to receive (for 40 MHz channels this is the center)
# - bandwidth: bandwidth to use, 20 or 40 MHz
# - ctl sideband: upper or lower control channel, 1 for upper, -1 for lower, 0 for 20 MHz channels
# - antenna #: sets antennas to use,  
#    1111	Enabled	 Enabled	Enabled	        Enabled
#    0101     Disabled   Enabled	Disabled	Enabled
# - protocol: 802.11 flavor:  a b g or n
# - mcs index: If 802.11n, which index (0-15), if not 802.11n, enter data rate in Mbps
#=======================================================================
wifiRxPER()
{
    #Code goes here

    channel=$1
    bandwidth=$2
    ctl_sideband=$3
    tx_count=10000    

    case "$3" in
    -1) writemem e6000000 3c87
    ;;
    1)  writemem e6000000 3c97
    ;;
    esac   

 
    antenna=$(($4+112)) 

    echo "antenna"
    echo $antenna


   
    if [ "$5" = "n" ]
    then
    protocol=1
    else
    protocol=0
    fi

    modulation_index=$6
    set_test_mode $channel $antenna $modulation_index $bandwidth 40 $protocol 0 
    printInfo "RX PER test started on channel $channel with $bandwidth MHz BW"

    echo 0 > /proc/sys/kernel/printk
    show_test_packet
    echo "15      4       1       7" > /proc/sys/kernel/printk

    dmesg -c > /dev/null

    printInfo "When test transmission is complete hit Enter"
    read input

    echo 0 > /proc/sys/kernel/printk
    show_test_packet
    echo "15      4       1       7" > /proc/sys/kernel/printk

    printInfo "RX PER test stopped."
    #rx_count=`dmesg -c | grep RF1_RX | sed 's/,//' | awk '{print $5}'`
    rx_count=$(dmesg | grep RF1_RX | sed 's/^.*RF1_RX = //g' | sed 's/,.*$//g')
    #echo "rx1_count is $rx_count"

    #echo "15      4       1       7" > /proc/sys/kernel/printk
     
    if [ $rx_count -gt 10000 ]
    then rx_count=10000 
    fi 
    echo "good packets are $rx_count" 
    
    err_count=$(($tx_count-$rx_count))
    echo "error packets are $err_count" 
    wholePct=$(($err_count/100))
    decimalPct=$(($err_count%100)) 
    #Calculation of PER goes here
    #PER based on Sequence of 10,000 packets sent
    printInfo "PER is $wholePct.$decimalPct%"  
    echo "PER is $wholePct.$decimalPct%"   
     
}




#=======================================================================
# Syntax: wifiSetPower [power]
#
# Sets the power level in dBm then prints the current power level
#
# Inputs:
# - power: Power level in dBm
#=======================================================================
wifiSetPower()
{
   #Code goes here
   set_tx_pow $1
   # Print current power
   printInfo "Set Power to $1"
}

#=======================================================================
# Syntax: wifiCWWave [channel]
#
# Transmits a CW waveform on the selected channel
#
# Inputs:
# - channel: channel to use to transmit the CW wave
#=======================================================================
wifiCWWave()
{
	#Code goes here
	# new send_CW_singal provide more parameter

	#set all 4 antenna
	set_test_mode 36 127 0 20 40 n 1 
	
	set_channel_by_calcmd $1

	writerfmem 0 135 0
	writerfmem 0 136 0
	writerfmem 0 144 fffff
	writerfmem 0 145 3fffff
	writerfmem 0 146 3fffff
	writerfmem 0 147 3fffff
	writerfmem 0 148 ffffff
	writerfmem 0 149 ffffff
	writerfmem 0 150 3fffff
	writerfmem 0 151 3fffff
	writerfmem 0 138 3fffff
	writerfmem 0 137 ffffff
	writemem e609048c 13b5
	writemem e6090490 3b

	#VERSION 10
	enable_txpow_cal 0
	set_tx_rf_gain 23 23 23 23
	writerfmem 0 175 0	
	writerfmem 0 176 0
	writerfmem 0 177 0
	writerfmem 0 178 0



	printInfo "CW test started on channel $1"
}

#=======================================================================
# Syntax: wifiCWWaveStop
#
# Stops the CW wave test
#=======================================================================
wifiCWWaveStop()
{
	#Code goes here
	
	writerfmem 0 135 00180380
	writerfmem 0 136 00180180
	writerfmem 0 144 0000c000
	writerfmem 0 145 0000c000
	writerfmem 0 146 0000c000
	writerfmem 0 147 0000c000
	writerfmem 0 148 00300030
	writerfmem 0 149 00300030
	writerfmem 0 150 00300030
	writerfmem 0 151 00300030
	writerfmem 0 138 00000000
	writerfmem 0 137 00000000
	writemem e609048c 000003b5
	writemem e6090490 00000008

	enable_txpow_cal 2
	
   	printInfo "CW test stopped"
}


#=======================================================================
# Syntax: wifiRxMeasure 
#
# Sets chip to measure RSSI on current channel
#
# Inputs:
# - none
#=======================================================================
wifiRxMeasure()
{
    echo "RxMeasure called."
    dmesg -c > /dev/null
	show_test_packet 1
	dmesg
	dmesg -c > /dev/null
	show_rssi_level
	dmesg
}

wifiGetMode()
{
 	Mode="$(call_qcsapi get_bootcfg_param calstate)"
	echo $Mode
	return $Mode
}

wifiSetMode()
{
	Mode=$1
	Current_mode="$(call_qcsapi get_bootcfg_param calstate)"
	echo $Mode
	echo $Current_mode
	if [ $Mode -ne $Current_mode ];then
		echo "changing mode, please wait for 1 minute"
		call_qcsapi update_bootcfg_param calstate $1
		reboot
	fi
}


########################################################################
#                              Utilities                               #
########################################################################

#=======================================================================
# Syntax: printInfo [message]
#
# Prints the information message given
#=======================================================================
printInfo()
{
   echo -e "[INFO]  $@"
}



########################################################################
#                             Script Main                              #
########################################################################

# Param 1 is the function, the rest the params for that function
func=$1
shift
params="$@"

# Call the function given
case $func in
   "txMode")    		wifiTxMode $params ;;
   "stopTxMode")		wifiTxModeStop $params ;;
   "rxPER") 			wifiRxPER $params ;;
   "rxMode") 			wifiRxMode $params ;;
   "stopRxMode")		wifiRxModeStop $params ;;
   "rxMeasure")			wifiRxMeasure $params ;;
   "cwwave")      		wifiCWWave $params ;;
   "cwwaveStop")  		wifiCWWaveStop $params ;;
   "setPower")    		wifiSetPower $params ;;
   "getMode")       		wifiGetMode $params ;;
   "setMode")       		wifiSetMode $params ;;

   *) ;;
esac


########################################################################
#                              Utilities                               #
########################################################################

# RF Test mode
# set_bootval calstate 1
# reboot
#
# Normal mode
# set_bootval calstate 3
# reboot
#

