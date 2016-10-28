package GtkZ::App::Graphical;

use Moose;
use GtkZ::App;
use Glib qw( TRUE FALSE );
extends 'GtkZ::App';

has 'main_area' => (
    is => 'ro',
    isa => 'Gtk2::DrawingArea',
    lazy => 1,
    builder => '_build_main_area',
);

sub _build_main_area {
    my ( $self ) = @_;
    return $self->da;
}

has 'da' => (
    is  => 'rw',
    isa => 'Gtk2::DrawingArea',
    lazy => 1,
    builder => '_build_da',
    documentation => "GTK drawing area",
);

sub _build_da {
    my ( $self ) = @_;

    my $da = Gtk2::DrawingArea->new;

    $da->signal_connect( expose_event => sub { $self->render( @_ ) } );

    $da->set_events( [
        'key-press-mask',
        'exposure-mask',
        'leave-notify-mask',
        'button-press-mask',
        'pointer-motion-mask',
        'pointer-motion-hint-mask',
    ] );

    $da->signal_connect( 'button-press-event' => sub { return $self->button_clicked( @_ ) } );
    $da->signal_connect( 'motion-notify-event' => sub { $self->motion_notify( @_ ) } );
    $da->signal_connect( 'key-press-event' => sub { $self->keyhandler->handle( @_ ) } );
    $da->signal_connect( 'scroll-event' => sub { $self->scroll( @_ ) } );
    $da->can_focus( TRUE );
    $da->grab_focus;

    my $color = Gtk2::Gdk::Color->new( 0, 0, 0 );
    $da->modify_bg( 'normal', $color );

    return $da;
}

has 'da_width' => (
    is  => 'rw',
    isa => 'Int',
    required => 0,
);

has 'da_height' => (
    is  => 'rw',
    isa => 'Int',
    required => 0,
);

__PACKAGE__->meta->make_immutable;
