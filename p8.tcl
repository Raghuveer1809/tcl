set ns [new Simulator]
set ntrace [open prog8.tr w]
$ns trace-all $ntrace
set namfile [open prog8.nam w]
$ns namtrace-all $namfile

proc finish {} {
global ns ntrace namfile
$ns flush-trace
exec nam prog8.nam &
close $ntrace
close $namfile


set tcpsize [exec grep "^r" prog8.tr | grep "tcp" | tail -n 1 | cut -d " " -f 6]
set numtcp [exec grep "^r" prog8.tr | grep -c "tcp"]
set tcptime 4.0
set udpsize [exec grep "^r" prog8.tr | grep "cbr" | tail -n 1 | cut -d " " -f 6]
set numudp [exec grep "^r" prog8.tr | grep -c "cbr"]
set udptime 4.0

puts "throughput of FTP"
puts "[ expr ($numtcp*$tcpsize)/$tcptime] bytes per sec"
puts "CBR"
puts "[ expr ($udpsize*$numudp)/$udptime] bytes per sec"
exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

set lan [$ns newLan "$n0 $n1 $n2 $n3 $n4 $n5 $n6 $n7" 5Mb 10ms LL Queue/DropTail Channel]


set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n7 $sink0
$ns connect $tcp0 $sink0


set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
set null0 [new Agent/Null]
$ns attach-agent $n5 $null0
$ns connect $udp0 $null0









$ns at 0.1 "$cbr0 start"
$ns at 2 "$ftp0 start"
$ns at 1.9 "$cbr0 stop"
$ns at 4.3 "$ftp0 stop"
$ns at 6 "finish"
$ns run

