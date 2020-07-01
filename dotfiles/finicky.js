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
        /^https:\/\/dev\.azure\.com\/mseng.*$/,

        finicky.matchHostnames([
          "team.githubapp.com",
          "nines.githubapp.com",
          "janky.githubapp.com",
          "githubber.tv",
          "github.zoom.us",
          "applications.zoom.us",
          "aka.ms"
        ])
      ],
      browser: "Google Chrome"
    },
    {
      match: [ /^https:\/\/github.com\/acourtneybrown\/.*$/ ],
      browser: "Safari"
    }
  ]
};
