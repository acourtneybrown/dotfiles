// See https://github.com/johnste/finicky/wiki/Configuration-(v3)

function openInFirefoxContainer(containerName, url) {
  console.log('opening in ' + containerName);
  return `ext+container:name=${containerName}&url=${encodeURIComponent(
    url.toString()
  )}`;
}

function containsQueryParam(search, param) {
  if (search) {
    search = search.slice(1) // trim the leading ?
    console.log(search)
    const params = search.split('&')
    console.log(params)
    return params.includes(param)
  }
  return false
}

const bundleIdsForHarmony = new Set(["com.logitech.myharmony"])

export default {
  defaultBrowser: "Firefox",
  rewrite: [
    {
      // Redirect all urls to use https
      match: (url) => {
        console.log('checking for http')
        return url.protocol === "http:"
      },
      url: (url) => {
        console.log('switch to https');
        url.protocol = "https:";
        return url;
      }
    },
    {
      match: (url) => {
        console.log('logging url')
        console.log(JSON.stringify(url, null, 2));
        return false;
      },
      url: (url) => url,
    },
    {
      match: [
        (url) => containsQueryParam(url.search, "op_vault=Cara"),
      ],
      url: (url) => openInFirefoxContainer("Cara", url),
    },
    {
      match: [
        (url) => containsQueryParam(url.search, "op_vault=CB"),
      ],
      url: (url) => openInFirefoxContainer("CB", url),
    },
    {
      match: [
        finicky.matchHostnames([
          "govzw.com",
        ]),

        (url) => containsQueryParam(url.search, "op_vault=Joint"),
        (url) => containsQueryParam(url.search, "op_vault=Kids%20RO"),
      ],
      url: (url) => openInFirefoxContainer("Joint", url),
    },
    {
      match: [
        finicky.matchHostnames([
          /nytimes\.com/,
          /wsj\.com/,
          "my.asu.edu",
        ]),

        (url) => containsQueryParam(url.search, "op_vault=Jenny"),
      ],
      url: (url) => openInFirefoxContainer("Jenny", url),
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

        (url, { opener }) => {
          console.log(opener.bundleId)
          return bundleIdsForHarmony.has(opener.bundleId)
        },

        (url) => containsQueryParam(url.search, "op_vault=Adam"),
        (url) => containsQueryParam(url.search, "op_vault=Adam%20@%20Work"),
        (url) => containsQueryParam(url.search, "op_vault=Private"),
      ],
      url: (url) => openInFirefoxContainer("Adam", url),
    },
    // TODO: consider https://github.com/johnste/finicky/wiki/Configuration-ideas#open-zoom-links-in-zoom-app-with-or-without-password
  ],
  handlers: [
    {
      match: [
        /zoom\.us/
      ],
      browser: "us.zoom.xos",
    }
  ]
};
