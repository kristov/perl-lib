package ACME::RPE::Type::SpecificImpulse;

use Moose;

has 'seconds' => (
    is => 'ro',
    isa => 'Num',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
