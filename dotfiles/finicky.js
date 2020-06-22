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
        /^https:\/\/github\.com\/github.*$/,
        finicky.matchHostnames([ "team.githubapp.com", "nines.githubapp.com" ])
      ],
      browser: "Google Chrome"
    },
    {
      match: [ /^https:\/\/github.com\/acourtneybrown\/.*$/ ],
      browser: "Safari"
    },
    {
      match: finicky.matchHostnames([ "applications.zoom.us" ]),
      browser: "Google Chrome"
    },
    {
      match: finicky.matchHostnames([ "aka.ms" ]),
      browser: "Google Chrome"
    }
  ]
};
