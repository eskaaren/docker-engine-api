package Docker::Engine::API::Misc;
use v5.24;
use lib '../../../../lib';
use Docker::Engine::API::HTTP;
use URI::Escape;
use strict;
use warnings;

sub new {
  my ($class, $self) = @_;
  $self->{http} = Docker::Engine::API::HTTP->new($self->{base_url});
  return bless $self, $class;
}

sub auth {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/auth'
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          username      => $opts->{username}      // undef,
          password      => $opts->{password}      // undef,
          serveraddress => $opts->{serveraddress} // undef
        }
      ) // undef
    }
  );
}

sub info {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => '/info'
      }
    )
  );
}

sub version {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => '/version'
      }
    )
  );
}

sub _ping {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => '/_ping'
      }
    )
  );
}

sub commit {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/commit',
        params   => {
          container => $opts->{container}           // undef,
          repo      => $opts->{repo}                // undef,
          tag       => $opts->{tag}                 // undef,
          comment   => uri_escape($opts->{comment}) // undef,
          author    => uri_escape($opts->{author})  // undef,
          pause     => $opts->{pause}               // undef,
          changes   => uri_escape($opts->{changes}) // undef
        }
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json($opts->{config}) // undef
    }
  );
}

sub events {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => '/events',
        params   => {
          since   => $opts->{since}   // undef,
          until   => $opts->{until}   // undef,
          filters => $opts->{filters} // undef
        }
      }
    )
  );
}

sub get {
  my ($self, $opts) = @_;
  my $endpoint = '/images/get';

  if (defined($opts->{name})) {
    $endpoint = "/images/$opts->{name}/get";
  }

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => $endpoint

         # TODO: The api docs suggests that there might be parameters to select by name, but not good enough documented.
      }
    )
  );
}

sub load {
  my ($self, $tarfile, $opts) = @_;
  my $tar = Archive::Tar::File->new(file => $tarfile);

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/images/load'
      },
      {
        headers => {'Content-Type' => 'application/x-tar'},
        content => $tar->get_content()
      }
    )
  );
}

sub exec {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/containers/$opts->{id}/exec"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          AttachStdin  => $opts->{AttachStdin}  // undef,
          AttachStdout => $opts->{AttachStdout} // undef,
          AttachStderr => $opts->{AttachStderr} // undef,
          DetachKeys   => $opts->{DetachKeys}   // undef,
          Tty          => $opts->{Tty}          // undef,
          Cmd          => $opts->{Cmd}          // undef
        }
      ) // undef
    }
  );
}

sub exec_start {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/exec/$opts->{id}/start"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Detach => $opts->{Detach} // undef,
          Tty    => $opts->{Tty}    // undef
        }
      ) // undef
    }
  );
}

sub exec_resize {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/exec/$opts->{id}/resize",
        params   => {
          h => $opts->{h} // undef,
          w => $opts->{w} // undef
        }
      }
    )
  );
}

sub exec_inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/exec/$opts->{id}/json"
      }
    )
  );
}

1;
