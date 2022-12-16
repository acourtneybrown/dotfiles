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
    {%@@ if confluent @@%}
    {
      // Confluent-related sites
      match: [
        finicky.matchHostnames([
          "a.goodtime.io",
          "app.firehydrant.io",
          "app.geekbot.com",
          "app.glean.com",
          "circleci.com",
          "confluent-tools.datadoghq.com",
          "confluent.askspoke.com",
          "confluent.okta.com",
          "confluent.slack.com",
          "confluentinc.atlassian.net",
          "docs.google.com",
          "hire.lever.co",
          "jenkins.confluent.io",
          "metabase.confluent.io",
          "status.zoom.us",
          "signin.aws.amazon.com",

          /^go$/,
          /confluent-internal\.io/,
          /confluent.io/,
          /confluent\.cloud/,
          /cultureamp.com/,
          /golinks.io/,
          /semaphoreci.com/,
          /sumologic.com/,
        ]),

        /applications.zoom.us\/slack\/api\/call\/callback/,
        /confluent.zoom.us\/rec\/play/,
        /confluent.zoom.us\/saml/,
        /github.com\/.*confluentinc/,
        /github.com\/semaphoreci/,
        /jetbrains.com/,
        /travis-ci.org\/github\/confluentinc/,
       ],
      browser: "Google Chrome"
    },
    {%@@ endif @@%}
    {
      match: [
        finicky.matchHostnames([
          "my.asu.edu",
        ])
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
        /^https:\/\/github.com\/{{@@ github_account @@}}\/.*$/,
      ],
      browser: "Safari"
    },
    {
      match: ({ opener }) => {
        // finicky.log(opener.bundleId);
        return opener.bundleId
          && (opener.bundleId === "com.agilebits.onepassword7" || opener.bundleId === "com.1password.1password")
      },
      browser: "Safari"
    },
    {
      match: [
        /zoom\.us/
      ],
      browser: "us.zoom.xos"
    }
  ]
};
