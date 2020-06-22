# Go development @ github
export GOPROXYUSER={{@@ env['octofactory_username'] @@}}
export GOPROXYPASS={{@@ env['octofactory_password'] @@}}
export GOPROXY="https://${GOPROXYUSER}:${GOPROXYPASS}@{{@@ env['octofactory_host'] @@}}/api/go/github-go,https://proxy.golang.org,direct"
export GONOPROXY="*github.com/github/*"
export GONOSUMDB="*github.com/github/*"
export GOPRIVATE='*github.com/github/*'
export GOPATH=`go env GOPATH`
