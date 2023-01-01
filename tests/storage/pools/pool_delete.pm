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
use Utils::Rockstor_webui qw(navigate_to_pools);

sub run {

    my $raid_level = get_var('RAID_LEVEL');

    # Navigate to the main Pools page
    navigate_to_pools();

    # Click on the "delete" icon
    assert_and_click([
        'pools_page_click_delete',
        'pools_page_' . $raid_level . '_click_delete'],
        'timeout' => 30);

    # Click on "Confirm"
    assert_and_click('pools_page_confirm_delete', 'timeout' => 30);

    # Verify the pool is no longer listed in the table
    assert_screen('pools_page_root_only', 'timeout' => 60);

}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;