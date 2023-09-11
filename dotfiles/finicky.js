// See https://github.com/johnste/finicky/wiki/Configuration

function openInFirefoxContainer(containerName, urlString) {
  return `ext+container:name=${containerName}&url=${encodeURIComponent(
    urlString
  )}`;
}

function contains1pId(urlSearch) {
  // finicky.log(urlSearch)
  for (const id of meContainerIds) {
    if (urlSearch.includes(`${id}=${id}`)) {
      return true
    }
  }
  return false
}

function remove1pId(urlString) {
  finicky.log(urlString)
  result = urlString
  for (const regex of meUrlSearchRegex) {
    finicky.log(`checking ${regex}`)
    result = result.replace(regex, "")
  }
  finicky.log(result)
  return result
}

const noContainerHosts = new Set(['duckduckgo.com', 'www.google.com', 'www.amazon.com', 'wikipedia.org'])
const bundleIdsFor1p = new Set(["com.agilebits.onepassword7", "com.1password.1password"])
const bundleIdsForAlfred = new Set(["com.runningwithcrayons.Alfred"])
const meContainerIds = [
  {%@@ for id in firefox_me_ids.split() @@%}
    {{@@ id @@}},
  {%@@ endfor @@%}
]
const meUrlSearchRegex = [
  {%@@ for id in firefox_me_ids.split() @@%}
    new RegExp("[?&]?" + {{@@ id @@}} + "=" + {{@@ id @@}}),
    // new RegExp({{@@ id @@}} + "=" + {{@@ id @@}}),
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
          // finicky.log(opener.bundleId);
          // finicky.log(url.host)
          if (bundleIdsFor1p.has(opener.bundleId)) {
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
