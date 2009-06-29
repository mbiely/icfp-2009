#!/bin/sh

#by now this shellscript is small, but it will get much bigger in future - trust me

SCHANIDIR="disassembler-from-joe"
BAERLIDIR="simulator"

GENERALSCHANIEXE="./runner"
GENERALBAERLIEXE="./sim.opt"

#this is only valid for ME on TI18!!!!!!!!!!!!!!!!!!!!!
TMPDIR="/tmp/hoscherei"
OUTPUTDIR="/homes/icfp/hoscherei"

BINTRACEOUTPUTDIR=$OUTPUTDIR/bintraces
EMPTRACEOUTPUTDIR=$OUTPUTDIR/emptraces

#compares two float values
#returns 1 (first arg bigger) / 0 (equal) / -1 (second val bigger)
#SCORECOMPARE="perl -le '$ta = sprintf(\"%020.15f\", $ARGV[0]);$tb = sprintf(\"%020.15f\", $ARGV[1]);print $ta cmp $tb;'"
SCORECOMPARE="perl floatcompare.pl"
      mv $TMPDIR/${problem}00${scenario}.baerli.emp $EMPTRACEOUTPUTDIR/${problem}00${scenario}.$BAERLIPOINTS.baerli.emp


#generate hoschereiverzeichnisse für outputsi
mkdir -p $BINTRACEOUTPUTDIR $EMPTRACEOUTPUTDIR $TMPDIR


#rebuild executables
make --directory $SCHANIDIR all > /dev/null
make --directory $BAERLIDIR all > /dev/null




for problem in 1 2 3 4; do
  for scenario in 1 2 3 4; do

    echo "running scenario ${problem}00${scenario}"


    PROBLEMSCHANIEXE=$GENERALSCHANIEXE$problem


    echo "evaluating schani..."
    cd $SCHANIDIR &> /dev/null
    SCHANIPOINTS=`$PROBLEMSCHANIEXE -s ${problem}00${scenario} -d $TMPDIR/${problem}00${scenario}.schani.emp -t $TMPDIR/${problem}00${scenario}.schani.osf    | grep score | awk '{print $3}'`
    cd - &> /dev/null
    echo "schani scored $SCHANIPOINTS points."


    echo "evaluating baerli..."
    cd $BAERLIDIR &> /dev/null
    BAERLIPOINTS=`$GENERALBAERLIEXE -s ${problem}00${scenario} | grep "final points" | awk '{print $3}'`
    mv ${problem}00${scenario}.emp $TMPDIR/${problem}00${scenario}.baerli.emp
    mv ${problem}00${scenario}.osf $TMPDIR/${problem}00${scenario}.baerli.osf
    cd - &> /dev/null
    echo "baerli scored $BAERLIPOINTS points."


    if [ `$SCORECOMPARE $SCHANIPOINTS $BAERLIPOINTS` -gt 0 ] 
    then
      #schani war besser
      echo "therefore, using schani's solution for ${problem}00${scenario}. (sorry baerli ;( )"
      tar -C $EMPTRACEOUTPUTDIR -jcf ${problem}00${scenario}.$SCHANIPOINTS.schani.emp.tar.bz2 $TMPDIR/${problem}00${scenario}.schani.emp &> /dev/null
      mv $TMPDIR/${problem}00${scenario}.schani.osf $BINTRACEOUTPUTDIR/${problem}00${scenario}.$SCHANIPOINTS.schani.osf 
    else
      #baerli war besser
      echo "therefore, using baerli's solution for ${problem}00${scenario}. (sorry schani ;( )"
      tar -C $EMPTRACEOUTPUTDIR -jcf ${problem}00${scenario}.$BAERLIPOINTS.baerli.emp.tar.bz2 $TMPDIR/${problem}00${scenario}.baerli.emp &> /dev/null
      mv $TMPDIR/${problem}00${scenario}.baerli.osf $BINTRACEOUTPUTDIR/${problem}00${scenario}.$BAERLIPOINTS.baerli.osf
    fi
    # clean up tmpdir
    rm $TMPDIR/* &> /dev/null






  done
done








