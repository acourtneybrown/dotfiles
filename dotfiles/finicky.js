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
          "confluentinc.semaphoreci.com",
          "jenkins.confluent.io",
          "jfrog.io",
          "metabase.confluent.io",
          "www.golinks.io",
        ]),

        /github.com\/confluentinc/,
        /https:\/\/go\//,
       ],
      browser: "Google Chrome"
    },
    {
      match: [
        finicky.matchHostnames([
          "govzw.com",
        ]),
        /^https:\/\/github.com\/acourtneybrown\/.*$/,
      ],
      browser: "Safari"
    },
    {
      match: ({ sourceBundleIdentifier }) =>
        sourceBundleIdentifier.endsWith("com.agilebits.onepassword7-helper"),
      browser: "Safari"
    }
  ]
};
