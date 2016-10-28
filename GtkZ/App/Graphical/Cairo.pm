package GtkZ::App::Graphical::Cairo;

use Moose;
use GtkZ::App::Graphical;
use Glib qw( TRUE FALSE );
extends 'GtkZ::App::Graphical';

has 'layer_renderers' => (
    is => 'rw',
    isa => 'ArrayRef',
    builder => '_build_layer_renderers',
);

sub _build_layer_renderers {
    my ( $self ) = @_;
    return [
        sub {
            my ( $self, $cr ) = @_;
            $cr->save;
            $cr->rectangle( 50, 55, 100, 100 );
            $cr->set_line_width( 1 );
            $cr->set_source_rgb( 1, 0, 0 );
            $cr->stroke();
            $cr->restore;
        },
    ];
}

has 'surface' => (
    is  => 'rw',
    isa => 'Cairo::ImageSurface',
    documentation => "Cairo surface we are drawing to",
);

sub render {
    my ( $self, $widget, $event ) = @_;

    my ( $da_width, $da_height ) = $self->da->window->get_size;

    $self->da_width( $da_width );
    $self->da_height( $da_height );

    $self->do_cairo_drawing;
    my $cr = Gtk2::Gdk::Cairo::Context->create( $widget->window );
    $cr->set_source_surface( $self->surface(), 0, 0 );
    $cr->paint;
    return FALSE;
}

sub create_surface {
    my ( $self ) = @_;
    my $surface = Cairo::ImageSurface->create( 'argb32', $self->da_width, $self->da_height );
    $self->surface( $surface );
}

sub do_cairo_drawing {
    my ( $self ) = @_;

    $self->create_surface();

    my $surface = $self->surface();
    my $cr = Cairo::Context->create( $surface );

    my $layer_renderers = $self->layer_renderers;

    for my $renderer ( @{ $layer_renderers } ) {
        $renderer->( $self, $cr );
    }
}

sub button_clicked {}
sub motion_notify {}
sub scroll {}

__PACKAGE__->meta->make_immutable;
