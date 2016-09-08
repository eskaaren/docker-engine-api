use v5.24;
use feature qw/postderef/;
use Test::More tests => 11;
use lib '../../../../lib';
use lib 'lib';
use Docker::Engine::API;
use JSON::PP;
use Env;

my $time_begin = time();

unless (-d '/tmp/swarmtest') {
  mkdir '/tmp/swarmtest';
}

my $d = Docker::Engine::API->new(
  {
    base_url => $ENV{'prove_url'} // 'http://127.0.0.1:3375'
  }
);

my $m = $d->{misc};

my $res = $m->auth(
  {
    username      => 'fakeuser',
    password      => 'fakepass',
    serveraddress => 'https://index.docker.io/v1/'
  }
);
like($res->{content}, qr/unauthorized/, "Auth");

$res = $m->info();
like($res->{content}, qr/Architecture/, 'Info');

$res = $m->version();
like($res->{content}, qr/Version/, 'Version');

$res = $m->_ping();
like($res->{content}, qr/OK/, 'Ping');

my $c = $d->{containers};
$c->remove(
  {
    id    => 'misccontainer',
    v     => 1,
    force => 1
  }
);

my $i = $d->{images};
$i->remove(
  {
    name  => 'miscrepo:misctag',
    force => 1
  }
);

my $c_res = $c->create(
  {
    name   => 'misccontainer',
    config => {
      Cmd   => ['sleep', '30'],
      Image => 'alpine'
    }
  }
);
my $container_id = decode_json($c_res->{content})->{Id};
$res = $m->commit(
  {
    container => $container_id,
    repo      => 'miscrepo',
    tag       => 'misctag',
    comment   => 'Misctestcontainer commit',
    author    => 'Fakie Fake <fakie@fake.com>',
    pause     => 0,
    changes   => 'EXPOSE 6666',
    config    => {
      Hostname => 'mischostname',
      Cmd      => ['date']
    }
  }
);
like($res->{content}, qr/Id":/, "Commit");

my $time_end = time();
$res = $m->events(
  {
    since => $time_begin,
    until => $time_end
  }
);
is($res->{status}, '200', "Events");

$res = $m->get(
  {
    name => 'alpine:latest'
  }
);
is($res->{headers}->{'content-type'}, 'application/x-tar', "Get image");

$c_res = $c->start({id => $container_id});
$res = $m->exec(
  {
    id           => $container_id,
    AttachStdin  => JSON::PP->false(),
    AttachStdout => JSON::PP->true(),
    AttachStderr => JSON::PP->true(),
    DetachKeys   => 'ctrl-c',
    Tty          => JSON::PP->false(),
    Cmd          => ['sleep', '30']
  }
);
my $exec_id = decode_json($res->{content})->{Id};
is($res->{status}, 201, "Exec");

$res = $m->exec_start(
  {
    id     => $exec_id,
    Detach => JSON::PP->true(),
    Tty    => JSON::PP->false()
  }
);
is($res->{status}, 200, "Exec start");

$res = $m->exec_resize(
  {
    id => $exec_id,
    h  => 40,
    w  => 92
  }
);
is($res->{status}, 200, "Exec resize");

$res = $m->exec_inspect(
  {
    id => $exec_id
  }
);
like($res->{content}, qr/Running/, 'Exec inspect');

# Cleanup
END {
  $res = $c->remove(
    {
      id    => $container_id,
      v     => 1,
      force => 1
    }
  );

  $res = $i->remove(
    {
      name  => 'miscrepo:misctag',
      force => 1
    }
  );
}
