package TestApp::Controller::Books;

use strict;
use base qw/TestApp::Controller::Base/;

__PACKAGE__->config(
    'Controller::FormBuilder' => {
        method_name => 'formbuilder',
        stash_name  => 'form',
    },
);

sub edit : Local Form {
    my ( $self, $c, @args ) = @_;

    my $form = $self->formbuilder;

    if ( $form->submitted ) {
        if ( $form->validate ) {
            return $c->response->body("VALID FORM");
        }
        else {
            $c->stash->{ERROR} = "INVALID FORM";
            $form->field(
                name  => '_invalid_fields',
                type  => 'hidden',
                value => join( "|", grep { !$_->validate } $form->fields )
            );
        }
    }

    $form->field( name => 'email', validate => 'EMAIL' );
    $form->method('GET');
    $c->stash->{template} = "books/edit.tt";
}

sub edit_item : Local Form('/books/edit2') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = "books/edit.tt";
}

sub basic : Local Form {
    my ( $self, $c ) = @_;

    $c->stash->{template} = "books/basic.tt";
    my $form = $self->formbuilder;
    $form->field( name => 'email', validate => 'EMAIL' );
}

1;
