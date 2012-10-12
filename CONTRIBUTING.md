Contributing to zoppo - because you're a nice person, aren't you?
=================================================================
This project would exist even without all of its users and contributors,
because only @meh and @shurizzle actually use this crippled thing.

Nonetheless help will always be appreciated and welcome.

Issue reporting
---------------
- Check that the issue has not already been reported.
- Check that the issue has not already been fixed in the latest code.
- Open an issue with a clear title and description in grammatically correct,
  complete sentences.

Pull Request
------------
- Read [how to properly contribute to open source projects on GitHub][1].
- Use a topic branch to easily amend a pull request later, if necessary.
- Write [good commit messages][2] (but don't worry, if it's bad it will be
  amended by the person that merges the commit)
- Squash commits on the topic branch before opening a pull request (but again,
  don't really worry, we can do it for you)
- Use the same coding style and spacing.
- Open a [pull request][4] that relates to but one subject with a clear title
  and description in grammatically correct, complete sentences.

Plugins
-------
- A *README.md* must be present.
- Large functions and helpers must be placed in a *functions* directory.
- Functions that take arguments should have completion.

Other than that, if you're working on a plugin that you plan to maintain you
can create a repository where you maintain it and open an issue asking for it
to be added.

Unless the plugin makes more sense as being merged into another one, it will be
added as a submodule and you'll be free to work on it.

Keep in mind that if you break something the plugin will be removed. Every
submodule sync will be reviewed by someone to ensure that.

Prompts
-------
- A screenshots section must be present in the file header.
- The pull request description must have [embedded screenshots][5].

Coding style
============
- Always put at the end of the file with a new line above the vim modeline you
  can find in any other file in the project (and if you don't use vim, follow
  the instructions in the modeline).
- Use single quotes when there's nothing to expand.
- Use `$name` when there are no modifiers for the expansion.
- Don't quote command, function and variable names (for example when using
  `zstyle -[abs]`).
- Helpers should be named with namespaces (for example `history:stats` to show
  history statistics).

[1]: http://gun.io/blog/how-to-github-fork-branch-and-pull-request
[2]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[4]: https://help.github.com/articles/using-pull-requests
[5]: http://daringfireball.net/projects/markdown/syntax#img
