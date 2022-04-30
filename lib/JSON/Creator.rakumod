use JSON::Fast;
unit class JSON::Creator:ver<0.0.1>:auth<cpan:fco>;

has $.values = Nil;

class Creator {
    has $!values is built handles <AT-POS AT-KEY>;

    method !values { $!values }
    method ^values($obj) { $obj!values }

    multi method FALLBACK(::?CLASS:U: Str $name) is rw {
        self.new.name
    }

    multi method FALLBACK(::?CLASS:D: Str $name) is rw {
        $!values{ $name } //= ::?CLASS.new: :values( $!values{$name} )
    }

    method Slip {
        |$!values
    }
}

method to-data { to-data $!values }

method to-json(|c) { to-json $.to-data, |c }

multi to-data(JSON::Creator::Creator $_) {
    to-data .^values
}

multi to-data(%data --> Map()) {
    %data.map(
        -> (:$key, :$value) { $key => to-data $value }
    )
}
multi to-data(@data --> List()) {
    @data.map({ .&to-data })
}
multi to-data($_ is readonly) {
    $_
}

sub infix:<::>(Str() $key, $value) is tighter(&infix:<,>) is export {
    die unless $*JSON-CREATOR;
    $*JSON-CREATOR{$key} = $value;
}

sub json(&block) is export {
    my $creator = JSON::Creator::Creator.new;
    my $*JSON-CREATOR = $creator;
    block $creator;
   ::?CLASS.new: :values($creator.^values);
}


=begin pod

=head1 NAME

JSON::Creator - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use JSON::Creator;

=end code

=head1 DESCRIPTION

JSON::Creator is ...

=head1 AUTHOR

 <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
