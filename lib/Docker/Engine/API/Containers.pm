package Docker::Engine::API::Containers;
use v5.24;
use lib '../../../../lib';
use Docker::Engine::API::HTTP;
use Docker::Engine::API::ContainerConfig;
use JSON::PP;
use Archive::Tar::File;
use feature qw/postderef/;
use strict;
use warnings FATAL => 'all';

sub new {
  my ($class, $self) = @_;
  $self->{http} = Docker::Engine::API::HTTP->new($self->{base_url});
  return bless $self, $class;
}

sub list {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => '/containers/json',
        params   => {
          all    => $opts->{all}    // undef,
          limit  => $opts->{limit}  // undef,
          since  => $opts->{since}  // undef,
          before => $opts->{before} // undef,
          size   => $opts->{size}   // undef,
          filters => $self->{http}->undef_stripper_to_json(
            {
              exited    => defined($opts->{filters}->{exited})    ? ["$opts->{filters}->{exited}"]    : undef,
              status    => defined($opts->{filters}->{status})    ? ["$opts->{filters}->{status}"]    : undef,
              label     => defined($opts->{filters}->{label})     ? ["$opts->{filters}->{label}"]     : undef,
              isolation => defined($opts->{filters}->{isolation}) ? ["$opts->{filters}->{isolation}"] : undef,
              ancestor  => defined($opts->{filters}->{ancestor})  ? ["$opts->{filters}->{ancestor}"]  : undef,
              before    => defined($opts->{filters}->{before})    ? ["$opts->{filters}->{before}"]    : undef,
              since     => defined($opts->{filters}->{since})     ? ["$opts->{filters}->{since}"]     : undef,
              volume    => defined($opts->{filters}->{volume})    ? ["$opts->{filters}->{volume}"]    : undef,
              network   => defined($opts->{filters}->{network})   ? ["$opts->{filters}->{network}"]   : undef
            }
          ) // undef
        }
      }
    )
  );
}

sub create {
  my ($self, $opts) = @_;
  my $config = Docker::Engine::API::ContainerConfig->new();

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/containers/create',
        params   => {
          name => $opts->{name}
        }
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => encode_json($config->override($opts->{config}))
    }
  );
}

sub inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/json",
        params   => {
          size => $opts->{size} // 0
        }
      }
    )
  );
}

sub top {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/top",
        params   => {
          ps_args => $opts->{ps_args} // '-ef'
        }
      }
    )
  );
}

sub logs {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/logs",
        params   => {
          details    => $opts->{details}    // 0,
          follow     => $opts->{follow}     // 0,
          stdout     => $opts->{stdout}     // 0,
          stderr     => $opts->{stderr}     // 0,
          since      => $opts->{since}      // 0,
          timestamps => $opts->{timestamps} // 0,
          tail       => $opts->{tail}       // 'all'
        }
      }
    )
  );
}

sub changes {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/changes"
      }
    )
  );
}

sub export {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/export"
      }
    )
  );
}

sub stats {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/stats",
        params   => {
          stream => $opts->{stream} // 1
        }
      }
    )
  );
}

sub resize {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/resize",
        params   => {
          h => $opts->{h} // 40,
          w => $opts->{w} // 80
        }
      }
    )
  );
}

sub start {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/start"
      }
    )
  );
}

sub stop {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/stop",
        params   => {
          t => $opts->{t} // 0
        }
      }
    )
  );
}

sub restart {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/restart",
        params   => {
          t => $opts->{t} // 0
        }
      }
    )
  );
}

sub kill {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/kill",
        params   => {
          signal => $opts->{signal} // 'SIGKILL'
        }
      }
    )
  );
}

sub update {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/update"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => encode_json($opts->{config})
    }
  );
}

sub rename {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/rename",
        params   => {
          name => $opts->{name}
        }
      }
    )
  );
}

sub pause {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/pause"
      }
    )
  );
}

sub unpause {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/unpause"
      }
    )
  );
}

sub attach {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/attach",
        params   => {
          detachKeys => $opts->{detachKeys} // 'ctrl-<c>',
          logs       => $opts->{logs}       // 0,
          stream     => $opts->{stream}     // 0,
          stdin      => $opts->{stdin}      // 0,
          stdout     => $opts->{stdout}     // 0,
          stderr     => $opts->{stderr}     // 0
        }
      }
    )
  );
}

sub attach_ws {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/attach/ws",
        params   => {
          detachKeys => $opts->{detachKeys} // 'ctrl-<c>',
          logs       => $opts->{logs}       // 0,
          stream     => $opts->{stream}     // 0,
          stdin      => $opts->{stdin}      // 0,
          stdout     => $opts->{stdout}     // 0,
          stderr     => $opts->{stderr}     // 0
        }
      }
    )
  );
}

sub wait {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/wait"
      }
    )
  );
}

sub remove {
  my ($self, $opts) = @_;

  return $self->{http}->delete(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}",
        params   => {
          v     => $opts->{v}     // 0,
          force => $opts->{force} // 0
        }
      }
    )
  );
}

sub archive {
  my ($self, $opts) = @_;
  my $url = $self->{http}->url_builder(
    {
      endpoint => "/containers/$opts->{id}/archive",
      params   => {
        path                 => $opts->{path},
        noOverwriteDirNonDir => $opts->{noOverwriteDirNonDir} // 1
      }
    }
  );

  if ($opts->{op} eq 'get') {
    return $self->{http}->get($url);
  }
  elsif ($opts->{op} eq 'put') {
    my $tar = Archive::Tar::File->new(file => $opts->{archive});

    return $self->{http}->put(
      $url,
      {
        headers => {'Content-Type' => 'application/x-tar'},
        content => $tar->get_content()
      }
    );
  }
  elsif ($opts->{op} eq 'head') {
    return $self->{http}->head($url);
  }
}

1;
