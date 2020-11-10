// See https://github.com/johnste/finicky/wiki/Configuration

module.exports = {
  defaultBrowser: "browserosaurus",
  rewrite: [
    {
      // Redirect all urls to use https
      match: ({ url }) => url.protocol === "http",
      url: { protocol: "https" }
    }
  ],
  handlers: [
    {
      // Work-related sites
      match: [
        finicky.matchHostnames([
          "confluent-tools.datadoghq.com",
          "confluent.askspoke.com",
          "confluent.io",
          "confluent.okta.com",
          "confluent.zoom.us",
          "confluentinc.atlassian.net",
          "go",
          "jenkins.confluent.io",
          "jfrog.io",
        ]),
        /github.com\/confluentinc/,
       ],
      browser: "Google Chrome"
    },
    {
      match: [ /^https:\/\/github.com\/acourtneybrown\/.*$/ ],
      browser: "Safari"
    }
  ]
};
