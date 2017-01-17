package GtkZ::Menu;

use Moose;

has 'app' => (
    is  => 'rw',
    isa => 'GtkZ::App',
    required => 1,
    documentation => 'The app context',
);

has 'widget' => (
    is  => 'rw',
    isa => 'Gtk2::MenuBar',
    lazy => 1,
    builder => '_build_widget',
    documentation => 'The widget to render',
);

has 'menu_def' => (
    is  => 'rw',
    isa => 'ArrayRef',
    required => 1,
    documentation => 'The menu definition',
);

sub _build_widget {
    my ( $self ) = @_;

    my $menu_bar = Gtk2::MenuBar->new();

    for my $menu_def ( @{ $self->menu_def } ) {

        my $top_menu_item = Gtk2::MenuItem->new( $menu_def->{label} );
        my $menu = Gtk2::Menu->new();

        for my $item ( @{ $menu_def->{items} } ) {
            my $menu_item = Gtk2::MenuItem->new( $item->{label} );
            $menu_item->signal_connect( 'activate' => sub { $item->{call}->( $self->app ) } );
            $menu->append( $menu_item );
        }

        $top_menu_item->set_submenu( $menu );
        $menu_bar->append( $top_menu_item );
    }

    return $menu_bar;
}

__PACKAGE__->meta->make_immutable;
