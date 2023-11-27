#!/usr/bin/env bash
src="ahollocou--scoda"
out="$HOME/Logs/$src$1.log"
ulimit -s unlimited
printf "" > "$out"

# Download scoda
if [[ "$DOWNLOAD" != "0" ]]; then
  rm -rf $src
  git clone https://github.com/wolfram77/$src
  cd $src
fi

# Convert graph to binary format, run scoda, and clean up
runScoda() {
  stdbuf --output=L printf "Converting $1 to $1.edges ...\n"                   | tee -a "$out"
  lines="$(node process.js header-lines "$1")"
  tail -n +$((lines+1)) "$1" > "$1.edges"
  stdbuf --output=L benchmark_code/build/scoda -f "$1.edges" -o "out.log" 2>&1 | tee -a "$out"
  stdbuf --output=L printf "\n\n"                                              | tee -a "$out"
  rm -rf "$1.edges"
}

# Build and run scoda
cd benchmark_code
mkdir build
cd build
cmake ..
make -j32
cd ../..

# Run scoda on all graphs
runAll() {
# runScoda "$HOME/Data/web-Stanford.mtx"
runScoda "$HOME/Data/indochina-2004.mtx"
runScoda "$HOME/Data/uk-2002.mtx"
runScoda "$HOME/Data/arabic-2005.mtx"
runScoda "$HOME/Data/uk-2005.mtx"
runScoda "$HOME/Data/webbase-2001.mtx"
runScoda "$HOME/Data/it-2004.mtx"
runScoda "$HOME/Data/sk-2005.mtx"
runScoda "$HOME/Data/com-LiveJournal.mtx"
runScoda "$HOME/Data/com-Orkut.mtx"
runScoda "$HOME/Data/asia_osm.mtx"
runScoda "$HOME/Data/europe_osm.mtx"
runScoda "$HOME/Data/kmer_A2a.mtx"
runScoda "$HOME/Data/kmer_V1r.mtx"
}

# Run scoda 5 times
for i in {1..5}; do
  runAll
done

# Signal completion
curl -X POST "https://maker.ifttt.com/trigger/puzzlef/with/key/${IFTTT_KEY}?value1=$src$1"
