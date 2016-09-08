package Docker::Engine::API::HTTP;
use v5.24;
use feature qw/postderef/;
use HTTP::Tiny;
use JSON::PP;
use strict;
use warnings FATAL => 'all';

sub new {
  my ($class, $base_url) = @_;
  my $self = {
    http     => HTTP::Tiny->new(),
    base_url => $base_url
  };
  return bless $self, $class;
}

sub request {
  my ($self, $opts) = @_;

  return $self->{http}->request(
    $opts->{method},
    $opts->{url} => {
      headers => $opts->{headers},
      content => $opts->{content}
    }
  );

}

sub get {
  my ($self, $url) = @_;

  return $self->request(
    {
      method => 'GET',
      url    => $url
    }
  );
}

sub post {
  my ($self, $url, $opts) = @_;
  my $req_opts = $opts;
  $req_opts->{method} = 'POST';
  $req_opts->{url}    = $url;

  return $self->request($req_opts);
}

sub put {
  my ($self, $url, $opts) = @_;
  my $req_opts = $opts;
  $req_opts->{method} = 'PUT';
  $req_opts->{url}    = $url;

  return $self->request($req_opts);
}

sub head {
  my ($self, $url) = @_;

  return $self->request(
    {
      method => 'GET',
      url    => $url
    }
  );

}

sub delete {
  my ($self, $url) = @_;

  return $self->request(
    {
      method => 'DELETE',
      url    => $url
    }
  );
}

sub url_builder {
  my ($self, $opts) = @_;

  my $url = $self->{base_url} . $opts->{endpoint};
  if ($opts->{params}) {
    $url .= '?';
    for my $k (keys $opts->{params}->%*) {
      if (defined($opts->{params}->{$k})) {
        my $param = $k . "=" . $opts->{params}->{$k};
        $url .= "$param" . '&';
      }
    }
  }
  $url =~ s/\&$//g;
  return $url;
}

sub undef_stripper {
  my ($self, $data) = @_;
  my $stripped = undef;

  for my $k (keys $data->%*) {
    if (defined($data->{$k})) {
      $stripped->{$k} = $data->{$k};
    }
  }
  return $stripped;
}

sub undef_stripper_to_json {
  my ($self, $data) = @_;

  $data = $self->undef_stripper($data);

  if (defined($data)) {
    return encode_json($data);
  }
  return undef;
}

1;
