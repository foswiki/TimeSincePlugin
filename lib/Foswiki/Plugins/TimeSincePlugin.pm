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

package Foswiki::Plugins::TimeSincePlugin;

use strict;
use warnings;

our $VERSION = '4.10';
our $RELEASE = '16 Aug 2018';
our $NO_PREFS_IN_TOPIC = 1;
our $SHORTSUMMARY = 'Display time difference in a human readable way';
our $core;

sub initPlugin {

  Foswiki::Func::registerTagHandler(
    'TIMESINCE',
    sub {
      return getCore(shift)->handleTimeSince(@_);
    }
  );

  return 1;
}

sub getCore {
  unless (defined $core) {
    require Foswiki::Plugins::TimeSincePlugin::Core;
    $core = new Foswiki::Plugins::TimeSincePlugin::Core();
  }

  return $core;
}

sub finishPlugin {
  if (defined $core) {
    undef $core;
  }
}

1;
