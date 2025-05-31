// See https://github.com/johnste/finicky/wiki/Configuration-(v3)

function openInFirefoxContainer(containerName, urlString) {
  return `ext+container:name=${containerName}&url=${encodeURIComponent(
    urlString
  )}`;
}

const bundleIdsForHarmony = new Set(["com.logitech.myharmony"])

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
      match: [
        /op_vault=Cara/,
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Cara", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        /op_vault=CB/,
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("CB", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        finicky.matchHostnames([
          "govzw.com",
        ]),

        /op_vault=Joint/,
        /op_vault=Kids%20RO/,
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Joint", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        finicky.matchHostnames([
          /nytimes\.com/,
          /wsj\.com/,
          "my.asu.edu",
        ]),

        /op_vault=Jenny/,
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Jenny", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        finicky.matchHostnames([
          "bazelbuild.slack.com",
          "gaming.amazon.com",
          "i.cvs.com",
          "l.klara.com",
          "login.docker.com",
          "meet.google.com",
          "myactivity.google.com",
          "notcharlie.slack.com",
          "pbj-dogs.slack.com",
          "xooglerco.slack.com",
        ]),

        /^https:\/\/calendly\.com\/omaras\//,
        /^https:\/\/github\.com\/{{@@ github_account @@}}(\/|$)/,
        /^https:\/\/github\.com\/NotCharlie(\/|$)/,

        "https://www.amazon.com/alexa-privacy/apd/rvh",

        ({ opener }) => {
          return bundleIdsForHarmony.has(opener.bundleId)
        },

        /op_vault=Adam/,
        /op_vault=Adam%20@%20Work/,
        /op_vault=Private/,
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Adam", urlString);
      },
      browser: "Firefox",
    },
    // TODO: consider https://github.com/johnste/finicky/wiki/Configuration-ideas#open-zoom-links-in-zoom-app-with-or-without-password
    {
      match: [
        /zoom\.us/
      ],
      browser: "us.zoom.xos",
    }
  ]
};
