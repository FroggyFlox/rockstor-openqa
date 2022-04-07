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

# Here, we simply test if we can successfully login at the console on first boot.


use base 'basetest';
use warnings;
use strict;
use testapi;
use lockapi;
use mmapi;

sub run {
    # Wait until the system has fully booted to desktop
    assert_screen('desktop_ready', 300);

    # # wait until the parent (Rockstor) is ready
    # mutex_wait 'rockstor_ready';
    #
    # Start firefox and connect to IP
    # x11_start_program('firefox https://10.0.2.15', valid => 0);
    send_key('ctrl-alt-t');
    assert_screen('xterm_ready');
    enter_cmd('firefox https://10.0.2.15');
    wait_still_screen(stilltime => 4, timeout => 30);
    assert_screen('security_exception', 60);
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
