#!/usr/bin/awk -f

{
	if ($1 == s && $2 == p) {
		$1 = " ";
		$2 = " ";
		y = ",";
	} else if ($1 == s) {
		$1 = " ";
		p = $2;
		y = ";";
	} else {
		s = $1;
		p = $2;
		y = ".";
	}
	NF--;
	if (x) {
		print x, y;
	}
	x = $0;
}
END {
	print x, ".";
}
