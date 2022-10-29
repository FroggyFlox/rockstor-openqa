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

# Here, we initiate the client shutdown.


use base 'basetest';
use warnings;
use strict;
use testapi;
use Utils::Kde qw(launch_krunner);
use utils;

sub run {
    # Close Firefox (we assume it's opened and in focus)
    send_key('alt-f4');
    check_screen('firefox_confirm_close_tabs', 'timeout' => 10);
    if (match_has_tag('firefox_confirm_close_tabs')) {
        send_key('ret');
    }
    wait_still_screen();

    # # Launch Krunner
    # launch_krunner();
    #
    # # Enter the shutdown command
    # type_string_slow('shutdown');
    # send_key('ret');
    Utils::Kde::x11_start_program(
        'shutdown',
        'valid' => 0,
        'no_wait' => 1,
        'match_typed' => 'shutdown_command_typed',
        # 'target_match' => 'shutdown_screen',
        'timeout' => 30
    );

    # Confirm shutdown
    assert_screen('shutdown_screen');
    send_key('ret');

    # Assert shutdown
    assert_shutdown();
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
