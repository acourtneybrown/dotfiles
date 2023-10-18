// See https://github.com/johnste/finicky/wiki/Configuration

function openInFirefoxContainer(containerName, urlString) {
  return `ext+container:name=${containerName}&url=${encodeURIComponent(
    urlString
  )}`;
}

function contains1pId(urlSearch) {
  for (const id of meContainerIds) {
    if (urlSearch.includes(`${id}=${id}`)) {
      return true
    }
  }
  return false
}

function remove1pId(urlString) {
  result = urlString
  for (const regex of meUrlSearchRegex) {
    result = result.replace(regex, "")
  }
  return result
}

const noContainerHosts = new Set(['duckduckgo.com', 'www.google.com', 'www.amazon.com', 'wikipedia.org'])
const bundleIdsFor1p = new Set(["com.agilebits.onepassword7", "com.1password.1password"])
const bundleIdsForHarmony = new Set(["com.logitech.myharmony"])
const bundleIdsForAlfred = new Set(["com.runningwithcrayons.Alfred"])
const meContainerIds = [
  {%@@ for id in firefox_me_ids.split() @@%}
    {{@@ id @@}},
  {%@@ endfor @@%}
]
const meUrlSearchRegex = [
  {%@@ for id in firefox_me_ids.split() @@%}
    new RegExp("[?&]?" + {{@@ id @@}} + "=" + {{@@ id @@}}),
  {%@@ endfor @@%}
]

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
          "login.docker.com",
          "lookerstudio.google.com",
          "metabase.confluent.io",
          "signin.aws.amazon.com",
          "status.zoom.us",

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
    {%@@ elif personal @@%}
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

        "https://www.amazon.com/alexa-privacy/apd/rvh",

        ({ opener, url }) => {
          if (bundleIdsFor1p.has(opener.bundleId)) {
            return true
          }
          if (bundleIdsForHarmony.has(opener.bundleId)) {
            return true
          }

          if (bundleIdsForAlfred.has(opener.bundleId)) {
            return !noContainerHosts.has(url.host) || contains1pId(url.search)
          }
          return false
        },
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Me", remove1pId(urlString));
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
