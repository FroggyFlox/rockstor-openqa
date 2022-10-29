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

# Here, we simply open a konsole session with root privileges.


use base 'basetest';
use warnings;
use strict;
use testapi;
use Utils::Kde qw(launch_krunner launch_konsole x11_start_program);

sub run {
    # Wait until the system has fully booted to desktop
    assert_screen('desktop_ready', 600);
    sleep(10); # most likely unnecessary

    # Start Konsole
    # launch_konsole();
    # Utils::Kde::x11_start_program('konsole', target_match => 'konsole_launched', 'timeout' => 60);
    Utils::Kde::x11_start_program(
        'konsole',
        'valid' => 1,
        'no_wait' => 1,
        'match_typed' => 'konsole_command_typed',
        'target_match' => 'konsole_launched',
        'timeout' => 30
    );

    # Login as root
    enter_cmd('su');
    sleep(1);
    type_string('rockytest');
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
