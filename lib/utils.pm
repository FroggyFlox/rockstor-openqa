# Copyright 2015-2022 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

package utils;

use base Exporter;
use Exporter;

use strict;
use warnings;
use testapi;
use Utils::Systemd qw(systemctl disable_and_stop_service);

our @EXPORT = qw(
    enter_cmd_slow
    enter_cmd_very_slow
    set_hostname
    type_string_slow
    type_string_very_slow
);

=head1 SYNOPSIS

Main file for all kind of functions
=cut

# USB kbd in raw mode is rather slow and QEMU only buffers 16 bytes, so
# we need to type very slowly to not lose keypresses.

# arbitrary slow typing speed for bootloader prompt when not yet scrolling
use constant SLOW_TYPING_SPEED => 13;

# type even slower towards the end to ensure no keybuffer overflow even
# when scrolling within the boot command line to prevent character
# mangling
use constant VERY_SLOW_TYPING_SPEED => 4;


=head2 type_string_slow

 type_string_slow($string);

Typing a string with C<SLOW_TYPING_SPEED> to avoid losing keys.

=cut

sub type_string_slow {
    my ($string) = @_;

    type_string $string, max_interval => SLOW_TYPING_SPEED;
}

=head2 type_string_very_slow

 type_string_very_slow($string);

Typing a string even slower with C<VERY_SLOW_TYPING_SPEED>.

The bootloader prompt line is very delicate with typing especially when
scrolling. We are typing very slow but this could still pose problems
when the worker host is utilized so better wait until the string is
displayed before continuing
For the special winter grub screen with moving penguins
C<wait_still_screen> does not work so we just revert to sleeping a bit
instead of waiting for a still screen which is never happening. Sleeping
for 3 seconds is less waste of time than waiting for the
C<wait_still_screen> to timeout, especially because C<wait_still_screen> is
also scaled by C<TIMEOUT_SCALE> which we do not need here.

=cut

sub type_string_very_slow {
    my ($string) = @_;

    type_string $string, max_interval => VERY_SLOW_TYPING_SPEED;

    if (get_var('WINTER_IS_THERE')) {
        sleep 3;
    }
    else {
        wait_still_screen(1, 3);
    }
}

=head2 enter_cmd_slow

 enter_cmd_slow($cmd);

Enter a command with C<SLOW_TYPING_SPEED> to avoid losing keys.

=cut

sub enter_cmd_slow {
    my ($cmd) = @_;

    enter_cmd $cmd, max_interval => SLOW_TYPING_SPEED;
}

=head2 enter_cmd_very_slow

 enter_cmd_very_slow($cmd);

Enter a command even slower with C<VERY_SLOW_TYPING_SPEED>. Compare to
C<type_string_very_slow>.

=cut

sub enter_cmd_very_slow {
    my ($cmd) = @_;

    enter_cmd $cmd, max_interval => VERY_SLOW_TYPING_SPEED;
    wait_still_screen(1, 3);
}




=head2 set_hostname

 set_hostname($hostname);

Setting hostname according input parameter using hostnamectl.
Calling I<reload-or-restart> to make sure that network stack will propogate
hostname into DHCP/DNS.

If you change hostname using C<hostnamectl set-hostname>, then C<hostname -f>
will fail with I<hostname: Name or service not known> also DHCP/DNS don't know
about the changed hostname, you need to send a new DHCP request to update
dynamic DNS yast2-network module does
C<NetworkService.ReloadOrRestart if Stage.normal || !Linuxrc.usessh>
if hostname is changed via C<yast2 lan>.

=cut

sub set_hostname {
    my ($hostname) = @_;
    assert_script_run "hostnamectl set-hostname $hostname";
    assert_script_run "hostnamectl status|grep $hostname";
    assert_script_run "uname -n|grep $hostname";
    systemctl 'status network.service';
    save_screenshot;
    assert_script_run "if systemctl -q is-active network.service; then systemctl reload-or-restart network.service; fi";
}

1;
