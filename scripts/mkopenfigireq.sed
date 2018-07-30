#!/usr/bin/sed -f

$! {
	s@]$@,@
}
1! {
	s@^\[@ @
}
