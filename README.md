# Dependencies
- Zine `v0.10.2-dev.2+aa43d44`

# Release
Contents of the static website are served on the `release` branch.
Easiest way to release:
```sh
git worktree add public release
zine release --install public # release to public by default anywyas
```
```sh
cd public
git add -i
git commit
git push

```
