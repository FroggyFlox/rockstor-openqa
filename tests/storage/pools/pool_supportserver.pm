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

# This module is used to navigate to the Storage > Pools page


use base 'basetest';
use warnings;
use strict;
use testapi;
use lockapi;
use mmapi;
use Utils::Rockstor_webui;

sub run {

    # Get pool name from ENV or set it if not yet defined
    set_pool_name unless get_var('POOL_NAME');
    my $pool_name = get_var('POOL_NAME');
    my $raid_level = get_var('RAID_LEVEL');

    # Clear the screen
    enter_cmd('clear');

    # Wait for mutex signal to populate pool
    ## Follow example in docs: https://open.qa/docs/#_test_synchronization_and_locking_api
    ## When a parent (this job) needs to wait for a child, let's fetch the child ID first
    ## and pass this to mutex_wait
    my $children = get_children();
    # We only have one child here
    my $child_id = (keys %$children)[0];
    # Pass this child_id to mutex_wait
    mutex_wait($raid_level . '_pool_created', $child_id);

    # Populate pool
    ## copy / to /mnt2/pool_name
    assert_script_run('ls -lah /mnt2/' . $pool_name . '/');
    assert_script_run('cp -R /{usr,var} /mnt2/' . $pool_name . '/.');

    # Send mutex ready signal
    mutex_create $raid_level . '_pool_populated';
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;
