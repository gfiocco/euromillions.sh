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
else 
	INDEX_START=0
	NONE='\033[00m'
	BRIGHT='\033[01m'
	GREEN='\033[32m'
fi

RESULTS="`wget -qO- https://www.national-lottery.co.uk/results/euromillions/draw-history/csv`"
echo "$RESULTS" | tail -n +2 | while read line; do

	result=( $(echo $line | sed 's/,/ /g') )

	matching_list=( ${YOUR_NUMBERS[@]} )

	# counting numbers matching
	matching_count=0
	for i in {1,2,3,4,5}; do 
		for j in {0,1,2,3,4}; do 
			if [ $((${result[$(($i+$INDEX_START))]})) -eq $((${YOUR_NUMBERS[$(($j+$INDEX_START))]})) ]; then 
				((++matching_count)); 
				matching_list[$(($j+$INDEX_START))]=${BRIGHT}${GREEN}${YOUR_NUMBERS[$(($j+$INDEX_START))]}${NONE}
			fi
		done
	done

	# counting lucky stars matching
	luckystars_count=0
	for i in {6,7}; do 
		for j in {5,6}; do 
			if [ $((${result[$(($i+$INDEX_START))]})) -eq $((${YOUR_NUMBERS[$(($j+$INDEX_START))]})) ]; then 
				((++luckystars_count)); 
				luckystars_list+=( ${YOUR_NUMBERS[$(($j+$INDEX_START))]} )
				matching_list[$(($j+$INDEX_START))]=${BRIGHT}${GREEN}${YOUR_NUMBERS[$(($j+$INDEX_START))]}${NONE}
			fi
		done
	done

	# notify any winning match
	matching_string="${matching_list[@]:0:5} | ${matching_list[@]:5:2}"
	if [ $matching_count -eq 5 -a $luckystars_count -eq 2 ] ; then   printf "${result[0+INDEX_START]} - Match 5 + 2 for draw ${result[9+$INDEX_START]} >£30m win  ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 5 -a $luckystars_count -eq 1 ] ; then printf "${result[0+INDEX_START]} - Match 5 + 1 for draw ${result[9+$INDEX_START]} ~£100k win ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 5 -a $luckystars_count -eq 0 ] ; then printf "${result[0+INDEX_START]} - Match 5 + 0 for draw ${result[9+$INDEX_START]} ~£10k win  ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 4 -a $luckystars_count -eq 2 ] ; then printf "${result[0+INDEX_START]} - Match 4 + 2 for draw ${result[9+$INDEX_START]} ~£1k win   ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 4 -a $luckystars_count -eq 1 ] ; then printf "${result[0+INDEX_START]} - Match 4 + 1 for draw ${result[9+$INDEX_START]} ~£100 win  ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 3 -a $luckystars_count -eq 2 ] ; then printf "${result[0+INDEX_START]} - Match 3 + 2 for draw ${result[9+$INDEX_START]} ~£50 win   ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 4 -a $luckystars_count -eq 0 ] ; then printf "${result[0+INDEX_START]} - Match 4 + 0 for draw ${result[9+$INDEX_START]} ~£25 win   ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 2 -a $luckystars_count -eq 2 ] ; then printf "${result[0+INDEX_START]} - Match 2 + 2 for draw ${result[9+$INDEX_START]} ~£10 win   ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 3 -a $luckystars_count -eq 1 ] ; then printf "${result[0+INDEX_START]} - Match 3 + 1 for draw ${result[9+$INDEX_START]} ~£7 win    ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 3 -a $luckystars_count -eq 0 ] ; then printf "${result[0+INDEX_START]} - Match 3 + 0 for draw ${result[9+$INDEX_START]} ~£6 win    ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 1 -a $luckystars_count -eq 2 ] ; then printf "${result[0+INDEX_START]} - Match 1 + 2 for draw ${result[9+$INDEX_START]} ~£4.30 win ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 2 -a $luckystars_count -eq 1 ] ; then printf "${result[0+INDEX_START]} - Match 2 + 1 for draw ${result[9+$INDEX_START]} ~£3.60 win ($matching_string) markert:${result[8+INDEX_START]}\n"
	elif [ $matching_count -eq 2 -a $luckystars_count -eq 0 ] ; then printf "${result[0+INDEX_START]} - Match 2 + 0 for draw ${result[9+$INDEX_START]} ~£2.50 win ($matching_string) markert:${result[8+INDEX_START]}\n"
	fi

done