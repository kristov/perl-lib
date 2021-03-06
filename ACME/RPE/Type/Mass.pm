package ACME::RPE::Type::Mass;

use Moose;

use constant KG_TO_LB => 2.20462;

has 'kg' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_kg',
);

sub _build_kg {
    my ($self) = @_;
    return $self->lb / KG_TO_LB;
}

has 'lb' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_lb',
);

sub _build_lb {
    my ($self) = @_;
    return $self->kg * KG_TO_LB;
}

__PACKAGE__->meta->make_immutable;
