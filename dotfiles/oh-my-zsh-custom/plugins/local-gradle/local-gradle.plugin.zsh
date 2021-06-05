# shellcheck disable=SC2148

# Locally installed gradle
alias gl='/usr/local/share/gradle/bin/gradle'
alias gd='ps ax | grep -i [g]radledaemon'

# \$1 is an argument in the awk script
# shellcheck disable=SC2142
alias gdpids="ps ax | grep -i [g]radledaemon | awk '{print \$1;}'"

# Gradle build related
alias proof="git diff-tree --no-commit-id --name-only -r HEAD | grep subprojects | cut -d\/ -f 2 | sort -u | groovy -e \"def p = [] ; System.in.eachLine { p.add it.split('-').toList().withIndex().collect { s, i -> i?s.capitalize():s }.join() } ; def tasks = ((['sanityCheck']+p.collect { it+':test '+it+':intTest' }).join(' ')); System.err.println('Running '+tasks); println tasks \" | xargs ./gradlew --continue --parallel"
