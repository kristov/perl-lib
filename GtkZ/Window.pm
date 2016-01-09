package GtkZ::Window;

use Moose;
use Gtk2 qw( -init );
use Glib qw( TRUE FALSE );

use GtkZ::Menu;

has 'app' => (
    is => 'rw',
    isa => 'GtkZ::App',
    required => 1,
);

has 'width' => (
    is => 'rw',
    isa => 'Int',
    default => 800,
);

has 'height' => (
    is => 'rw',
    isa => 'Int',
    default => 600,
);

has 'menu' => (
    is => 'rw',
    isa => 'GtkZ::Menu',
    lazy => 1,
    builder => '_build_menu',
);

has 'window' => (
    is => 'rw',
    isa => 'Gtk2::Window',
    lazy => 1,
    builder => '_build_window',
);

sub _build_menu {
    my ( $self ) = @_;
    return GtkZ::Menu->new( { app => $self->app } );
}

sub _build_window {
    my ( $self ) = @_;

    my $vbox = Gtk2::VBox->new( FALSE, 0 );

    my $window = Gtk2::Window->new( 'toplevel' );
    $window->set_default_size( $self->width, $self->height );

    my $menu = $self->menu;
    $vbox->pack_start( $menu->widget, FALSE, FALSE, 0 );

    $window->signal_connect( delete_event => sub { exit; } );
    $window->add( $vbox );

    return $window;
}

sub run {
    my ( $self ) = @_;
    $self->window->show_all;
    Gtk2->main();
}

__PACKAGE__->meta->make_immutable;
