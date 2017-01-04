
#!/bin/bash


# samples_dir="/gs/project/ugh-612-aa/huziy/Output/GL_Hostetler/Samples"
samples_dir="/sf1/escer/sushama/restore/huziy/Samples"
coords_file=${samples_dir}/../tictacs.rpn

#===================

. s.ssmuse.dot diagtools fulldev

# create the coords file
rm -f ${coords_file}
for f in ${samples_dir}/*/pm*; do
	echo "desire(-1, ['>>', '^^'])" | editfst -s $f -d ${coords_file}
	break
done


# select the data
for y in {1998..1998}; do

	echo $y

	soumet  ./select_fields_for_Craig.sh  -t  7200 -cpus 1 -listing /home/huziy/listings/localhost -jn select_${y} -args ${y} ${samples_dir} ${coords_file}

done

