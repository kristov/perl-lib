package ACME::RPE::Type::Velocity;

use Moose;

use constant MS_TO_FTS => 3.28084;

has 'm_s' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_m_s',
);

sub _build_m_s {
    my ($self) = @_;
    return $self->ft_s / MS_TO_FTS;
}

has 'ft_s' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_ft_s',
);

sub _build_ft_s {
    my ($self) = @_;
    return $self->m_s * MS_TO_FTS;
}

__PACKAGE__->meta->make_immutable;
