# Count Git Edits #

Quick and dirty Perl script to count the number of line additions/subtractions per contributor.
Considers all remote branches, not just `master`.
Considers each contributor to be a unique name/email combination.

## Usage ##

```console
./count_git_edits.pl <<repository_location>> <<starting_commit_point>> <<ending_commit_point>>
```

...where:

- `<<repository_location>>` is a path to a repository.
- `<<starting_commit_point>>` specifies a starting time when to start looking for commits.
  This is passed directory to the `--since` option of `git log`; see details about possibilities in `man gitrevisions`.
- `<<ending_commit_point>>` specifies a starting time when to stop looking for commits.
  This is passed directory to the `--until` option of `git log`; see details about possibilities in `man gitrevisions`.
