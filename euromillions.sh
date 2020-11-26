#!/usr/bin/env zsh

set -e
err_report() {
    echo $0": error on line $1"
}
trap 'err_report $LINENO' ERR

LANG=C
LC_NUMERIC=C

YOUR_NUMBERS=("$@")

if [ -z "$YOUR_NUMBERS" ]; then
  echo "Usage: ./euromillions.sh 5 7 8 16 20 2 12"
  exit
fi

# improving compatibility between zsh and bash users
if [[ -n ${ZSH_VERSION} ]]; then 
    INDEX_START=1 # zsh arrays start at index position 1 while bash arrays at index position 0
    NONE='\x1b[0m'
    BRIGHT='\x1b[1m'
    GREEN='\x1b[32m'
    UNDERSCORE="\x1b[4m"
else 
    INDEX_START=0
    NONE='\033[00m'
    BRIGHT='\033[01m'
    GREEN='\033[32m'
    UNDERSCORE="\033[04m"
fi

# convert all YOUR_NUMBERS to integers 
for i in {0,1,2,3,4,5,6,7}; do
    YOUR_NUMBERS[$(($i+$INDEX_START))]=$(($YOUR_NUMBERS[$(($i+$INDEX_START))]+0))
done

echo ${BRIGHT}${UNDERSCORE}"Your Numbers: ${YOUR_NUMBERS[@]}"${NONE}

RESULTS="`wget -qO- https://www.national-lottery.co.uk/results/euromillions/draw-history/csv`"
echo "$RESULTS" | tail -n +2 | while read line; do

	RESULT=( $(echo $line | sed 's/,/ /g') )

	matching_list=( ${YOUR_NUMBERS[@]} )
	result_list=( ${RESULT[@]:1:7} )
	
	# pad matching_list with zeros
	for i in {0,1,2,3,4,5,6}; do
		matching_list[$(($i+$INDEX_START))]=$(printf "%02d" ${matching_list[$(($i+$INDEX_START))]})
	done

	# pad result_list with zeros
	for i in {0,1,2,3,4,5,6}; do
		result_list[$(($i+$INDEX_START))]=$(printf "%02d" ${result_list[$(($i+$INDEX_START))]})
	done

	# counting numbers matching
	matching_count=0
	for i in {1,2,3,4,5}; do 
		for j in {0,1,2,3,4}; do 
			if [ $((${RESULT[$(($i+$INDEX_START))]})) -eq $((${YOUR_NUMBERS[$(($j+$INDEX_START))]})) ]; then 
				((++matching_count)); 
				matching_list[$(($j+$INDEX_START))]=${BRIGHT}${GREEN}${matching_list[$(($j+$INDEX_START))]}${NONE}
				result_list[$(($i+$INDEX_START-1))]=${BRIGHT}${GREEN}${result_list[$(($i+$INDEX_START-1))]}${NONE}
			fi
		done
	done

	# counting lucky stars matching
	luckystars_count=0
	for i in {6,7}; do 
		for j in {5,6}; do 
			if [ $((${RESULT[$(($i+$INDEX_START))]})) -eq $((${YOUR_NUMBERS[$(($j+$INDEX_START))]})) ]; then 
				((++luckystars_count)); 
				matching_list[$(($j+$INDEX_START))]=${BRIGHT}${GREEN}${matching_list[$(($j+$INDEX_START))]}${NONE}
				result_list[$(($i+$INDEX_START-1))]=${BRIGHT}${GREEN}${result_list[$(($i+$INDEX_START-1))]}${NONE}
			fi
		done
	done

	# notify any winning match
	if [ $matching_count -eq 5 -a $luckystars_count -eq 2 ] ;   then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 5+2 - ${BRIGHT}${GREEN}>£30m win${NONE}"
	elif [ $matching_count -eq 5 -a $luckystars_count -eq 1 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 5+1 - ${BRIGHT}${GREEN}~£100k win${NONE}"
	elif [ $matching_count -eq 5 -a $luckystars_count -eq 0 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 5+0 - ${BRIGHT}${GREEN}~£10k win${NONE}"
	elif [ $matching_count -eq 4 -a $luckystars_count -eq 2 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 4+2 - ${BRIGHT}${GREEN}~£1k win${NONE}"
	elif [ $matching_count -eq 4 -a $luckystars_count -eq 1 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 4+1 - ${BRIGHT}${GREEN}~£100 win${NONE}"
	elif [ $matching_count -eq 3 -a $luckystars_count -eq 2 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 3+2 - ${BRIGHT}${GREEN}~£50 win${NONE}"
	elif [ $matching_count -eq 4 -a $luckystars_count -eq 0 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 4+0 - ${BRIGHT}${GREEN}~£25 win${NONE}"
	elif [ $matching_count -eq 2 -a $luckystars_count -eq 2 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 2+2 - ${BRIGHT}${GREEN}~£10 win${NONE}"
	elif [ $matching_count -eq 3 -a $luckystars_count -eq 1 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 3+1 - ${BRIGHT}${GREEN}~£7 win${NONE}"
	elif [ $matching_count -eq 3 -a $luckystars_count -eq 0 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 3+0 - ${BRIGHT}${GREEN}~£6.0 win${NONE}"
	elif [ $matching_count -eq 1 -a $luckystars_count -eq 2 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 1+2 - ${BRIGHT}${GREEN}~£4.3 win${NONE}"
	elif [ $matching_count -eq 2 -a $luckystars_count -eq 1 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 2+1 - ${BRIGHT}${GREEN}~£3.6 win${NONE}"
	elif [ $matching_count -eq 2 -a $luckystars_count -eq 0 ] ; then echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match 2+0 - ${BRIGHT}${GREEN}~£2.5 win${NONE}"
	else
		echo "${RESULT[0+INDEX_START]} - ${result_list[@]:0:5} | ${result_list[@]:5:2} - Match ${matching_count}+${luckystars_count} - No win"
	fi
done