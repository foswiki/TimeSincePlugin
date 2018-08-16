# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2005-2018 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

package Foswiki::Plugins::TimeSincePlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Time();
use Foswiki::Plugins ();
use POSIX;

use constant TRACE => 0;    # toggle me

sub new {
  my $class = shift;
  my $session = shift;

  $session ||= $Foswiki::Plugins::SESSION;

  my $this = bless({@_}, $class);

  $this->{_secondsOfUnit} = {
    years => 60 * 60 * 24 * 365.2425,
    months => 2628000,
    weeks => 60 * 60 * 24 * 7,
    days => 60 * 60 * 24,
    hours => 60 * 60,
    minutes => 60,
    seconds => 1,
  };

  return $this;
}

sub secondsOfUnit {
  my ($this, $unit) = @_;

  return $this->{_secondsOfUnit}{$unit};
}

sub handleTimeSince {
  my ($this, $params, $topic, $web) = @_;

  #writeDebug("handleTimeSince(" . $params->stringify() . ") called");

  my $theTopic = $params->{topic} || $topic;
  my $theWeb = $params->{web} || $web;
  my $theFrom = $params->{_DEFAULT} || $params->{from} || '';
  my $theTo = $params->{to} || '';
  my $theUnits = $params->{units};
  $theUnits = 2 unless defined $theUnits;

  my %doUnit = ();
  my $numUnits;

  if ($theUnits =~ /^(\d+)$/) {
    $numUnits = $1;

    $doUnit{seconds} = Foswiki::Func::isTrue($params->{seconds}, 0);
    $doUnit{minutes} = Foswiki::Func::isTrue($params->{minutes}, 1);
    $doUnit{hours} = Foswiki::Func::isTrue($params->{hours}, 1);
    $doUnit{days} = Foswiki::Func::isTrue($params->{days}, 1);
    $doUnit{weeks} = Foswiki::Func::isTrue($params->{weeks}, 1);
    $doUnit{months} = Foswiki::Func::isTrue($params->{months}, 1);
    $doUnit{years} = Foswiki::Func::isTrue($params->{years}, 1);
  } else {
    %doUnit = map { $_ => 1 } split(/\s*,\s*/, $theUnits);
  }

  my $theAbs = Foswiki::Func::isTrue($params->{abs}, 0);
  my $theNull = $params->{null} || 'about now';
  my $theFormat = $params->{format} || '$time';
  my $theNegFormat = $params->{negformat} || '- $time';

  if ($theFrom eq '') {
    ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);
    ($theFrom) = Foswiki::Func::getRevisionInfo($theWeb, $theTopic);
  } else {
    $theFrom =~ s/^\s+|\s+$//go;

    unless ($theFrom =~ /^\d+$/) {
      my $epoch = Foswiki::Time::parseTime($theFrom);
      return inlineError("ERROR: can't parse from=\"$theFrom\"") unless defined $epoch;
      $theFrom = $epoch;
    }
  }

  if ($theTo eq '') {
    $theTo = time();
  } else {

    $theTo =~ s/^\s+|\s+$//go;
    if ($theTo !~ /^\d+$/) {    # already epoch seconds
      my $epoch = Foswiki::Time::parseTime($theTo);
      return inlineError("ERROR: can't parse from=\"$theTo\"") unless defined $epoch;
      $theTo = $epoch;
    }
  }

  writeDebug("theFrom=$theFrom, theTo=$theTo");

  my $duration = $theTo - $theFrom;
  my $isNeg = $duration < 0;
  $duration = abs($duration) if $isNeg;

  # gather result string
  my @result = ();
  my $index = 0;
  foreach my $unit (qw(years months weeks days hours minutes seconds)) {
    next unless $doUnit{$unit};

    my $factor = $this->secondsOfUnit($unit);
    my $count = floor($duration / $factor);
    writeDebug("duration=$duration, unit=$unit, seconds in $unit=$factor, count=$count");

    if ($count) {
      my $label = $unit;
      $label =~ s/s$//go if $count == 1;    # TODO use maketext
      push @result, "$count $label";

      $index++;
      $duration -= $count * $factor;

      last if defined $numUnits && $index >= $numUnits;
    }
  }

  my $timeString = '';
  if (@result) {
    my $last = pop @result;

    $timeString = join(", ", @result) . ' and ' if @result;
    $timeString .= $last;
  }

  my $result;
  if ($timeString eq '') {
    $result = $theNull;
  } else {
    $result = $isNeg ? $theNegFormat : $theFormat;
    $result =~ s/\$time/$timeString/g;
  }

  return Foswiki::Func::decodeFormatTokens($result);
}

sub inlineError {
  return '<div class="foswikiAlert">' . $_[0] . '</div>';
}

sub writeDebug {
  print STDERR "TimeSincePlugin - $_[0]\n" if TRACE;
}

1;

