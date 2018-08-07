##
## Put me in ~/.irssi/scripts, and then execute the following in irssi:
##
##       /load perl
##       /script load notify
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
use HTML::Entities;

$VERSION = "0.01";
%IRSSI = (
  authors     => 'Tomas Slusny',
  contact     => 'slusnucky@gmail.com',
  name        => 'notify.pl',
  description => 'TODO',
  license     => 'MIT',
  url         => 'https://github.com/deathbeam',
);

sub sanitize {
  my ($text) = @_;
  encode_entities($text,'\'<>&');
  my $apos = "&#39;";
  my $aposenc = "\&apos;";
  $text =~ s/$apos/$aposenc/g;
  $text =~ s/"/\\"/g;
  $text =~ s/\$/\\\$/g;
  $text =~ s/`/\\"/g;
  return $text;
}

sub notify_linux {
  my ($server, $summary, $message) = @_;
  my $cmd = "EXEC - notify-send" .
            " '" . $summary . "'" .
            " '" . $message . "'";
  $server->command($cmd);
}

sub notify_mac {
  my ($server, $summary, $message) = @_;
  $message =~ s/\\"/\\\\\\"/g;
  my $cmd = "EXEC -  osascript -e" .
          " 'display notification \\\"". $message . "\\\"" .
          " with title \\\"" . $summary . "\\\"" .
          " sound name \\\"Basso\\\"'\"";
  $server->command($cmd);
}

sub notify {
  my ($server, $summary, $message) = @_;

  # Make the message entity-safe
  $summary = sanitize($summary);
  $message = sanitize($message);

  my $cmd = "EXEC -" .
            " notify-send".
            " '" . $summary . "'" .
            " '" . $message . "'";
  $server->command($cmd);

  # Detect OS
  if ($^O eq "linux") {
    notify_linux($server, $summary, $message);
  }
  else {
    notify_mac($server, $summary, $message);
  }
}

sub print_text_notify {
  my ($dest, $text, $stripped) = @_;
  my $server = $dest->{server};

  return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
  my $sender = $stripped;
  $sender =~ s/^\<.([^\>]+)\>.+/\1/ ;
  $stripped =~ s/^\<.[^\>]+\>.// ;
  my $summary = $dest->{target} . ": " . $sender;
  notify($server, $summary, $stripped);
}

sub message_private_notify {
  my ($server, $msg, $nick, $address) = @_;

  return if (!$server);
  notify($server, "PM from ".$nick, $msg);
}

sub dcc_request_notify {
  my ($dcc, $sendaddr) = @_;
  my $server = $dcc->{server};

  return if (!$dcc);
  notify($server, "DCC ".$dcc->{type}." request", $dcc->{nick});
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
Irssi::signal_add('dcc request', 'dcc_request_notify');
