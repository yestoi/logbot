use strict;
use IO::Socket;

#Do config lookup
my $nick = "logbot";
my $server = "irc.undergroundsystems.org";
my $channel = "#underground_systems";

my $sock = new IO::Socket::INET(PeerAddr => $server,
								PeerPort => 6667,
								Proto => 'tcp') or
									die "Put my socks on!";
print $sock "NICK $nick\r\n";
print $sock "USER $nick 8 * :logbot\r\n";

while (my $in = <$sock>) {
	if ($in =~ /004/) {	
		last;
	}	
	elsif ($in =~ /433/) {  #Check if nick is in use
		die "Who dat?"
	}
}

print $sock "JOIN $channel\r\n";

while (my $lines = <$sock>) {
	chop $lines;
	if ($lines =~ /^PING(.*)$/i) {
		print $sock "PONG $1\r\n";
	}
	else {
		print "$lines\n"
	}
}
