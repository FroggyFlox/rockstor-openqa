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

# Here, we:
# - open Konsole
# - verify we have an IP address
# - open Firefox to browse to rockstor SUT


use base 'basetest';
use warnings;
use strict;
use testapi;
use Utils::Kde qw(launch_konsole launch_firefox x11_start_program);
use lockapi;
use mmapi;

sub run {
    # Wait until the system has fully booted to desktop
    sleep(20);
    assert_screen('desktop_ready', 600);

    # Start Konsole
    # launch_konsole();
    Utils::Kde::x11_start_program(
        'konsole',
        'valid' => 1,
        'no_wait' => 1,
        'match_typed' => 'konsole_command_typed',
        'target_match' => 'konsole_launched',
        'timeout' => 30
    );
    # Utils::Kde::x11_start_program('konsole', target_match => 'konsole_launched', 'timeout' => 30);
    # Wait until the parent (rockstorserver) is ready
    mutex_wait 'rockstor_ready';

    # Test network connection
    enter_cmd('ip a');
    enter_cmd('ping -c 3 rockstorserver');
    enter_cmd('ping -c 3 10.0.2.101');
    sleep(5); # sleep for 5 sec to allow visual inspection if needed
    enter_cmd('exit');

    # Start firefox and browse to rockstorserver
    # launch_firefox(url => 'https://rockstorserver');
    # Utils::Kde::x11_start_program('firefox https://rockstorserver', target_match => 'firefox_rockstorserver_url_typed', 'timeout' => 60);
    Utils::Kde::x11_start_program(
        'firefox https://rockstorserver',
        'valid' => 1,
        'no_wait' => 1,
        'match_typed' => 'firefox_url_typed',
        'target_match' => 'security_exception',
        'timeout' => 30
    );
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
