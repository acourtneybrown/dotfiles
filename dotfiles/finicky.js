// See https://github.com/johnste/finicky/wiki/Configuration

function openInFirefoxContainer(containerName, urlString) {
  return `ext+container:name=${containerName}&url=${encodeURIComponent(
    urlString
  )}`;
}

module.exports = {
  defaultBrowser: "Firefox",
  rewrite: [
    {
      // Redirect all urls to use https
      match: ({ url }) => url.protocol === "http",
      url: { protocol: "https" },
    },
  ],
  handlers: [
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
          "device.sso.us-west-2.amazonaws.com",
          "docs.google.com",
          "hire.lever.co",
          "ironcladapp.com",
          "jenkins.confluent.io",
          "lookerstudio.google.com",
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
    {%@@ if confluent @@%}
      browser: "Google Chrome",
    {%@@ endif @@%}
    {%@@ if personal @@%}
      url: ({ urlString }) => {
        return openInFirefoxContainer("CFLT", urlString);
      },
      browser: "Firefox",
    {%@@ endif @@%}
    },
    {
      match: [
        finicky.matchHostnames([
          "my.asu.edu",
        ])
      ],
      // url: ({ urlString }) => {
      //   return openInFirefoxContainer("Jenny", urlString);
      // },
      // browser: "Firefox"
      browser: "Google Chrome",
    },
    {%@@ if personal @@%}
    {
      match: [
        finicky.matchHostnames([
          "govzw.com",

          /nytimes.com/,
          /wsj.com/,
        ]),

        /^https:\/\/github.com\/{{@@ github_account @@}}\/.*$/,

        ({ opener }) => {
          // finicky.log(opener.bundleId);
          return opener.bundleId
            && (opener.bundleId === "com.agilebits.onepassword7" || opener.bundleId === "com.1password.1password")
        },
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Me", urlString);
      },
      browser: "Firefox",
    },
    {%@@ endif @@%}
    {
      match: [
        /zoom\.us/
      ],
      browser: "us.zoom.xos",
    }
  ]
};
