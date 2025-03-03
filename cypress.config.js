const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    env: {
      apiUrl: 'http://localhost:3000/api/v1'
    }
  },
  component: {
    devServer: {
      framework: 'react',
      bundler: 'webpack'
    }
  },
  viewportWidth: 1280,
  viewportHeight: 720
}) 