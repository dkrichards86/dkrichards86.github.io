---
layout: post
author: dkrichards86
title: Database Normalization and You
description:  >-
    Database normalization is the process of breaking related data into discrete,
    maintainable sections. In this article, I will explain normalization through
    real world examples and plain English.
---
Data comes to us in a variety of shapes, sizes andformats. In its raw form, data
is unruly, a garbled mess of unusable insight. Within data however lie
relationships and connections, a network of disjointed information that tell a
cohesive story. In order to gain knowledge from data, we need to make sense of
the mangled network.

Normalization seeks to model relationships in data in a way that is easy to
follow, easy to combine, and easy to maintain. Normalization is the act of
splitting apart a disjointed web of datum and organizing it into a reasonable
structure, guided by a set of rules pertaining to the relationships of attributes.
These rules, outlined by relational database pioneer Edgar F. Codd, are referred
to as the “Normal Forms”.

## First Normal Form
In First Normal Form, all attributes within a record set are indivisible and
atomic. No one field can contain more than one piece of related information.
Let’s take a look at an example. Consider the following relation:

| staff\_num | staff\_name | staff\_email |
|-|-|-|
| 123 | John Doe | john.doe@domain.com,jdoe@ajob.org |
| 456 | Jane Doe | jane@domain.com,jane@anemployer.net |
| 789 | Robert Tables | littlebobbytables@domain.com |

Since the staff_email column contains multiple comma-delimited entries, it is
not atomic. You would not, for example, be able to easily select distinct
employee email addresses.

To shift this to First Normal Form, we need to split the staff_email column
from the relation, leaving two related relations.

| staff\_num | staff\_name |
|-|-|
| 123 | John Doe |
| 456 | Jane Doe |
| 789 | Robert Tables |

| staff\_num | staff\_email |
|-|-|
| 123 | john.doe@domain.com |
| 123 | jdoe@anemployer.org |
| 456 | jane@domain.com|

By moving emails to a separate relation, we can now, through a join or subquery,
get unique records containing a staff member and their associated email
addresses.

Note: As an aside, the above relation also adheres to Third Normal Form.

## Second Normal Form
For a relation to be in Second Normal Form, non-prime attributes (ancillary
columns) must be dependent on the candidate key in its entirety, not just a
subset thereof. In other words, a field must relate back the every attribute
of the candidate key, not just one or two attributes.

Consider the following team/role relation, with a candidate key (project\_num, team).

| project\_num | team | role | team\_hq |
|-|-|-|-|
| 123 | Team 1 | User Interface | New York |
| 123 | Team 2 | Database Design | San Francisco |
| 465 | Team 2 | API Development | San Francisco |

Values in the team\_hq column are only dependent on the team attribute of the
candidate key. They are in no way dependent on the project number. To move this
to Second Normal Form, we need to split the team_hq column from the relation,
leaving two related relations.

| project\_num |team | role |
|-|-|-|
| 123 | Team 1 | User Interface|
| 123 | Team 2 | Database Design |
| 465 | Team 2 | API Development |
| 789 | Team 2 | User Interface|

| team | team\_hq |
|-|-|
| Team 1 | New York |
| Team 2 | San Francisco |

We can still apply joins to easily retrieve the team’s headquarters, but we no
longer have a maintenance burden of updating each record associated with a team
if a team were to move.

## Third Normal Form
For a relation to be in Third Normal Form, a table must first be in Second Normal
Form, and all attributes must be determined only by a candidate key. In other
words, a field must be directly attributable to the candidate key. The relation
will be free of superfluous content.

Consider the following staff/manager relation, with a surrogate key (staff\_num).

| staff\_num |staff\_name | manager\_num | manager\_name|
|-|-|-|-|
| 123 | John Doe | 987 | Sara Manageer |
| 456 | Jane Doe | 654 | Jay Deboss |
| 789 | Robert Tables | 321 | Elle Hefe|

While staff\_name and manager\_num both directly relate to the surrogate key
staff\_num, manager\_name does not.

To move this to Third Normal Form, we need to split the manager\_name column from
the relation, leaving two related relations.

| staff\_num |staff\_name | manager\_num |
|-|-|-|
| 123 | John Doe | 987 |
| 456 | Jane Doe | 654 |
| 789 | Robert Tables | 321 |

| manager\_num | manager\_name |
|-|-|
| 987 | Sara Manageer |
| 654 | Jay Deboss |
| 321 | Elle Hefe|

We can still apply joins to easily retrieve the manager’s name, but we no longer
have a maintenance burden of updating names when staff members change direct
reports.

## Boyce-Codd Normal Form
For a relation to be in Boyce-Codd Normal Form, a table must first be in Third
Normal Form. Additionally, it must be free of reverse dependencies. In other
words, if two attributes on a relation have a Many:One relationship, we can
infer the many from the one.

Note: Boyce-Codd Normal Form is somewhere between Third Normal and Fourth Normal
Forms. Think of it as Three-and-a-Half Normal Form.

Consider the following staff member to skill and language relation, with a
surrogate key (staff\_num).

| staff\_num | language | skill |
|-|-|-|
| 123 | JavaScript | User Interface|
| 123 | JavaScript | Data Visualization |
| 456 | Python| Data Science |
| 789 | Python| API Development |

In our hypothetical company, management has required that all User Interface and
Data Visualization activities are done using JavaScript. All Data Science and API
Development are done in Python. While we know that a language can have multiple
components, a skill is attributed to one and only one language. We can glean the
language from the skill.

| staff\_num | skill |
|-|-|
| 123 | User Interface|
| 123 | Data Visualization |
| 456 | Data Science |
| 456 | Data Visualization |
| 789 | API Development |


| language | skill |
|-|-|
| JavaScript | User Interface|
| JavaScript | Data Visualization |
| Python| Data Science |
| JavaScript | Data Visualization |
| Python| API Development |

Through joins we can learn the team member’s language from their skill.

## Fourth Normal Form
For a relation to be in Fourth Normal Form, a table must first be in Third Normal
Form. The relationship should be free of multivalued dependencies. In other words,
querying should not leave any ambiguity or imply any results.

Note: Fourth Normal Form is not regularly encountered.

Consider the following project staffing relation. Let’s assume a project will
need one team member to fill each role. In this case, each project has an
assigned staff member, as well as an assigned project need. There is no
relationship between project need and staff member.

| project\_num | staff\_num | project\_need |
|-|-|-|
| 12345 | 123 | User Interface |
| 12345 | 456 | Data Science |
| 46578 | 789 | API Development |
| 78901 | 123 | Data Visualization |

If we were to query project 12345, we’d receive tuples that imply a staff member
fulfills a specific role. We’d get (132, User Interface) and (456, Data Science).

To make this less ambiguous and remove an implications, split it into two relations.

| project\_num | staff\_num |
|-|-|
| 12345 | 123 |
| 12345 | 456 |
| 46578 | 789 |
| 78901 | 123 |


| project\_num | project\_need |
|-|-|
| 12345 | User Interface|
| 12345 | Data Science |
| 45678 | API Development |
| 78901 | Data Visualization |

We can then join the two tables on project number to get staffing and project need.

## Fifth Normal Form
For a relation to be in Fifth Normal Form, a table must first be in Fourth Normal
Form. When rejoining decomposed structures, we should not gain or lose any
attributes. So when we query with part of the table, we shouldn’t gain or lose
any additional records.

_Note: Fifth Normal Form is not regularly encountered._

Consider the following project staffing relation. In this case, a project has
assigned staff, and with them come certain abilities. All three attributes
combine to form a candidate key.

| project\_num | staff\_num | project\_asset |
|-|-|-|
| 12345 | 123 | User Interface|
| 12345 | 456 | Data Science |
| 45678 | 789 | API Development |
| 78901 | 123 | Data Visualization |

Problems arise when we try to add new entries to the relation. If we added a
need for Data Visualization to 45678, we’d have a missing staff number attribute.
If we were to add a new staff member with two skills, we must add two separate entries.

We can get around this by joining three separate relations. One staff to project,
one skill to staff, and one skill to project.

| project\_num | staff\_num |
|-|-|
| 12345 | 123 |
| 12345 | 456 |
| 45678 | 789 |
| 78901 | 123 |


| staff\_num | project\_asset |
|-|-|
| 123 | User Interface|
| 456 | Data Science |
| 789 | API Development |
| 123 | Data Visualization |


| project\_num | project\_asset |
|-|-|
| 12345 | User Interface|
| 12345 | Data Science |
| 45678 | API Development |
| 78901 | Data Visualization |

---

### So what form should I use?
The normal forms are nothing more than guiding principles to database structure.
They are not hard, fast rules or requirements. When you’re developing a database,
adherence to normal forms is highly dependent on the project and data at hand,
and is entirely up to developers’ discretion

---

_This article originally appeared as a Software Engineering Birds of a Feather
presentation in the RTI International Center for Data Science. Content was
tailored to a mixed crowd of data scientists and software engineers and may
include reference some analytical techniques or applications. I originally published
this article to Medium before transitioning to a self-hosted solution._