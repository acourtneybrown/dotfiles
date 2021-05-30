# shellcheck disable=SC2148

if [[ -f /usr/libexec/java_home ]]; then

  function jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v"$version")
    java -version
  }

  # Setting versions of JDK
  alias j7='jdk 1.7'
  alias j8='jdk 1.8'
  alias j9='jdk 9'
  alias j10='jdk 10'
  alias j11='jdk 11'
  alias j12='jdk 12'
fi
