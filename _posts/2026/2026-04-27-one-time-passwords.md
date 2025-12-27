---
layout: post
title: "How One-Time Passwords work"
description: >-
  Those six-digit codes from your authenticator app aren't magic. They're generated using clever
  algorithms that solve the problem of secure authentication without requiring a network connection.
tags: [authentication, security, cryptography]
---

You probably use two-factor authentication codes every day. You pull out your phone, open Google
Authenticator or Authy, and type in a six-digit code that changes every 30 seconds. But have you
ever wondered how those codes work?

Those codes aren't random. They're generated using algorithms called HOTP and TOTP that solve a real
problem: how do you prove identity without sending secrets over the network?

The genius is in the math. Both you and the server can generate the same code at the same time using
a shared secret, but an attacker watching network traffic can't predict future codes even if they
intercept one.

## The Counter Problem

HOTP (HMAC-based One-Time Password) was the original solution. The idea is simple: you and the
server share a secret key, and you both keep track of a counter. To generate a code, you combine the
secret key and counter using HMAC, then truncate the result to get a human-readable number.

Every time you generate a code, you increment the counter. The server does the same. As long as your
counters stay in sync, you'll generate identical codes.

The algorithm takes your shared secret and the current counter value, runs them through HMAC-SHA1 to
get a 20-byte hash, then uses a clever truncation process to extract a 6-digit number from that
hash. The same inputs always produce the same output, so both sides get identical codes.

HOTP works, but it has a synchronization problem. If you generate a code but don't use it, your
counter gets out of sync with the server. Generate a few codes while testing, and suddenly your
authenticator doesn't work. The server has to implement "look-ahead" windows to handle counter
drift, which adds complexity.

## Time as a Counter

TOTP (Time-based One-Time Password) elegantly solves the synchronization issue by using time as the
counter. Instead of manually incrementing numbers, both sides use the current timestamp divided by a
time window (usually 30 seconds).

When you generate a TOTP code at 3:00:15 PM, you're really using counter value 1736789632 (the Unix
timestamp divided by 30). The server calculates the same counter value and generates the same code.
No manual synchronization needed.

The time window is crucial. Using 30-second windows means codes change every half minute, giving
users reasonable time to enter them while limiting how long each code remains valid. A 30-second
window strikes the right balance between usability and security.

The beauty is that slight clock differences don't break the system. Servers typically accept codes
from the current time window plus or minus one window on each side. If your phone's clock is 15
seconds off, it still works.

## Why This Approach Works

The security comes from the shared secret and the unpredictability of HMAC output. Even if an
attacker intercepts a code, they can't work backward to figure out the secret or predict future
codes. HMAC is designed so that knowing the output doesn't reveal anything useful about the input.

The time-based approach means codes have built-in expiration. Each code is only valid for its time
window, so intercepted codes become useless quickly. An attacker would need to use a stolen code
within 30-60 seconds, which is a narrow window for most attacks.

TOTP also works offline. Your phone doesn't need internet access to generate codes because it has
everything it needs: the shared secret and the current time. This makes it more reliable than
SMS-based authentication, which depends on cellular service.

## Implementation Details

The shared secret is typically exchanged through QR codes when you set up two-factor authentication.
That QR code contains the secret key, usually encoded in base32 format, along with metadata like the
issuer name and account identifier.

Most authenticator apps support multiple hash algorithms (SHA1, SHA256, SHA512) and different code
lengths (6 or 8 digits), though 6-digit SHA1-based codes remain the standard for compatibility
reasons.

The truncation process that converts the 20-byte HMAC output to a 6-digit number is clever. It uses
dynamic truncation based on the last nibble of the hash to pick an offset, then extracts a 4-byte
value and converts it to decimal. This ensures the output is evenly distributed across the possible
code space.

## When to Use Each

HOTP makes sense when you need event-based authentication rather than time-based. Hardware tokens
that generate codes on button press often use HOTP because they don't have reliable clocks.

TOTP is better for most applications because it doesn't require synchronization state. Users can
generate codes freely without worrying about getting out of sync. The time dependency isn't usually
a problem since most devices have reasonably accurate clocks.

For web applications, TOTP is almost always the right choice. It's what Google Authenticator, Authy,
and similar apps implement. Users are familiar with the workflow, and the 30-second rotation
provides good security without being annoying.

## The Bigger Picture

HOTP and TOTP solve the fundamental problem of proving identity without transmitting secrets. They
turn a shared secret into a stream of temporary passwords that can't be reused or predicted.

This makes them perfect for two-factor authentication. Even if someone steals your password, they
still need access to your authenticator device to generate valid codes. And even if they somehow
intercept a code, it expires quickly.

Understanding how these algorithms work helps you appreciate why authenticator apps are more secure
than SMS codes and why the 30-second rotation isn't just a UX quirk. It's a carefully designed
system that balances security, usability, and practical implementation constraints.
