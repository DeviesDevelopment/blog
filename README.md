# blog

## Requirements

- [Hugo CLI](https://gohugo.io/getting-started/installing)

## How to

This repository uses git submodules for hugo themes. To clone the repo, you must either:

- Run git clone with an additional flag: `git clone --recurse-submodules https://github.com/DeviesDevelopment/blog`
- Run `git submodule update --init --recursive` after cloning the repository

### Write new post

From the repository root, run `hugo new posts/my-title.md`.

This will create a new file in `content\posts\my-title.md`, wwhere you can write your content.

### Run server locally

From the repository root, run `hugo server -D` and navigate to [http://localhost:1313](http://localhost:1313) in your web browser.
