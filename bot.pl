use strict;
use diagnostics;
use IO::Socket;

#configuration
my $nick = "logbot";
my $server = "irc.undergroundsystems.org";
my $channel = "#HaKT_Dev";
my $pass = "IAMAMADDAFAKKINGLOGBOT";
my $file = "logfile"; #This the base log file name. It'll be postfix'd with '-MM-DD'

my $sock = new IO::Socket::INET(PeerAddr => $server,
                                PeerPort => 6667,
                                Proto => 'tcp') or
                                        die "Put my socks on!";
print $sock "NICK $nick\r\n";
print $sock "USER $nick 8 * :$nick\r\n";

while (my $in = <$sock>) {
	if ($in =~ /266/) {	
		last;
	}	
	elsif ($in =~ /433/) {  #Check if nick is in use
		die "Who dat?";
	}
}

print $sock "PRIVMSG NickServ IDENTIFY $pass\r\n";
sleep 3;
print $sock "JOIN $channel\r\n";

my $old_time = time;
my @buffer = (["", ""]);

while (my $line = <$sock>) 
{
    # Handle io with server
	chop $line;
	if ($line =~ /^PING(.*)$/i) {
		print $sock "PONG $1\r\n";
	}
	else {
		if ($line =~ /^:(.+)!.*:(.+)$/) {
            push (@buffer, [$1, $2]);
            #print "<" .$1. "> " . $2 . "\n";
		}
	}

    if (time-$old_time >= 60) { # 900 sec = 15 min
		my (undef, undef, undef, $day, $month) = localtime();
        open LOGFILE, ">>$file-$month-$day.txt" or die $!;

        my $i = 0;
		push (@buffer, []);
        while (my @row = @{$buffer[++$i]}) {
            print LOGFILE "<", $row[0], "> ", $row[1], "\n";
        }

        @buffer = (); 
		push (@buffer, []);
        $old_time = time;
        close LOGFILE;
    }
}
