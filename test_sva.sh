#!/bin/bash

exec 2>&1
set -ex

## set up files
ln -s $PRJDIR/test_sva.sby .
ln -s $PRJDIR/properties.sv .

## create the mutated design
bash $SCRIPTS/create_mutated.sh -c -o mutated.sv

while read idx mut; do
	## run formal property check
	sby -f test_sva.sby ${idx}
	## obtain result
	gawk "{ print $idx, \$1; }" test_sva_${idx}/status >> output.txt
done < input.txt

exit 0
