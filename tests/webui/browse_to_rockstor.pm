# Copyright (C) 2020-2021 SUSE LLC
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

# Here, we:
# - open Konsole
# - verify we have an IP address
# - open Firefox to brose to rockstor SUT


use base 'basetest';
use warnings;
use strict;
use testapi;
use lockapi;
use mmapi;

sub run {
    # Wait until the system has fully booted to desktop
    sleep(20);
    assert_screen('desktop_ready', 300);

    # We could use the ctl-alt-t shortcut to open Konsole
    # but this is somehow not working 100% of the time.
    # Let's thus use the UI instead.
    assert_and_click('kde_logo');
    assert_and_click('konsole');
    assert_screen('konsole_launched', 20);

    # wait until the parent (Rockstor) is ready
    mutex_wait 'rockstor_ready';

    # Test network connection
    enter_cmd('ip a');
    enter_cmd('ping -c 3 rockstorserver');
    enter_cmd('ping -c 3 10.0.2.101');

    # Start firefox and browse to rockstorserver
    enter_cmd('firefox https://rockstorserver');
    assert_and_click('security_exception');
    assert_and_click('click_advanced');
    # Navigate to the "Accept" button and press "Enter"
    send_key('tab');
    send_key('tab');
    send_key('tab');
    send_key('ret');
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
