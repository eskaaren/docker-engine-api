use v5.24;
use Test::More;
use lib '../../../../lib';
use lib 'lib';
use Docker::Engine::API;
use JSON::PP;
use Env;

unless (-d '/tmp/swarmtest') {
  mkdir '/tmp/swarmtest';
}

my $d = Docker::Engine::API->new(
  {
    base_url => $ENV{'prove_url'} // 'http://127.0.0.1:3375'
  }
);

my $n = $d->{networks};
$n->remove(
  {
    id => 'testnetwork'
  }
);

my $res = $n->list(
  {
    filters => {
      name => 'bridge'
    }
  }
);
like($res->{content}, qr/Name\":\"bridge/, "List networks");

my $id = decode_json($res->{content})->[0]->{Id};
$res = $n->inspect(
  {
    id => $id
  }
);
like($res->{content}, qr/Name":/, "Inspect network");

$res = $n->create(
  {
    Name => "testnetwork"
  }
);
like($res->{content}, qr/Id":/, "Create network");

$id = decode_json($res->{content})->{Id};
my $c = $d->{containers};
$c->remove(
    {
      id    => 'networktestcontainer',
      v     => 1,
      force => 1
    }
  );
$res = $c->create(
  {
    name   => 'networktestcontainer',
    config => {
      Cmd   => ['ping', '-c', '20', '127.0.0.1'],
      Image => 'alpine'
    }
  }
);
my $container = decode_json($res->{content})->{Id};
$res = $n->connect(
  {
    id        => $id,
    Container => $container
  }
);
is($res->{status}, 200, "Connect network");

$res = $n->disconnect(
  {
    id        => $id,
    Container => $container,
    Force => JSON::PP->true()
  }
);
is($res->{status}, 200, "Disconnect network");

$res = $n->remove(
  {
    id => $id
  }
);
is($res->{status}, 204, "Remove network");

done_testing();

END {
  $res = $c->remove(
    {
      id    => $container,
      v     => 1,
      force => 1
    }
  );
}
