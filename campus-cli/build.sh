#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
if [ -n "${JAVA_HOME:-}" ]; then
    JAVAC="$JAVA_HOME/bin/javac"
    JAR="$JAVA_HOME/bin/jar"
else
    JAVAC=javac
    JAR=jar
fi
mkdir -p target/classes
find src/main/java -name '*.java' | sort > target/main-sources.txt
"$JAVAC" --release 21 -encoding UTF-8 -d target/classes @target/main-sources.txt
"$JAR" --create --file target/campus-cli.jar --main-class com.example.campus.CampusApplication -C target/classes .
echo '构建完成：target/campus-cli.jar'
