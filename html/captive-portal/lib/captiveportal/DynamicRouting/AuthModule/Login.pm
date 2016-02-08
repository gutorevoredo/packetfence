package captiveportal::DynamicRouting::AuthModule::Login;

=head1 NAME

captiveportal::DynamicRouting::AuthModule::Login

=head1 DESCRIPTION

Login registration

=cut

use Moose;
extends 'captiveportal::DynamicRouting::AuthModule';
with 'captiveportal::DynamicRouting::FieldValidation';

use pf::util;
use pf::log;
use pf::config::util;
use List::MoreUtils qw(all);
use pf::auth_log;
use pf::person;
use pf::Authentication::constants;
use pf::web::guest;

has '+pid_field' => (default => sub { "username" });

has '+source_id' => (trigger => \&_build_sources );

has 'sources' => (is => 'rw', default => sub {[]});

around 'source' => sub {
    my ($orig, $self, $source) = @_;

    # We don't modify the setting behavior
    if($source){
        $self->$orig($source);
    }

    # If the source is set in the session we use it.
    if($self->session->{source}){
        return $self->session->{source};
    }
    else {
        $self->$orig();
    }
};

sub _build_sources {
    my ($self, $source_id, $previous) = @_; 
    my @sources;
    if($source_id eq "_PROFILE_SOURCES_"){
        @sources = ($self->app->profile->getInternalSources, $self->app->profile->getExclusiveSources);
    }
    else {
        my @source_ids = split(/\s*,\s*/, $source_id);
        @sources = map { pf::authentication::getAuthenticationSource($_) } @source_ids;
    }
    
    get_logger->debug(sub { use Data::Dumper ; "Module ".$self->id." is using sources : ".Dumper(\@sources) });
    $self->sources(\@sources);
}

sub required_fields_child {
    return ["username", "password"];
}

sub execute_child {
    my ($self) = @_;
    if($self->app->request->method eq "POST"){
        $self->authenticate();
    }
    else {
        $self->prompt_fields();
    }
};

sub authenticate {
    my ($self) = @_;
    my $username = $self->request_fields->{$self->pid_field};
    my $password = $self->request_fields->{password};
    
    my ($stripped_username, $realm) = strip_username($username);

    my @sources = get_user_sources($self->sources, $username, $realm);

    # If all sources use the stripped username, we strip it
    # Otherwise, we leave it as is
    my $use_stripped = all { isenabled($_->{stripped_user_name}) } @sources;
    if($use_stripped){
        $username = $stripped_username;
    }

    if ($self->app->reached_retry_limit("login_retries", $self->app->profile->{'_login_attempt_limit'})) {
        $self->app->flash->{error} = $GUEST::ERRORS{$GUEST::ERROR_MAX_RETRIES};
        $self->prompt_fields();
        return;
    }

    if(isenabled($self->app->profile->reuseDot1xCredentials)) {
        my $mac       = $self->current_mac;
        my $node_info = node_view($mac);
        $username = strip_username($node_info->{'last_dot1x_username'});
        get_logger->info("Reusing 802.1x credentials. Gave username ; $username");
    } else {
        # validate login and password
        my ( $return, $message, $source_id ) =
          pf::authentication::authenticate( { 'username' => $username, 'password' => $password, 'rule_class' => $Rules::AUTH }, @sources );
        if ( defined($return) && $return == 1 ) {
            pf::auth_log::record_auth($source_id, $self->current_mac, $username, $pf::auth_log::COMPLETED);
            # Logging USER/IP/MAC of the just-authenticated user
            get_logger->info("Successfully authenticated ".$username);
            $self->session->{source} = pf::authentication::getAuthenticationSource($source_id);
        } else {
            pf::auth_log::record_auth(join(',',map { $_->id } @sources), $self->current_mac, $username, $pf::auth_log::FAILED);
            $self->app->flash->{error} = $self->app->i18n($message);
            $self->prompt_fields();
            return;
        }
    }

    
    # not sure we should set the portal + source here...
    person_modify($self->current_mac, %{ $self->request_fields }, portal => $self->app->profile->getName, source => $self->source->id);
    $self->username($username);
    $self->done();
}

sub auth_source_params {
    my ($self) = @_;
    return {
        username => $self->app->session->{username},
    };
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

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

__PACKAGE__->meta->make_immutable;

1;
