# Copyright (c) 2012-2022 RockStor, Inc. <http://rockstor.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


package Utils::Kde;

use base 'Exporter';
use Exporter;
use strict;
use warnings;
use testapi;
use utils;

our @EXPORT = qw(
  launch_krunner
  launch_konsole
  launch_firefox
);

=head1 Utils::Kde

C<Utils::Kde> - Library for interacting with the KDE Plasma desktop

=cut


=head2 launch_krunner

    launch_krunner();

Launch KRunner

=cut
sub launch_krunner {
    my $timeout = @_;
    $timeout //= 30;
    my $hotkey = 'alt-f2';

    send_key($hotkey);

    mouse_hide(1);
    if (!check_screen('krunner_started', $timeout)) {
        record_info('workaround', "Krunner does not show up on $hotkey, retrying up to ten times (see bsc#978027)");
        send_key 'esc';    # To avoid failing needle on missing 'alt' key - poo#20608
        send_key_until_needlematch('krunner_started', $hotkey, 10, 10);
    }
    wait_still_screen(2);
}


=head2 launch_konsole

    launch_konsole();

Launch Konsole using Krunner

=cut
sub launch_konsole {
    # Launch KRunner
    launch_krunner();
    # Start Konsole
    type_string_slow('konsole');
    send_key('ret');
    assert_screen('konsole_launched', 60);
}


=head2 launch_firefox

    launch_firefox();

Open Firefox to the given C<url> if given.

=cut
sub launch_firefox {
    my %args = @_;
    print "URL is: $args{url}\n";
    # Create firefox command
    my $firefox_cmd = 'firefox';
    if (defined($args{url})) {
        $firefox_cmd = $firefox_cmd . ' ' . $args{url};
    }
    print "firefox_cmd: $firefox_cmd\n";

    # Type it in
    type_string_slow($firefox_cmd);
    send_key('ret');

}

1;
