## Steps for a new release
- Bump version in `NetTime.podspec`.
- Bump version in `README.md`.
- In `CHANGELOG.md`, create a section for the new version and move changes from
  the master section there.
- Run `pod lib lint` and make sure it succeeds without errors or wannings.
- Check in all changes in git.
- Make a new tag for the version number.
- Push all changes and tag to GitHub and make a pull request.
- Make sure CI is green.
- Test the PR branch with a SwiftPM project using TOMLDeserializer.
- Merge the PR. Make sure the version tag is preserved when this happens.
- Create a GitHub release from the new version tag. Paste in content of
  corresponding change log.
- Run `pod trunk push`.
