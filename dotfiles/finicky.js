// See https://github.com/johnste/finicky/wiki/Configuration

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
          "i.cvs.com",
          "login.docker.com",
          "meet.google.com"

          /nytimes\.com/,
          /wsj\.com/,
        ]),

        /^https:\/\/github\.com\/{{@@ github_account @@}}(\/|$)/,
        /^https:\/\/github\.com\/NotCharlie(\/|$)/,

        "https://www.amazon.com/alexa-privacy/apd/rvh",

        ({ opener }) => {
          return bundleIdsForHarmony.has(opener.bundleId)
        },
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Me", urlString);
      },
      browser: "Firefox",
    },
    {%@@ endif @@%}
    {
      // Confluent-related sites
      match: [
        finicky.matchHostnames([
          "confluent.okta.com",
        ]),
       ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("CFLT", urlString);
      },
      browser: "Firefox",
    },
    {%@@ if personal @@%}
    {
      match: [
        {%@@ for id in firefox_cara_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Cara", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        {%@@ for id in firefox_cb_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Carter", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        {%@@ for id in firefox_joint_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Joint", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        {%@@ for id in firefox_jenny_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}
      ],
      url: ({ urlString }) => {
        return openInFirefoxContainer("Jenny", urlString);
      },
      browser: "Firefox",
    },
    {
      match: [
        {%@@ for id in firefox_all_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}
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
