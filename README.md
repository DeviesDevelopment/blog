# blog

Blog by [Devies](https://www.devies.se/).

Visit the blog at [deviesdevelopment.github.io/blog](https://deviesdevelopment.github.io/blog/).

## Requirements

You need to have [Hugo CLI](https://gohugo.io/getting-started/installing) installed.

## Getting started

This repository uses git submodules for hugo themes. To clone the repo, you must either:

- Run git clone with an additional flag: `git clone --recurse-submodules git@github.com:DeviesDevelopment/blog.git`
- Run `git submodule update --init --recursive` after cloning the repository

### Write new post

From the repository root, run `./new-post.sh "Some epic title"`.

This will create a new file in `content/posts/YYYY-MM-DD_some-epic-title.md`, where you can write your content.

### Run server locally

From the repository root, run `hugo server -D` and navigate to [http://localhost:1313](http://localhost:1313) in your web browser.