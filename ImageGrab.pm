#!/usr/bin/perl
package ImageGrab;

use strict;
use warnings FATAL => qw( all );
use Fetch;
use Number::Bytes::Human qw(format_bytes parse_bytes);
use File::Spec;
use File::Basename;
use URI::Escape;
use File::Basename;
use Data::Dumper;

#const
use constant DIR => 'Download';
use constant MAX_TRIES => 3;

#dispatch for download
sub downloader{
	my $retryCount = 0;
	
	my($url, $dir) = @_;
	my $filename = uri_unescape(basename($url));
	my $path = File::Spec->catfile($dir, $filename);
	my $response = -1;
	
	#check if file exists
	if(-e $path){
		warn "$path already exists, skipping file...";
		return;
	}
	
	#keep trying to download till you hit MAX_TRIES
	while($response < 0 && $retryCount < MAX_TRIES){
		$response = Fetch::downloadFile($url, $dir, $filename);
		if($response >= 0){
			writeStatus($path, $response);
		}
		$retryCount++;
	}
	
	#did it fail even after MAX_TRIES? *Sigh...*
	if($response < 0){
		warn "$path failed: Exceeded Max-Retries"; 
	}
}

#write status to stdout
sub writeStatus{
	my($path, $size) = @_;
	print "$path ok! --> ".format_bytes($size)."\n"; 
}

#grab url and send to downloader
#handover to this function and you are done
sub imageGrabber{
	my $url = shift;
	my $retryCount = 0;
	my $pageContents;
	
	while(!defined($pageContents) && $retryCount < MAX_TRIES){
		$pageContents = Fetch::getFileContents($url);
		if(defined($pageContents)){
			my @urlList = $pageContents =~ /(http.*?\.jpg)/g;
			foreach my $url (@urlList){
				downloader($url, DIR);
			}
		}
		$retryCount++;
	}
	#did it fail even after MAX_TRIES? *Sigh...*
	if(!defined($pageContents)){
		warn "$url failed: Exceeded Max-Retries"; 
	}
}

1;
