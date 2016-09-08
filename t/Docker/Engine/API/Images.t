use v5.24;
use Test::More tests => 9;
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

my $i = $d->{images};

my $res = $i->list(
  {
    all     => 1,
    filters => {
      dangling => 'false'
    }
  }
);
like($res->{content}, qr/RepoTags/, "List images");

my $dir = `pwd`;
chomp $dir;
$res = $i->build(
  "$dir/t/Docker/Engine/API/dockerfile.tgz",
  {
    dockerfile => "dir/Dockerfile",
    t          => 'buildimagetag',
    q          => 1,
    labels     => {
      server => 'testserver'
    }
  }
);
is($res->{status}, 200, "Build dockerfile");

$res = $i->create(
  {
    fromImage => 'alpine',
    tag       => 'latest'
  }
);
like($res->{content}, qr/Pulling/, "Create image");

$res = $i->inspect(
  {
    name => 'buildimagetag'
  }
);
like($res->{content}, qr/RepoTags/, 'Inspect image');

$res = $i->history(
  {
    name => 'buildimagetag'
  }
);
like($res->{content}, qr/Created/, 'Image history');

$res = $i->push(
  {
    name              => 'nosuchimage',
    'X-Registry-Auth' => '{"username": "fakeuser", "password": "fakepassword", "email": "fake@fake.com"}'
  }
);
like($res->{content}, qr/locally/, "Push image");

$res = $i->tag(
  {
    name => 'buildimagetag',
    repo => 'fakerepo',
    tag  => 'faketag'
  }
);
is($res->{status}, 201, 'Tag image');

$res = $i->remove(
  {
    name  => 'fakerepo:faketag',
    force => 1
  }
);
like($res->{content}, qr/Untagged/, "Remove image");

$res = $i->search(
  {
    term    => 'ubuntu',
    limit   => 1,
    filters => {
      'is-official' => 'true'
    }
  }
);
like($res->{content}, qr/star_count/, "Search image");

$res = $i->remove(
  {
    name  => 'buildimagetag',
    force => 1
  }
);
