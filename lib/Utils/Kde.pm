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
  x11_start_program
);

=head1 Utils::Kde

C<Utils::Kde> - Library for interacting with the KDE Plasma desktop

=cut


=head2 launch_krunner

    launch_krunner();

Launch KRunner
Simplified from https://github.com/os-autoinst/os-autoinst-distri-opensuse/blob/a58baa00222ae7c99ded4a82589d0ba4cdf07496/lib/susedistribution.pm#L184-L234

=cut
sub launch_krunner {
    my ($program, $timeout) = @_;
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
    for (my $retries = 10; $retries > 0; $retries--) {
        # krunner may use auto-completion which sometimes gets confused by
        # too fast typing or looses characters because of the load caused (also
        # see below), especially in wayland.
        # See https://progress.opensuse.org/issues/18200 as well as
        # https://progress.opensuse.org/issues/35589
        type_string_very_slow substr $program, 0, 2;
        wait_still_screen(3);
        type_string_very_slow substr $program, 2;
        # Do multiple attempts
        # Make sure we have plasma suggestions as it may take time,
        # especially on boot or under load. Otherwise, try again
        if ($retries == 1) {
            assert_screen('desktop-runner-plasma-suggestions', $timeout);
        } elsif (!check_screen('desktop-runner-plasma-suggestions', $timeout)) {
            # Prepare for next attempt
            send_key 'esc';    # Escape from desktop-runner
            sleep(5);    # Leave some time for the system to recover
            send_key_until_needlematch 'krunner_started', $hotkey, 10, 10;
        } else {
            last;
        }
    }
}


=head2 x11_start_program

  x11_start_program($program [, timeout => $timeout ] [, no_wait => 0|1 ] [, valid => 0|1 [, target_match => $target_match ] [, match_timeout => $match_timeout ] [, match_no_wait => 0|1 ] [, match_typed => 0|1 ]]);

Simplified from: https://github.com/os-autoinst/os-autoinst-distri-opensuse/blob/a58baa00222ae7c99ded4a82589d0ba4cdf07496/lib/susedistribution.pm#L236-L318

Start the program C<$program> in an X11 session using the I<desktop-runner>
and looking for a target screen to match.

The timeout for C<check_screen> for I<desktop-runner> can be configured with
optional C<$timeout>. Specify C<no_wait> to skip the C<wait_still_screen>
after the typing of C<$program>. Overwrite C<valid> with a false value to exit
after I<desktop-runner> executed without checking for the result. C<valid=1>
is especially useful when the used I<desktop-runner> has an auto-completion
feature which can cause high load while typing potentially causing the
subsequent C<ret> to fail. By default C<x11_start_program> looks for a screen
tagged with the value of C<$program> with C<assert_screen> after executing the
command to launch C<$program>. The tag(s) can be customized with the parameter
C<$target_match>. C<$match_timeout> can be specified to configure the timeout
on that internal C<assert_screen>. Specify C<match_no_wait> to forward the
C<no_wait> option to the internal C<assert_screen>.
If user wants to assert that command was typed correctly in the I<desktop-runner>
she can pass needle tag using C<match_typed> parameter. This will check typed text
and retry once in case of typos or unexpected results (see poo#25972).

The combination of C<no_wait> with C<valid> and C<target_match> is the
preferred solution for the most efficient approach by saving time within
tests.

In case of KDE plasma krunner provides a suggestion list which can take a bit
of time to be computed therefore the logic is slightly different there, for
example longer waiting time, looking for the computed suggestions list before
accepting and a default timeout for the target match of 90 seconds versus just
using the default of C<assert_screen> itself. For other desktop environments
we keep the old check for the runner border.

This method is overwriting the base method in os-autoinst.
=cut

sub x11_start_program {
    my ($program, %args) = @_;
    my $timeout = $args{timeout};
    # enable valid option as default
    $args{valid} //= 1;
    $args{target_match} //= $program;
    $args{match_no_wait} //= 0;
    $args{match_timeout} //= 90;

    # Start desktop runner and type command there
    launch_krunner($program, $timeout);
    # With match_typed we check typed text and if doesn't match - retrying
    # Is required on KDE, as typing fails on KDE desktop runnner sometimes
    if ($args{match_typed} && !check_screen($args{match_typed}, 30)) {
        send_key 'esc';
        launch_krunner($program, $timeout);
    }
    wait_still_screen(3);
    save_screenshot;
    send_key 'ret';
    # As above especially krunner seems to take some time before disappearing
    # after 'ret' press we should wait in this case nevertheless
    wait_still_screen(3, similarity_level => 45) unless ($args{no_wait} || ($args{valid} && $args{target_match}));
    return unless $args{valid};
    my @target = ref $args{target_match} eq 'ARRAY' ? @{$args{target_match}} : $args{target_match};
    for (1 .. 3) {
        push @target, 'desktop-runner-plasma-suggestions';
        assert_screen([@target], $args{match_timeout}, no_wait => $args{match_no_wait});
        last unless match_has_tag('desktop-runner-border') || match_has_tag('desktop-runner-plasma-suggestions');
        wait_screen_change {
            send_key 'ret';
        };
    }
    # asserting program came up properly
    die "Did not find target needle for tag(s) '@target'" if match_has_tag('desktop-runner-border') || match_has_tag('desktop-runner-plasma-suggestions');
}


=head2 launch_konsole

    launch_konsole();

Launch Konsole using Krunner

=cut
sub launch_konsole {
    # Launch KRunner
    launch_krunner();
    # Start Konsole
    type_string_very_slow('konsole');
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
    type_string_very_slow($firefox_cmd);
    send_key('ret');

}

1;
