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
  url         => 'https://nondev.io',
);

Irssi::settings_add_str('notify', 'notify_remote', '');
Irssi::settings_add_str('notify', 'notify_debug', '');

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
  my ($server, $nodebugstr, $remote, $summary, $message) = @_;
  my $cmd = "EXEC " . $nodebugstr . "ssh -q " . $remote . " \"".
            " notify-send".
            " -i gtk-dialog-info -t 5000" .
            " '" . $summary . "'" .
            " '" . $message . "'";
  $server->command($cmd);
}

sub notify_mac {
  my ($server, $nodebugstr, $remote, $summary, $message) = @_;
  $message =~ s/\\"/\\\\\\"/g;
  my $cmd = "EXEC " . $nodebugstr . "ssh -q " . $remote . " \"".
          " osascript -e".
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

  my $debug = Irssi::settings_get_str('notify_debug');
  my $nodebugstr = '- ';
  if ($debug ne '') {
    $nodebugstr = '';
  }
  my $cmd = "EXEC " . $nodebugstr .
            " notify-send".
            " -i gtk-dialog-info -t 5000" .
            " '" . $summary . "'" .
            " '" . $message . "'";
  $server->command($cmd);

  my $remote = Irssi::settings_get_str('notify_remote');
  if ($remote ne '') {
    if (substr($remote, length($remote)-1) ne 'M') {
      notify_linux($server, $nodebugstr, $remote, $summary, $message);
    }
    else {
      $remote = substr($remote, 0, length($remote)-1);
      notify_mac($server, $nodebugstr, $remote, $summary, $message);
    }
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
