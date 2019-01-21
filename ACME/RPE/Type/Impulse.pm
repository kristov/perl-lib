package ACME::RPE::Type::Impulse;

use Moose;

use constant N_TO_LBF => 0.224809;

has 'N_s' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_N_s',
);

sub _build_N_s {
    my ($self) = @_;
    return $self->lbf_s / N_TO_LBF;
}

has 'lbf_s' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_lbf_s',
);

sub _build_lbf_s {
    my ($self) = @_;
    return $self->N_s * N_TO_LBF;
}

__PACKAGE__->meta->make_immutable;
