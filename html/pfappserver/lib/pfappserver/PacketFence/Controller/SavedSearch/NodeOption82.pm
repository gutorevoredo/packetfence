package pfappserver::PacketFence::Controller::SavedSearch::NodeOption82;

=head1 NAME

pfappserver::PacketFence::Controller::SavedSearch::NodeOption82 - Saved Search for NodeOption82

=cut

=head1 DESCRIPTION

NodeOption82

=cut

use strict;
use warnings;
use Moose;
use HTTP::Status qw(:constants is_error is_success);

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object dispatcher from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'savedsearch/node', CaptureArgs => 1 },
        view   => { AdminRole => 'AUDITING_READ' },
        list   => { AdminRole => 'AUDITING_READ' },
        create => { AdminRole => 'AUDITING_READ' },
        update => { AdminRole => 'AUDITING_READ' },
        remove => { AdminRole => 'AUDITING_READ' },
    },
    action_args => {
        '*' => { model => 'SavedSearch::NodeOption82', form => 'SavedSearch'}
    }
);

=head1 METHODS

=head2 before create

=cut

before 'create' => sub {
    my ( $self, $c ) = @_;
    $c->request->parameters->{pid} = $c->user->id;
};


__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

