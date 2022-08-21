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
  set_hostname
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
