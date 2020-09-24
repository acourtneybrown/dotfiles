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
          /githubapp.com/,
          /zoom.us/,

          "githubber.tv",
          "aka.ms",
          "thehub.github.com",
          "app.datadoghq.com",
          "github.rewatch.tv"
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
