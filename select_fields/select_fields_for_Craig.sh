#!/bin/bash

# Select required fields from the complete output dataset


dm_fields='UU','VV','TT','HR','P0','PN','HU'
pm_fields='N4','AD','PR','STFL','CLDP','T5','T9','IMAV','L1','LC','LD','TRAF','TDRA','IMAV','I5','SD','FV','FC','N3'

#dm_fields='HU'


# Absolute path to the directory with Samples
samples_dir=$2

out_dir=${samples_dir}/../selected_fields


coords_file=$3

. s.ssmuse.dot diagtools fulldev

#====================================================

set -e

mkdir -p ${out_dir}

select_year=$1


function select_vars_for_type {
	fprefix=$1
	selfields=$2
	fpath_dst=$3


        # Decide whether a variable should selected again
	i=0
	for the_field in $(echo ${selfields} | tr ',' ' '); do
		
		to_select[$i]=1
		
		if [ -s ${fpath_dst}_${the_field} ]; then
			to_select[$i]=0
		fi
		
		i=$(echo "${i}+1" | bc -l)
	done



        
	for pmf in ${monthdir}/${fprefix}*; do


		# Skip the file for time step 0
		if [[ ${pmf} == *00000000? ]]; then
			echo "skipping ${pmf}"
		fi

		# Save each field in a separate file
		i=0
		for the_field in $(echo ${selfields} | tr ',' ' '); do
			
			current_dest_file=${fpath_dst}_${the_field}

			# Copy coordinates to the output files (if required)
			if [ ! -s ${current_dest_file} ]; then 
				editfst -i 0 -s ${coords_file} -d ${current_dest_file}
			fi

			# Skip the variables which were already extracted
			if [ "${to_select[$i]}" = "0"  ]; then
				i=$(echo "${i}+1" | bc -l)
				echo "Skipping ${the_field} from ${pmf}, already selected!"
				continue
			fi

			echo "desire(-1, [${the_field}])" | editfst -s ${pmf} -d ${current_dest_file} 
			i=$(echo "${i}+1" | bc -l)
		done

	done

}


for monthdir in ${samples_dir}/*${select_year}??; do

	monthdir_dst=${out_dir}/$(basename ${monthdir})
	
	monthfile_dst=${monthdir_dst}/selected_fields.rpn

#	if [ -d ${monthdir_dst} ]; then
#		echo "${monthdir_dst} already exists, won't redo ..."
#		continue
#	fi

	mkdir -p ${monthdir_dst}


        if [ ! -z ${pm_fields} ]; then	
        	select_vars_for_type pm ${pm_fields} ${monthfile_dst}
	fi

	if [ ! -z ${dm_fields} ]; then
	        select_vars_for_type dm ${dm_fields} ${monthfile_dst}
        fi

	# editfst -i 0 -s ${coords_file} -d ${monthfile_dst}

done

