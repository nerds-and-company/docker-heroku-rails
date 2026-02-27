# Docker image for Heroku Rails

Usage: `FROM nerdsandcompany/docker-heroku-rails`

## Specifications

- Heroku 22
- Ruby 3.2.2
- Bundler 2.3.10
- Node 24.11.1
- Yarn 1.22.19
- Chrome
- ChromeDriver

## Versioning & Releases

Images are automatically built and published to [Docker Hub](https://hub.docker.com/r/nerdsandcompany/docker-heroku-rails) via Docker Hub's automated build integration with this repository.

Two build rules are configured:

- The `latest` tag is built automatically from the `master` branch on every push.
- A versioned image tag is built automatically for every Git tag pushed to the repository.

Tags follow the format `{ruby-version}-node{node-version}`, for example:
```
3.4.8-node24.11.1
```

When releasing a new version:

1. Push a Git tag to this repository (e.g. `git tag 3.4.8-node24.11.1 && git push origin 3.4.8-node24.11.1`).
2. Create a corresponding [GitHub Release](https://github.com/nerds-and-company/docker-heroku-rails/releases) for the tag to document what changed.
3. Docker Hub will automatically pick up the tag and build the versioned image.

If a fix is needed without changing the Ruby or Node version, the tag can be moved to a new commit and force-pushed:
```
git tag -f 3.4.8-node24.11.1 && git push --force origin 3.4.8-node24.11.1
```

This will trigger a new Docker Hub build, updating the existing versioned image in place. Remember to update the GitHub Release notes accordingly.
