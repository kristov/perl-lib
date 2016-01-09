package HTTP::Tool::Static;

use Moose;

has tool => (
    is => 'ro',
    isa => 'HTTP::Tool',
    required => 1,
);

has 'static_manifest' => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_static_manifest',
    documentation => 'Hashref of static libraries and their versions',
);

sub _build_static_manifest {
    my ( $self ) = @_;
    return $self->tool->load_json( $self->static_manifest_file );
}

has 'static_manifest_file' => (
    is => 'rw',
    isa => 'Str',
    default => '/opt/www/static/static_manifest.json',
);

1;
