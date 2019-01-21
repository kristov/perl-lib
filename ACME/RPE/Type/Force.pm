package ACME::RPE::Type::Force;

use Moose;

use constant N_TO_LBF => 0.224809;

has 'N' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_N',
);

sub _build_N {
    my ($self) = @_;
    return $self->lbf / N_TO_LBF;
}

has 'lbf' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_lbf',
);

sub _build_lbf {
    my ($self) = @_;
    return $self->N * N_TO_LBF;
}

__PACKAGE__->meta->make_immutable;
