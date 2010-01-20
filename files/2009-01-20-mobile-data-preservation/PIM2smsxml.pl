#!/usr/bin/perl -w
#################################
# Description:	Script to transform PIMBackup data into SMS Backup & Restore
#		data.
# Author:	Mario Mlynek
# Updates:	Lewis Oaten
# Last Updated:	19th Jan 2010
#################################
use Time::Local;

open(DATA,"<$ARGV[0]");
open(OUT,">sms.xml");

print OUT "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>\n";
print OUT "<smses>\n";
my $i = 0;
while(<DATA>) {
  my $fromTEL;
	my $UDATE;
	my $TYPE;
	my $MSG;
	my $SC;
	my $STATUS;

  if ($i == 0) {$i++; next};
	s/"|\\"//g;
  my @data = split /;/;

	if ($data[16] eq '') {$i++; next}; # escape clause for drafts (No Delivered date)
	if ($data[16] eq 'IPM.SMStext.vCard') {$i++; next}; # It's a txt with funkey orderd things SKIP!

	if ($data[5] =~ s/\\$//) {
		$data[5] .= ";".$data[6];
		splice(@data,6,1);
	}
	$MSG	=	$data[5];
	$MSG  =~ s/&/&amp\;/g;
	$MSG	=~ s/<BR>/\&\#13\;\&\#10\;/g;

	my @DATE = split /\,/,$data[16];
	print "$data[13] - $data[14] - $data[15] - $data[16]\n";
	$UDATE = timelocal($DATE[5],$DATE[4],$DATE[3],$DATE[2],$DATE[1]-1,$DATE[0])+3600;
	$UDATE .= "000";

	if ($data[7] eq '0') {	# Sended SMS
  	$TEL = $data[20];
		$TEL =~ s/\\$//;
		$TYPE	= '2';
		$SC		= 'null';
		$STATUS = '0';
	} else {								# Received SMS
  	$TEL = $data[2];
		$TEL =~ s/\D*(\+*\d{4,})\D*/$1/;
		$TEL =~ s/^00/+/;
		
		$TYPE	= '1';
		$SC		= '+447729000687';
		$STATUS = '-1';
	}

#	if ($i == 20) {last};	
  print OUT "<sms protocol=\"0\" address=\"$TEL\" date=\"$UDATE\" type=\"$TYPE\" subject=\"null\" body=\"$MSG\" toa=\"null\" sc_toa=\"null\" service_center=\"$SC\" read=\"1\" status=\"$STATUS\" />\n";
	$i++;
}
print OUT "</smses>";
close(OUT);
close(DATA);
