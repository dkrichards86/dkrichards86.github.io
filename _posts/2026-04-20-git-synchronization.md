---
layout: post
title: "Git Synchronization: Moving History Around"
description: >-
  Understanding how Git moves commits between repositories helps explain why rebasing rewrites
  history, 
  why merge conflicts happen, and what's really going on when you push and pull.
---

In a recent post we covered how Git stores data internally. Now let's talk about how it moves that
data around. Git synchronization is really about copying objects and updating references between
repositories. Understanding this helps explain why some Git operations can be destructive and others
are safe.

## What Push and Pull Actually Do

When you push to a remote repository, you're doing two things. First, Git copies any objects
(commits, trees, blobs) that the remote doesn't have. Second, it updates the remote branch reference
to point to your latest commit.

The copying part is straightforward. Git compares what objects you have locally with what the remote
has and transfers the difference. Since objects are immutable and content-addressed, this is safe
and efficient.

The reference update is where things get tricky. Git will only update a remote reference if your new
commit is a descendant of the current remote commit. This is called a "fast-forward" update. If your
commit isn't a descendant, Git rejects the push because updating the reference would lose commits.

Pull does the reverse. It fetches objects from the remote and updates your local references. But
pull is actually two operations: fetch followed by merge (or rebase, depending on your
configuration).

## Fast-Forward vs Non-Fast-Forward

Fast-forward updates are simple. Your commit has the remote's current commit somewhere in its
ancestry, so moving the remote reference forward doesn't lose any history. The reference just points
to a newer commit in the same chain.

Non-fast-forward situations happen when you and someone else have both made commits since the last
synchronization. Your history has diverged. You have commits they don't have, and they have commits
you don't have. Neither history is a subset of the other.

This is why Git sometimes rejects your pushes with "non-fast-forward" errors. It's not being
difficult. It's protecting against accidentally losing commits by overwriting the remote reference.

## Merging: Creating Convergence

Merge resolves diverged history by creating a new commit with multiple parents. A merge commit
points to both your branch and the branch you're merging, bringing the diverged histories back
together.

When you merge, Git finds the common ancestor of both branches and creates a three-way merge. It
compares the common ancestor with both branch tips and tries to automatically combine the changes.
If the changes don't conflict, Git creates a merge commit that includes both sets of changes.

Merge preserves history exactly as it happened. You can see that branches diverged and later
converged. Every original commit remains unchanged. This is why merge is considered the "safe"
option.

## Rebasing: Rewriting History

Rebase takes a different approach. Instead of creating a merge commit, it rewrites history to make
it look like your changes were made on top of the latest remote changes.

Rebasing works by finding the common ancestor of your branch and the target branch, then replaying
your commits one by one on top of the target. Each of your commits gets rewritten with a new parent,
creating new commit objects with new hashes.

This is why rebase can be dangerous. You're creating new commits and abandoning the old ones. If
anyone else has copies of your original commits, their history will diverge from yours after the
rebase.

## Why Rebase Rewrites Commits

Remember that commit objects include their parent commit hash. When you rebase, you're changing
which commit each of your commits points to as its parent. Since the parent hash is part of the
commit content, changing it creates an entirely new commit object with a new SHA-1 hash.

Your rebased commits contain the same changes (the diff between each commit and its parent), but
they're technically different objects. Git sees them as completely new commits that happen to have
similar content.

## Interactive Rebase: The Swiss Army Knife

Interactive rebase lets you edit history more precisely. You can reorder commits, combine them,
split them, or modify their messages. Under the hood, it's the same rewriting process, but with more
control over what the final history looks like.

Each operation in an interactive rebase creates new commit objects. Even if you only change a commit
message, you get a new commit hash because the message is part of the commit object content.

## When to Use Each Approach

Merge when you want to preserve the true history of how development happened. It shows when branches
diverged and converged, making it easy to understand the context of changes. Merge is safer because
it never loses commits.

Rebase when you want a clean, linear history. It makes your feature branch look like it was
developed on top of the latest main branch, even if that's not how it actually happened. Rebase is
better for code review because each commit represents a logical unit of work without merge noise.

The golden rule is never rebase commits that other people might have. Once you push commits, other
developers might base their work on them. Rebasing those commits creates confusion and potential
conflicts for everyone else.

## Handling Conflicts

Conflicts happen when Git can't automatically merge changes. This occurs when the same lines in the
same files were modified differently in both branches. Git marks the conflicts in your files and
asks you to resolve them manually.

During a merge, you resolve conflicts and create a merge commit. During a rebase, you resolve
conflicts for each commit being replayed. If multiple commits touch the same code, you might resolve
the same conflict several times.

## Remote Tracking Branches

Git maintains local copies of remote branch references called tracking branches. When you fetch, Git
updates these tracking branches to match the remote. Your local branches can then compare against
the tracking branches to see what's changed.

This is why Git can tell you things like "your branch is 3 commits ahead and 2 commits behind
origin/main." It's comparing your local branch reference with the tracking branch reference.

## The Mental Model

Think of Git repositories as independent databases that occasionally synchronize. Each repository
has its own object database and references. Synchronization involves copying objects and negotiating
reference updates.

Push and pull are about keeping these databases in sync. Merge and rebase are about reconciling
diverged history. The key insight is understanding when operations create new objects versus when
they just update references.

Once you see synchronization as object copying and reference updating, Git's behavior becomes
predictable. You can reason about whether an operation is safe, understand why conflicts happen, and
choose the right strategy for your situation.

Git synchronization isn't magic. It's just moving commits around and updating pointers.
Understanding the mechanics helps you use these powerful tools confidently and safely.
