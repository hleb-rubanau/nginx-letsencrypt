#!/bin/bash

function get_domains_from_configs() {
	grep server_name /etc/nginx/conf.d/* | cut -f2 -d: \
		| sed -e 's/;//g' -e 's/server_name//g' -e 's/\s+/ /g' \
		| tr ' ' '\n' | grep -v '^$' | grep -v '*.' | sort | uniq
}

function deduplicate_list() {
    perl -e ' %seen= {} ; my @result; foreach $elem (@ARGV) { if(!$seen{$elem}){ push @result, $elem; } ; $seen{$elem}=1; }; print join(" ", @result)."\n"; ' $* 
}

if [ "$AUTOFILL_DOMAINS" = "true" ]; then
  for domain in $( get_domains_from_configs ) ; do
    if [ -z "$EXTRA_DOMAINS" ]; then 
      EXTRA_DOMAINS=$domain
    else
      EXTRA_DOMAINS="$EXTRA_DOMAINS $domain"
    fi
  done
else
    true
fi

if [ ! -z "$EXTRA_DOMAINS" ]; then
  LE_DOMAINS=$( deduplicate_list $PRIMARY_DOMAIN $EXTRA_DOMAINS )
else 
  LE_DOMAINS=$PRIMARY_DOMAIN
fi

echo "$LE_DOMAINS"
