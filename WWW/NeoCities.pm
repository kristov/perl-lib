package WWW::NeoCities;

use Moose;
use URI;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Request::Common qw();
use JSON qw();

our $VERSION = 0.1;

has username => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has sitename => (
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    builder => '_build_sitename',
);

sub _build_sitename {
    my ( $self ) = @_;
    return $self->username;
}

has password => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has scheme => (
    is => 'rw',
    isa => 'Str',
    default => 'https',
);

has domain => (
    is => 'rw',
    isa => 'Str',
    default => 'neocities.org',
);

has base_url => (
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    builder => '_build_base_url',
);

sub _build_base_url {
    my ( $self ) = @_;
    return sprintf( '%s://%s/api/', $self->scheme, $self->domain );
}

has json => (
    is => 'rw',
    isa => 'JSON',
    default => sub {
        return JSON->new()->utf8;
    },
);

has agent => (
    is => 'rw',
    isa => 'LWP::UserAgent',
    lazy => 1,
    builder => '_build_agent',
);

sub _build_agent {
    my ( $self ) = @_;
    my $ua = LWP::UserAgent->new();
    $ua->agent( 'perl-WWW::NeoCities/' . $VERSION );
    $ua->timeout( 10 );
    $ua->env_proxy;
    return $ua;
}

has site_info => (
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    builder => '_build_site_info',
);

sub _build_site_info {
    my ( $self ) = @_;
    return $self->_get_req( 'info', { sitename => $self->sitename } );
}

sub upload {
    my ( $self, $local_file, $remote_file ) = @_;
    return $self->_post_req( 'upload', $local_file, $remote_file );
}

sub _get_req {
    my ( $self, $action, $args ) = @_;

    $args ||= {};
    my $url = $self->base_url . $action;

    my $uri = URI->new( $self->base_url . $action );
    $uri->query_form( %{ $args } );

    my $request = HTTP::Request->new( GET => $uri->as_string );
    $request->authorization_basic( $self->username, $self->password );

    my $response = $self->agent->request( $request );
 
    if ($response->is_success) {
        my $data = $self->json->decode( $response->decoded_content );
        return $data;
    }
    else {
        die $response->status_line;
    }
}

sub _post_req {
    my ( $self, $action, $local_file, $remote_file ) = @_;

    my $url = $self->base_url . $action;

    my $uri = URI->new( $self->base_url . $action );

    my $request = HTTP::Request::Common::POST(
        $uri->as_string,
        Content_Type => 'form-data',
        Content      => [ "$remote_file" => [ $local_file ] ]
    );
    $request->authorization_basic( $self->username, $self->password );

    my $response = $self->agent->request( $request );
 
    if ($response->is_success) {
        my $data = $self->json->decode( $response->decoded_content );
        return $data;
    }
    else {
        die $response->status_line;
    }
}

1;
