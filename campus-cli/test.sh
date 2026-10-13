#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
sh build.sh
if [ -n "${JAVA_HOME:-}" ]; then
    JAVAC="$JAVA_HOME/bin/javac"
    JAVA="$JAVA_HOME/bin/java"
else
    JAVAC=javac
    JAVA=java
fi
mkdir -p target/test-classes
find src/test/java -name '*.java' | sort > target/test-sources.txt
"$JAVAC" --release 21 -encoding UTF-8 -cp target/classes -d target/test-classes @target/test-sources.txt
"$JAVA" -cp target/classes:target/test-classes com.example.campus.MarketServiceTest
