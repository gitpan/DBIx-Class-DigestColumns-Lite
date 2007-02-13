package DBIx::Class::DigestColumns::Lite;
use strict;
use warnings;
use base 'DBIx::Class';
use Digest::SHA1 ();

our $VERSION = 0.02;

sub digest_key {
    my ($self ,$val) = @_;

    return $self->_schema_digest_key unless $val;

    # make schema's class data.
    $self->mk_classdata( _schema_digest_key => '');
    return $self->_schema_digest_key($val);
}

sub digest_columns {
    my ($self, @columns) = @_;

    if (@columns) {
        for (@columns) {
            $self->throw_exception("column $_ doesn't exist")
                unless $self->has_column($_);
        }
        # make schema's class data.
        $self->mk_classdata( _schema_force_digest_columns => [] );
        $self->_schema_force_digest_columns(\@columns);
    }

    return $self->_schema_force_digest_columns;
}

sub digest {
    my ($self ,$val) = @_;
    return Digest::SHA1::sha1_hex(($val || '') . ($self->digest_key || ''));
}

sub store_column {
    my ( $self, $column, $value ) = @_;

    if ( { map { $_ => 1 } @{ $self->digest_columns || [] } }->{$column} ) {
        $value = $self->digest($value);
    }

    $self->next::method( $column, $value );
}

1;
__END__

=head1 NAME

DBIx::Class::DigestColumns::Lite -  easy to use Digest Value for DBIx::Class

=head1 SYNOPSIS

    package DBIC::Schema::User;
    use base 'DBIx::Class';
    __PACKAGE__->load_components(qw/DigestColumns::Lite PK::Auto Core/);
    ....
    __PACKAGE__->digest_columns(qw/passwd/);
    __PACKAGE__->digest_key('no not yet...');

=head1 DESCRIPTION

you can easy to use Digest Value.
This module use Digest::SHA1.

=head1 METHOD

=head2 digest_key

set digest key

=head2 digest_columns

set digest columns colum name.

=head2 store_column

auto set digest value.

=head2 digest

get digested value.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

Atsushi Kobayashi  C<< <atsushi __at__ mobilefactory.jp> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Atsushi Kobayashi C<< <atsushi __at__ mobilefactory.jp> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

