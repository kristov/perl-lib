package HTTP::Tool::Comp;

use Moose;

has tool => (
    is => 'ro',
    isa => 'HTTP::Tool',
    required => 1,
);

has 'data_dir' => (
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    builder => '_build_data_dir',
);

sub _build_data_dir {
    my ( $self ) = @_;
    return $self->tool->directory_root . "/data";
}

sub render_comp {
    my ( $self, $comp ) = @_;

    my $file = $self->data_dir . "/$comp.json";

    my $json = $self->tool->load_json( $file );

    return $self->tool->render_template( $json->{template}, $json->{data} );
}

1;
