---
layout: post
title: "How Git Actually Works"
description: >-
  Git seems like magic until you understand what's happening under the hood. It's simpler than you'd
  think - just objects, references, and a clever content-addressing scheme.
tags: [git, version-control, engineering]
---

I've been using Git for over a decade, but I only really understood how it worked a few years ago.
Like most developers, I learned the commands I needed and treated the rest as magic. `git add`,
`git commit`, `git push` - they worked, so why dig deeper?

Understanding Git's internals changed how I think about version control entirely. It's not actually
that complicated. Git is essentially a content-addressable filesystem with a few clever abstractions
on top. Once you see how the pieces fit together, a lot of Git's seemingly weird behavior starts
making perfect sense.

## It's All About Objects

Git stores everything as objects in a simple key-value database. There are four types of objects:
blobs, trees, commits, and tags. Each object gets a unique SHA-1 hash based on its content. That
hash is both the object's identifier and a guarantee that the content hasn't changed.

Blobs store file content. When you `git add` a file, Git creates a blob object containing that
file's content. The blob doesn't know what the file was called or where it lived. It's just raw
content with a hash.

Trees represent directories. A tree object contains a list of other objects (blobs and other trees)
along with their names and permissions. This is how Git reconstructs your directory structure. Trees
can reference other trees, creating a hierarchy that matches your filesystem.

Commits tie everything together. A commit object points to a tree (representing the state of your
entire project at that moment), references one or more parent commits, and includes metadata like
author, timestamp, and commit message. Commits form the history chain that Git tracks.

Tags are just named references to other objects, usually commits. They're how Git implements things
like release markers.

## Content Addressing

The genius is in content addressing. Git doesn't store files by name or location. It stores them by
content hash. If two files have identical content, they get the same hash and Git only stores one
copy. This happens automatically across your entire repository history.

This means Git deduplication is perfect and free. If you have the same file in multiple branches, or
the same content in different files, Git stores it once. The savings compound over time, especially
for projects with lots of binary assets or generated files.

Content addressing also makes Git incredibly robust. You can't have silent corruption because
changing even one bit of an object changes its hash. Git would immediately know something was wrong.

## The Index

The index (also called staging area) is a binary file that tracks which version of each file should
go into the next commit. It's Git's way of letting you build commits incrementally.

When you `git add` a file, Git creates a blob object for that file's content and updates the index
to point to that blob. The index is essentially a draft of your next commit. When you `git commit`,
Git creates a tree object based on the current index and a commit object pointing to that tree.

This is why you can make changes to a file after staging it and those new changes won't be included
in the next commit. The index points to the blob that was created when you ran `git add`, not the
current file content.

## Branches Are Just References

Git branches aren't copies or directories. They're just text files containing SHA-1 hashes. The file
`.git/refs/heads/main` contains the hash of the commit that the main branch currently points to.
That's it.

When you create a new branch, Git creates a new text file with the current commit hash. When you
switch branches, Git updates your working directory to match the tree referenced by that branch's
commit and updates a special reference called HEAD to point to the new branch.

This is why Git branches are so cheap to create. You're just creating a 40-character text file.
Switching branches is fast because Git only needs to update the files that changed between the two
commits.

HEAD is a special reference that points to the current branch (or directly to a commit in detached
HEAD state). It's how Git knows which branch you're on and where new commits should go.

## How Commits Build History

Each commit object contains the hash of its parent commit (or parents, in the case of merge
commits). This creates a linked list of commits going back to the initial commit. Git history is
just following these parent pointers backward.

When you create a new commit, Git creates a commit object that points to the current branch's commit
as its parent, then updates the branch reference to point to the new commit. The old commit doesn't
go anywhere. It's still in the object database, still reachable through the new commit's parent
pointer.

This is why Git makes it easy to see any previous state of your project. Every commit is a complete
snapshot, and Git can reconstruct any previous state by following the parent chain and building the
appropriate tree structure.

## What Git Add Really Does

`git add` does three things. It creates a blob object for the file's current content (if one doesn't
already exist). It updates the index to reference that blob for that file path. And it leaves your
working directory unchanged.

The file in your working directory and the blob in Git's object database are now completely
independent. You can modify the working file without affecting the staged version. This is why
`git diff` shows differences between your working directory and the index, while `git diff --cached`
shows differences between the index and the last commit.

## What Happens During Commit

When you commit, Git creates a tree object based on the current index. This tree represents the
entire state of your project. Git then creates a commit object pointing to that tree, with the
current branch's commit as the parent.

Finally, Git updates the branch reference to point to the new commit. Your working directory stays
the same, but now there's a new commit in the history chain.

## Why This Design Works

Git's object model elegantly solves several problems. Content addressing gives you automatic
deduplication and integrity checking. Immutable objects mean you can never accidentally corrupt
history. Cheap branching encourages experimentation and parallel development.

The separation between the object database, index, and working directory gives you fine-grained
control over what gets committed and when. You can stage parts of files, review what you're about to
commit, and build commits incrementally.

Understanding that branches are just pointers explains why Git operations like merge and rebase work
the way they do. They're manipulating the commit graph and updating references, not copying or
moving files around.

## Making Git Less Mysterious

Once you understand that Git is just objects and references, most of the complexity disappears.
Commands that seemed arbitrary start making sense. You can predict what Git will do based on how the
operations affect the object database and references.

This mental model also helps with troubleshooting. When something goes wrong, you can reason about
what state Git is in and what operations might fix it. You understand why `git reset` has different
modes and what each one does to the working directory, index, and branch references.

Git isn't magic. It's just a really well-designed database with a few powerful abstractions.
Understanding how it works under the hood makes you a more effective Git user and helps you
appreciate why it's become the dominant version control system.
