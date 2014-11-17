# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2005-2014 Michael Daum http://michaeldaumconsulting.com
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

our $VERSION = '4.00';
our $RELEASE = '4.00';
our $NO_PREFS_IN_TOPIC = 1;
our $SHORTSUMMARY = 'Display time difference in a human readable way';
our $isInitialized;

###############################################################################
sub initPlugin {

  Foswiki::Func::registerTagHandler('TIMESINCE', \&handleTimeSince);
  return 1;
}

###############################################################################
sub handleTimeSince {

  unless ($isInitialized) {
    require Foswiki::Plugins::TimeSincePlugin::Core;
    $isInitialized = 1;
  }

  return Foswiki::Plugins::TimeSincePlugin::Core::handleTimeSince(@_);
}

1;
