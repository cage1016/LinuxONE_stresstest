#!/usr/bin/env bash

## Copyright (c) 2021 https://kaichu.io All Rights Reserved.
##__author__ = 'KAI CHU CHUNG'
##----------------------------------------------------------
## run jmeter container for bash shell

## Reference and Credits:
## http://tldp.org/LDP/abs/html/parameter-substitution.html
## https://stackoverflow.com/questions/14370133/is-there-a-way-to-create-key-value-pairs-in-bash-script#14371026
## https://stackoverflow.com/questions/5499472/specify-command-line-arguments-like-name-value-pairs-for-shell-script

## @Example:
## $ ./jmeter.sh -h
## Usage: jmeter.sh [-d <daemon>] [-i <jmeter_docker_image>] [-f <jmx_file>] [-t <test_folder>] [-z <enable_tar_html>] [-l <jmeterVariablesList>]
##  -d : Daemon, docker/podman (default: docker)
##  -t : Test directory (default: ./tmp)
##  -i : Jmeter docker image (default: ghcr.io/cage1016/jmeter:5.4.1)
##  -f : Specify JMX file
##  -l : Specify env list of Jmeter in following format: prop01=XXX,bbb=YYY,ccc=ZZZ
##  -z : Enable tar html report (default: false)
##  -g : Specify generate-png of Jmeter in following format: jmeter.jtl=ResponseTimesOverTime,perfMon.jtl=PerfMon
##
##   Example1: jmeter.sh -f ap.jmx
##   Example2: jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx
##   Example3: jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx -l prop01=XXX,prop02=YYY
##   Example4: jmeter.sh -d podman -f ap.jmx -z true -l prop01=XXX,prop02=YYY
##----------------------------------------------------------

scriptName=$(basename $0)

### check whether string is "option" (stats with "-")
checkOption(){
	# result: 0=false, other=true
	var=$1

	if [[ "${var}" = "-" ]]; then
		result=1
	elif [[ $(expr "${var}" : "\-") -ne 0 ]] ; then
		result=1
	else
		result=0
	fi
	echo ${result}
}

createSubCommand2(){
	# arg1: property list delimitted by comma (ex. parm1=xxx,parm2=yyy,parm3=zzz)
	propertyList=$@

	IFS=',' read -ra arrayPropertyList <<< "$propertyList"

	commandString=""
	idx=0
	for i in "${arrayPropertyList[@]}"
	do
        commandString="${commandString} -J${i}"
	done

	echo ${commandString}
}

createGeneratePngCommand(){
	propertyList=$@

	IFS=',' read -ra arrayPropertyList <<< "$propertyList"

    arrVar=()
	for i in "${arrayPropertyList[@]}"
	do
		IFS='=' read -ra buf <<< "$i"
        arrVar+=("--generate-png /tmp/${buf[1]}.png --input-jtl /tmp/${buf[0]} --plugin-type ${buf[1]},")
	done

	echo "${arrVar[*]}"
}

parseEnv(){
	keys=("THREADS RAMD_UP DURATION")
	propertyList=$@

	IFS=',' read -ra arrayPropertyList <<< "$propertyList"
	p=""
	for i in "${arrayPropertyList[@]}"
	do
		IFS='=' read -ra buf <<< "$i"
		if [[ ${keys[*]} =~ "${buf[0]}" ]]; then
			p="${p}_"${buf[0]}_${buf[1]}""
		fi		
	done
	
	echo "${p}" 
}

showHelp(){
	echo "Usage: ${scriptName} [-d <daemon>] [-i <jmeter_docker_image>] [-f <jmx_file>] [-t <test_folder>] [-z <enable_tar_html>] [-l <jmeterVariablesList>]"
	echo " -d : Daemon, docker/podman (default: docker)"
	echo " -t : Test directory (default: ./tmp)"
	echo " -i : Jmeter docker image (default: ghcr.io/cage1016/jmeter:5.4.1)"
	echo " -f : Specify JMX file"
	echo " -l : Specify env list of Jmeter in following format: prop01=XXX,bbb=YYY,ccc=ZZZ"
	echo " -z : Enable tar html report (default: false)"
	echo " -g : Specify generate-png of Jmeter in following format: jmeter.jtl=ResponseTimesOverTime,perfMon.jtl=PerfMon"
	echo " "
	echo "  Example1: ${scriptName} -f ap.jmx"
	echo "  Example2: ${scriptName} -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx"
	echo "  Example3: ${scriptName} -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx -l prop01=XXX,prop02=YYY"
	echo "  Example4: ${scriptName} -d podman -f ap.jmx -z true -l prop01=XXX,prop02=YYY"
	echo ""
	exit 1
}

#######################################
# Main Logic
#######################################
arg_f=
flag_f=0
arg_i=
flag_i=0
arg_l=
flag_l=0
arg_d=
flag_d=0
arg_t=
flag_t=0
arg_z=
flag_z=0
arg_g=
flag_g=0

for option in "$@"
do
	case "$option" in
		'-h')
			showHelp
			exit 0
			;;
		'-d')
			flag_d=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -i"
				showHelp
				exit 1
			elif [[ "$2" != "docker" ]] && [[ "$2" != "podman" ]]; then
				echo "Error: Daemon must be \"docker\" or \"podman\""
				showHelp
				exit 1
			else
				arg_d="$2"
				shift 2
			fi
			;;
		'-i')
			flag_i=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -i"
				showHelp
				exit 1
			else
				arg_i="$2"
				shift 2
			fi
			;;
		'-f')
			flag_f=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -f"
				showHelp
				exit 1
			else
				arg_f="$2"
				shift 2
			fi
			;;
		'-l')
			flag_l=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -l"
				showHelp
				exit 1
			else
				arg_l=$2
				shift 2
			fi
			;;
		'-t')
			flag_t=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -t"
				showHelp
				exit 1
			else
				arg_t=$2
				shift 2
			fi
			;;
		'-z')
			flag_z=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -z, (true or false)"
				showHelp
				exit 1
			elif [[ "$2" != "true" ]] && [[ "$2" != "false" ]]; then
				echo "Error: Daemon must be \"true\" or \"false\""
				showHelp
				exit 1
			else
				arg_z=$2
				shift 2
			fi
			;;
		'-g')
			flag_g=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -g"
				showHelp
				exit 1
			else
				arg_g=$2
				shift 2
			fi
			;;
		-*)
			echo "Error: Unsupported option: $1"
			showHelp
			exit 1
			;;
		*)
			if [[ ! -z "$1" ]] && [[ $(checkOption "$1") -eq 0 ]]; then
				shift 1
			fi
			;;
	esac
done


# echo flag_i: ${flag_i}
# echo arg_i: ${arg_i}
# echo flag_f: ${flag_f}
# echo arg_f: ${arg_f}
# echo flag_l: ${flag_l}
# echo arg_l: ${arg_l}

# jmx
if [[ ${flag_f} -ne 0 ]]; then
	jmxName=${arg_f}
else
	echo "Error: Please specify JMX using -f."
	showHelp
	exit 0
fi

# docker image
jmeterDocker="ghcr.io/cage1016/jmeter:5.4.1"
if [[ ${flag_i} -ne 0 ]]; then
	jmeterDocker=${arg_i}
fi

# daemon
daemon="docker"
if [[ ${flag_d} -ne 0 ]]; then
	daemon=${arg_d}
fi

# tar.gz
enbaleTargz=false
if [[ ${flag_z} -ne 0 ]]; then
	enbaleTargz=${arg_z}
fi

# test folder
testFolder="./tmp"
if [[ ${flag_t} -ne 0 ]]; then
	testFolder=${arg_t}
fi
rDir=${testFolder}/report
rm -rf ${testFolder} > /dev/null 2>&1
mkdir -p ${rDir}

subCommand=""
filePath1=""
if [[ ${flag_l} -ne 0 ]]; then
	subCommand=$(createSubCommand2 ${arg_l})
	filePath1=$(parseEnv ${arg_l})
fi

echo ""
echo "# Jmeter"
echo ${daemon} run --rm --name jmeter --network host -i -v $\{PWD\}:$\{PWD\} -w $\{PWD\} ${jmeterDocker} \
	${jmxName} -l ${testFolder}/jmeter.jtl -j ${testFolder}/jmeter.log ${subCommand} -o ${rDir} -e
echo ""

eval ${daemon} run --rm --name jmeter --network host -i -v ${PWD}:${PWD} -w ${PWD} ${jmeterDocker} ${jmxName} -l ${testFolder}/jmeter.jtl -j ${testFolder}/jmeter.log ${subCommand} -o ${rDir} -e

generatePngCommand=''
if [[ ${flag_g} -ne 0 ]]; then
	generatePngCommand=$(createGeneratePngCommand ${arg_g})
	IFS=',' read -ra a <<< "$generatePngCommand"

	for value in "${a[@]}"
	do
		echo ""
		echo "# JMeterPluginsCMD.sh"
		echo ${daemon} run --rm -v $\{PWD\}/${testFolder}:/tmp --entrypoint bash ${jmeterDocker} /opt/apache-jmeter-5.4.1/bin/JMeterPluginsCMD.sh $value
		echo ""

		eval ${daemon} run --rm -v $\{PWD\}/${testFolder}:/tmp --entrypoint bash ${jmeterDocker} /opt/apache-jmeter-5.4.1/bin/JMeterPluginsCMD.sh $value
	done
fi

echo ""
echo "==== jmeter.log ===="
echo "See jmeter log in ${testFolder}/jmeter.log"
echo ""

echo "==== Raw Test Report ===="
echo "See Raw test report in ${testFolder}/${jmxName}.jtl"
echo ""

echo "==== HTML Test Report ===="
echo "See HTML test report in ${rDir}/index.html"
echo ""

if [[ ! -z "$generatePngCommand" ]]; then
	echo "==== Generate PNG ===="
	echo "See generate png in ${testFolder}"
	for entry in "${testFolder}"/*.png
	do
		echo "$entry"
	done
	echo ""
fi

if [[ ${enbaleTargz} == "true" ]]; then
	echo "==== Tar report ===="

	n=""
	if [[ ! -z "$filePath1" ]]; then
		n="${testFolder}-$(date '+%Y%m%d_%H%M')${filePath1}.tar.gz"
	else
		n="${testFolder}-$(date '+%Y%m%d_%H%M').tar.gz"
	fi

	mv run-${testFolder}.log ${testFolder}
	echo "See Tar file in ${n}"
	tar czf ${n} ${testFolder}/*.log ${testFolder}/*.png ${testFolder}/*.jtl ${rDir}
fi
