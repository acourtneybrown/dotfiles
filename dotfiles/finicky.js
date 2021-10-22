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
          "app.geekbot.com",
          "confluent-tools.datadoghq.com",
          "confluent.jfrog.io",
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
          /sumologic.com/,
        ]),

        /applications.zoom.us\/slack\/api\/call\/callback/,
        /github.com\/.*confluentinc/,
        /travis-ci.org\/github\/confluentinc/,
       ],
      browser: "Google Chrome"
    },
    {
      match: [
        finicky.matchHostnames([
          "govzw.com",

          /nytimes.com/,
          /wsj.com/,
        ]),
        /^https:\/\/github.com\/acourtneybrown\/.*$/,
      ],
      browser: "Safari"
    },
    {
      match: ({ opener }) => {
        // finicky.log(opener.bundleId);
        return opener.bundleId && opener.bundleId === "com.agilebits.onepassword7"
      },
      browser: "Safari"
    }
  ]
};
