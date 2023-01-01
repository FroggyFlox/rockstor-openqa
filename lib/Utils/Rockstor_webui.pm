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


package Utils::Rockstor_webui;

use base 'Exporter';
use Exporter;
use strict;
use warnings;
use testapi;

our @EXPORT = qw(
  navigate_to_disks
  navigate_to_pools
  set_pool_name
);

=head1 Utils::Rockstor_webui

C<Utils::Rockstor_webui> - Library for navigating throughout Rockstor webUI

=cut


=head2 navigate_to_disks

    navigate_to_disks();

Click on the different menu items required to land on the main Pools page.

=cut
sub navigate_to_disks {
    # Click on the Storage > Pools menu items
    assert_and_click('menu_storage', 'timeout' => 30);
    assert_and_click('menu_storage_disks', 'timeout' => 30);
    # Verify the main Disks page layout
    assert_screen('disks_page', 'timeout' => 60);
}


=head2 navigate_to_pools

    navigate_to_pools();

Click on the different menu items required to land on the main Pools page.

=cut
sub navigate_to_pools {
    # Click on the Storage > Pools menu items
    assert_and_click('menu_storage', 'timeout' => 30);
    assert_and_click('menu_storage_pools', 'timeout' => 30);
    # Verify the main Pools page layout
    assert_screen('pools_page', 'timeout' => 60);
}


=head2 set_pool_name

    set_pool_name();

Create and set the POOL_NAME variable based on RAID_LEVEL (set in test_suite).

=cut
sub set_pool_name {
    my $raid_level = get_var('RAID_LEVEL');
    my $pool_name = $raid_level . '-pool';
    set_var('POOL_NAME', $pool_name);
    print('POOL_NAME was set as: ', $pool_name, '\n')
}

1;
