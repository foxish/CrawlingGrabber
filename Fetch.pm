#!/usr/bin/perl
package Fetch;

use strict;
use warnings FATAL => qw( all );
use LWP::Simple;
require LWP::UserAgent;

#look like a real browser, shall we?
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;
$ua->agent('Mozilla/5.0');

#download and write file (arguments = {url, dir, name})
sub downloadFile {
	my ($url, $dir, $name) = @_;
	my $response = $ua->get($url);
	if($response->is_success){
		open(my $fh,'>:raw', File::Spec->catfile($dir, $name));
		print $fh $response->content;
		close($fh);
		return length($response->decoded_content);
	}else{
		warn $response->status_line;
		return -1;
	}
}

#Just get file contents, for later parsing 
sub getFileContents {
	my $url = shift;
	my $response = $ua->get($url);
	if($response->is_success){
		return $response->decoded_content;
	}else{
		return;
	}
}

1;
