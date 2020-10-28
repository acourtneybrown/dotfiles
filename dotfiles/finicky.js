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
        /confluent.io/,
        /confluent.zoom.us/,
        /confluentinc.atlassian.net/,
        /github.com\/confluentinc/,
        /jfrog.io/
      ],
      browser: "Google Chrome"
    },
    {
      match: [ /^https:\/\/github.com\/acourtneybrown\/.*$/ ],
      browser: "Safari"
    }
  ]
};
