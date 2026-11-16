# Dependencies
- Zig `0.17.0` or newer
- Zine `v0.14.1`, built from source by this project. Run `zig build` to install it to `zig-out/bin/zine`.
  - The build uses forks of Zine and its highlighting packages, so ```` ```sql ```` code blocks highlight pipe syntax (`|>`). The forks are on the `pipe-sql` branch of [xiexingwu/zine](https://github.com/xiexingwu/zine), [xiexingwu/flow-syntax](https://github.com/xiexingwu/flow-syntax) and [xiexingwu/tree-sitter](https://github.com/xiexingwu/tree-sitter). The grammar itself is the `pipe-syntax` branch of [xiexingwu/tree-sitter-sql](https://github.com/xiexingwu/tree-sitter-sql).
  - When upgrading, also update `.zine_version` in `zine.ziggy` and the `.version` passed to Zine in `build.zig`.

## Updating the SQL grammar
Each fork pins the one below it, so a grammar change has to be passed up the
chain in this order:
1. In `tree-sitter-sql`, commit to `pipe-syntax`. Then update `pipe-syntax-dist`
   to match it, with the generated `src/` committed (`git add -f src`), and push
   both branches.
2. In `tree-sitter`, on `pipe-sql`, point the `tree-sitter-sql` submodule at the
   new `pipe-syntax-dist` commit and push. Then start the "Release tarball"
   workflow on `pipe-sql` from the Actions tab, and wait for it to publish a
   release.
3. In `flow-syntax`, on `pipe-sql`, set the `tree_sitter` URL in
   `build.zig.zon` to that release's `source.tar.gz`, and push.
4. In `zine`, on `pipe-sql`, set the `flow_syntax` URL to the new
   `flow-syntax` commit, and push.
5. Here, set the `zine` URL in `build.zig.zon` to the new `zine` commit.

Run `zig fetch <url>` to get the hash for each URL. If `zig build` then reports
a hash mismatch for a package, delete that package's `.tar.gz` from
`~/.cache/zig/p/` and build again.

# Development
```sh
./zine
```

# Release
The site is served by Porkbun from the `release` branch. To publish, commit 
changes on `main`, then run:
```sh
./release.sh
```
The script builds the site, mirrors it into the `public/` worktree of the
`release` branch, shows the diff, and pushes after confirmation.

## Pages built by other projects
Some pages, such as the Path of Exile atlas tree at `/poe/atlas/`, are built by
another project. Their builds live in `assets/` and are listed as folders in
`.static_assets` in `zine.ziggy`, so Zine copies them unchanged to the same path
in both the dev server and `zine release`.
**These builds are git ignored**, so a fresh
clone needs them copied in before the site builds.

Build the project with the sub-path it will be served at:
```sh
pnpm run build --base /poe/atlas/
```
Then replace the old build in `assets/` with the new one:
```sh
rm -rf ./assets/poe/atlas
cp -R <path/to/build> ./assets/poe/atlas
```

Link to these pages from content with `$link.siteAsset("poe/atlas/index.html")`.
