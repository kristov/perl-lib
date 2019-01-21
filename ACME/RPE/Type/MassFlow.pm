package ACME::RPE::Type::MassFlow;

use Moose;

use constant KG_TO_LB => 2.20462;

has 'kg_s' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_kg_s',
);

sub _build_kg_s {
    my ($self) = @_;
    return $self->lb_s / KG_TO_LB;
}

has 'lb_s' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_lb_s',
);

sub _build_lb_s {
    my ($self) = @_;
    return $self->kg_s * KG_TO_LB;
}

__PACKAGE__->meta->make_immutable;
