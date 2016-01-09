package GtkZ::App;

use Moose;
use GtkZ::Window;

has 'window' => (
    is => 'rw',
    isa => 'GtkZ::Window',
    lazy => 1,
    builder => '_build_window',
);

sub _build_window {
    my ( $self ) = @_;
    return GtkZ::Window->new( {
        app     => $self,
        width   => 800,
        height  => 600,
    } );
};

sub run {
    my ( $self ) = @_;
    $self->window->run;
}

sub quit {
    my ( $self ) = @_;
    Gtk2->main_quit;
}

__PACKAGE__->meta->make_immutable;
