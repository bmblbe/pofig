#!/usr/bin/env raku

use lib <.>;
use Pofig;

say "os name: " ~ os-name;
say "os version: " ~ os-version;
say "os vmajor: " ~ os-vmajor;
say "os vminor: " ~ os-vminor;
say "kernel version: " ~ kernel-version;
say "kernel vmajor: " ~ kernel-vmajor;
say "kernel vminor: " ~ kernel-vminor;
say "kernel vrevision: " ~ kernel-vrevision;
say "distro name: " ~ distro-name;
say "distro version: " ~ distro-version;
say "distro vmajor: " ~ distro-vmajor;
say "distro vminor: " ~ distro-vminor;
say "arch: " ~ arch-name;