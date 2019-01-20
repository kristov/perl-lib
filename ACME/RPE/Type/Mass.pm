package ACME::RPE::Type::Mass;

use Moose;
use ACME::RPE::Type::Force;

use constant ACCL_GRAVITY_SEALEVEL => 9.8066;
use constant KG_TO_POUNDS => 2.20462;

has 'kilograms' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_kilograms',
);

sub _build_kilograms {
    my ($self) = @_;
    return $self->pounds / KG_TO_POUNDS;
}

has 'pounds' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_pounds',
);

sub _build_pounds {
    my ($self) = @_;
    return $self->kilograms * KG_TO_POUNDS;
}

sub force_sealevel {
    my ($self) = @_;
    return ACME::RPE::Type::Force->new({
        newtons => $self->kilograms * ACCL_GRAVITY_SEALEVEL,
    });
}

__PACKAGE__->meta->make_immutable;
