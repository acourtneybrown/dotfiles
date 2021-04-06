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
          "a.goodtime.io",
          "app.firehydrant.io",
          "confluent-tools.datadoghq.com",
          "confluent.askspoke.com",
          "confluent.okta.com",
          "confluent.slack.com",
          "confluent.zoom.us",
          "confluentinc.atlassian.net",
          "confluentinc.semaphoreci.com",
          "hire.lever.co",
          "jenkins.confluent.io",
          "jfrog.io",
          "metabase.confluent.io",
          "www.golinks.io",
          "zoom.us",

          /^go$/,
          /confluent-internal\.io/,
          /confluent.io/,
          /confluent\.cloud/,
          /cultureamp.com/,
        ]),

        /github.com\/confluentinc/,
       ],
      browser: "Google Chrome"
    },
    {
      match: [
        finicky.matchHostnames([
          "govzw.com",

          /wsj.com/,
        ]),
        /^https:\/\/github.com\/acourtneybrown\/.*$/,
      ],
      browser: "Safari"
    },
    {
      match: ({ opener }) =>
        opener.bundleId.endsWith("com.agilebits.onepassword7-helper"),
      browser: "Safari"
    }
  ]
};
