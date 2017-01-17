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

has 'menu_def' => (
    is  => 'rw',
    isa => 'ArrayRef',
    required => 1,
    documentation => 'The menu definition',
);

has 'menu' => (
    is => 'rw',
    isa => 'GtkZ::Menu',
    lazy => 1,
    builder => '_build_menu',
);

sub _build_menu {
    my ( $self ) = @_;
    return GtkZ::Menu->new( {
        app      => $self->app,
        menu_def => $self->menu_def,
    } );
}

has 'window' => (
    is => 'rw',
    isa => 'Gtk2::Window',
    lazy => 1,
    builder => '_build_window',
);

sub _build_window {
    my ( $self ) = @_;

    my $window = Gtk2::Window->new( 'toplevel' );
    $window->set_default_size( $self->width, $self->height );

    my $menu = $self->menu;
    $self->main_vbox->pack_start( $menu->widget, FALSE, FALSE, 0 );

    $window->signal_connect( delete_event => sub { exit; } );
    $window->add( $self->main_vbox );

    return $window;
}

has 'main_vbox' => (
    is => 'rw',
    isa => 'Gtk2::VBox',
    lazy => 1,
    builder => '_build_main_vbox',
);

sub _build_main_vbox {
    my ( $self ) = @_;
    return Gtk2::VBox->new( FALSE, 0 );
}

sub add_main_area {
    my ( $self, $widget ) = @_;
    $self->main_vbox->pack_end( $widget, TRUE, TRUE, 0 );
}

sub run {
    my ( $self ) = @_;
    $self->window->show_all;
    Gtk2->main();
}

__PACKAGE__->meta->make_immutable;
