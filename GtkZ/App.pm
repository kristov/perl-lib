package GtkZ::App;

use Moose;
use GtkZ::Window;

has 'window' => (
    is => 'ro',
    isa => 'GtkZ::Window',
    lazy => 1,
    builder => '_build_window',
);

has 'dotfile' => (
    is => 'ro',
    isa => 'Str',
    required => 0,
);

has 'width' => (
    is => 'ro',
    isa => 'Int',
    default => 800,
    required => 0,
);

has 'height' => (
    is => 'ro',
    isa => 'Int',
    default => 600,
    required => 0,
);

has 'main_area' => (
    is => 'ro',
    isa => 'Gtk::Widget',
    required => 0,
);

sub _build_window {
    my ( $self ) = @_;
    my $window = GtkZ::Window->new( {
        app     => $self,
        width   => $self->width,
        height  => $self->height,
    } );
    if ( $self->main_area ) {
        $window->add_main_area( $self->main_area );
    }
    return $window;
};

sub run {
    my ( $self ) = @_;
    $self->load_dotfile if $self->dotfile;
    $self->window->run;
}

sub quit {
    my ( $self ) = @_;
    $self->save_dotfile if $self->dotfile;
    Gtk2->main_quit;
}

sub save_dotfile {
    my ( $self ) = @_;
}

sub load_dotfile {
    my ( $self ) = @_;
}

__PACKAGE__->meta->make_immutable;
