package ACME::RPE::Type::Force;

use Moose;

use constant NEWTON_TO_POUNDFORCE => 0.224809;

has 'newtons' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_newtons',
);

sub _build_newtons {
    my ($self) = @_;
    return $self->pound_force / NEWTON_TO_POUNDFORCE;
}

has 'pound_force' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_pound_force',
);

sub _build_pound_force {
    my ($self) = @_;
    return $self->newtons * NEWTON_TO_POUNDFORCE;
}

__PACKAGE__->meta->make_immutable;
