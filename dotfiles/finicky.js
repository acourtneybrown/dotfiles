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
    {%@@ if personal @@%}
    {
      match: [
        finicky.matchHostnames([
          "bazelbuild.slack.com",
          "gaming.amazon.com",
          "i.cvs.com",
          "l.klara.com",
          "login.docker.com",
          "meet.google.com",
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
        /^https:\/\/.*\.myworkday\.com\/confluent/,
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
        finicky.matchHostnames([
          "govzw.com",
        ]),

        {%@@ for id in firefox_joint_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}

        {%@@ for id in firefox_kids_ro_ids.split() @@%}
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
        finicky.matchHostnames([
          /nytimes\.com/,
          /wsj\.com/,
          "my.asu.edu",
        ]),

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
        {%@@ for id in firefox_adam_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}

        {%@@ for id in firefox_adam_work_ids.split() @@%}
          /{{@@ id @@}}={{@@ id @@}}/,
        {%@@ endfor @@%}

        {%@@ for id in firefox_private_ids.split() @@%}
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
