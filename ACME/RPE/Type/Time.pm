package ACME::RPE::Type::Time;

use Moose;

has 'seconds' => (
    is => 'ro',
    isa => 'Num',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
