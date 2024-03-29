# Blog

Blog by [Devies](https://www.devies.se/).

Visit the blog at [deviesdevelopment.github.io/blog](https://deviesdevelopment.github.io/blog/).

## Getting started

### Prerequisites

- [Hugo CLI](https://gohugo.io/getting-started/installing)

### Write new post

Clone the repository, navigate to the repository root and run `./new-post.sh "Some epic title"`.

This will create a new file in `content/posts/YYYY-MM-DD_some-epic-title.md`, where you can write your content.

Don't know what to write about? Have a look in the [topics list](topics.md)!

### Run server locally

If you want to preview how your post will look like, you can start a local server.

 1. Make sure you have [Hugo CLI](https://gohugo.io/getting-started/installing) installed.
 2. Update submodules: `git submodule update --init --recursive`
    - Required since git submodules is used for Hugo themes
 3. From the repository root, run `hugo server -D`
 4. Visit [http://localhost:1313/blog](http://localhost:1313/blog) in your web browser!

## Spell check

    npm install -g yaspeller

    yaspeller content

Configure in `.yaspellerrc`.
