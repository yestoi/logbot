use strict;
use diagnostics;
use IO::Socket;

#configuration
my $nick = "logbot";
my $server = "irc.undergroundsystems.org";
my $channel = "#HaKT_Dev";
my $pass = "IAMAMADDAFAKKINGLOGBOT";
my $file = "logfile"; # This the base log file name. It'll be postfix'd with '-DD-MM'

my $sock = new IO::Socket::INET(PeerAddr => $server,
                                PeerPort => 6667,
                                Proto => 'tcp') or
                                        die "Put my socks on!";
print $sock "NICK $nick\r\n";
print $sock "USER $nick 8 * :$nick\r\n";

while (my $in = <$sock>) {
	if ($in =~ /266/) {	
        # Connected, go onto main loop
		last;
	}	
	elsif ($in =~ /433/) {  # Check if nick is in use
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
	chop $line;

    # Handle response to server. 
	if ($line =~ /^PING(.*)$/i) { 
		print $sock "PONG $1\r\n";
	}

    # Add output to buffer and handle user input
	else {
        # Only get user input, not server output
		if ($line =~ /^:(.+)!.*:(.+)$/) {
            my $user = $1;
            my $msg = $2;

            # Don't log redundant stuff
            if ($msg =~ /^Leaving$/ or $msg =~ /^$channel/ or $msg =~ /^Connection reset by peer/) {
                next;
            }
            else {
                push (@buffer, [$1, $2]);
            }

            # Commands (Always add '$line =~ /$channel/' at the end of your conditionals)
            if ($msg =~ /^!$nick/ && $line =~ /$channel/) {
                print $sock "PRIVMSG $user Logs: ftp://hakt:GiveMEmaLOG\@crazzy.se\r\n";
            }
            # Add more commands here. 
		}
	}

    # Write log file
    if (time-$old_time >= 60) { # Write file every 60 seconds
		my (undef, undef, undef, $day, $month) = localtime();
        open LOGFILE, ">>$file-$day-$month.txt" or die $!;

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
