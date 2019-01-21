package ACME::RPE::Definitions;

use strict;
use warnings;
use Params::Validate;
use ACME::RPE::Type;

sub specific_impulse {
    validate(@_, {
         => {isa => 'ACME::RPE::Type::Mass'},
        final_mass => {isa => 'ACME::RPE::Type::Mass'},
        operating_duration => {isa => 'ACME::RPE::Type::Time'},
        specific_impulse => {isa => 'ACME::RPE::Type::SpecificImpulse'},
    });
}

sub rocket_mass_ratio {
    validate(@_, {
        initial_mass => {isa => 'ACME::RPE::Type::Mass'},
        final_mass => {isa => 'ACME::RPE::Type::Mass'},
        operating_duration => {isa => 'ACME::RPE::Type::Time'},
        specific_impulse => {isa => 'ACME::RPE::Type::SpecificImpulse'},
    });
}

1;
