use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = '1.0';
%IRSSI = (
    authors     => 'draggy',
    contact     => 'none',
    name        => 'randomslap',
    description => 'Send a random slap to a foe;',
    license     => 'Public Domain',
);

sub randomslap {
my ($person, $server, $witem) = @_;
	
my @objects = (
"around a bit with a large trout",
"a rather large squid",
"a hydraulic pump",
"a book by Stephen King",
"a 10mbit network card",
"the Win2k Buglist",
"a five layer cake",
"Finland",
"KFC mega-bucket",
"morning",
"a 56k modem",
"Texas",
"a 747",
"Windows 95",
"a shoe",
"aids",
"Simpsons creator Matt Groening",
"google.com",
"coca-cola",
"1GB of RAM",
"an ethiopian",
"his portable DVD player",
"an ACER T180 MODEL Computer",
"a ban stick",
"a Smorgasbord",
"Tarantism",
"A Case of the Mondays",
"a Barracuda",
"a space monkey",
"his Random Slap Script",
"a mexican midget",
"the Mexican border",
"a rubber chicken",
"teh ban hammah",
"Bill Gates",
"Microsoft",
"HIV",
"STD'S",
"king leonidas",
"a Jewish rabbi. Double prawned.",
"Feudalism",
"the modern world",
"slaps.txt",
"a he/she",
"teh 1930's",
"a trojan",
"teh virus",
"teh internetz",
"johnny quest",
"hearts",
"the queen of England",
"crumpets",
"biscuits",
"tea",
"the Deathstar",
"a Star Destroyer",
"a Big Daddy",
"Mario",
"2MB of RAM",
"a 62\" HDTV",
"Navi",
"a gokart",
"Mt. Rushmore",
"python",
"java",
"a BIG Gulp"
);
my $obj = $objects[rand(@objects)];

$witem->command("me slaps $person with $obj.");
};

Irssi::command_bind("slap", \&randomslap);

