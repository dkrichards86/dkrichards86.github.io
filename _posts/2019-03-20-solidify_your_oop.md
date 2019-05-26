---
layout: post
author: dkrichards86
title:  SOLIDify your Object Oriented Programming
description: >-
    SOLID is a mnemonic acronym for guiding principles to Object Oriented
    programming. In this article, I will explain SOLID through real world
    examples and plain English.
---
SOLID is a mnemonic acronym for guiding principles to Object Oriented programming.
The goal of SOLID is to encourage more extensible and maintainable code. The SOLID
principles were introduced in Bob Martin's 2000 article 
[Design Principles and Design Patterns](http://www.cvc.uab.es/shared/teach/a21291/temes/object_oriented_design/materials_adicionals/principles_and_patterns.pdf){:target="_blank" rel="noopener noreferrer"}.

SOLID Principles cover the following concepts:
- Single Responsibility Principle (SRP)
- Open/Closed Principle (OCP)
- Liskov Substitution Principle (LSP)
- Interface Segregation Principle (ISP)
- Dependency Inversion Principle (DIP)

It seems like articles explaining SOLID principles go one of two ways- they are
either incredibly over-simplified or they are so replete with technical jargon
that they are hard to follow. The goal of this article is to find a happy medium
between too simple and too complex, explaining the SOLID Principles through real
world examples and plain English.

## Single Responsibility Principle (SRP)
The Single Responsibility Principle states that an object should do one thing,
and only one thing. All attributes and methods of a class should be directly
related to the object being instantiated.

To explain this without jargon, let's consider a software developer. It's a
developers job to make features, debug issues, and refactor code. It is not a
software developer's job to make breakfast. In accordance with Single
Responsibility Principle, `makeFrenchToast()` should not exist as a method on
`SoftwareDeveloper`.

Consider the following `Person` class:

{% highlight javascript %}
class Person {
    constructor(name, phoneNumber) {
        this.setName(name);
        this.setPhoneNumber(phoneNumber);
    }
    
    setName(name) {
        this.name = name;
    }
    
    setPhoneNumber(phoneNumber) {
        if (this.validatePhoneNumber(phoneNumber)) {
            this.phoneNumber = phoneNumber;
        } else {
            this.phoneNumber = null;
        }
    }
    
    validatePhoneNumber(phoneNumber) {
        const phoneRegex = '/^[0-9()-]+$/';
        return phoneRegex.test(phoneNumber);
    }
}
{% endhighlight %}

Here, we accept a name and phone number as constructor arguments. Before we set 
the `Person` object's phone number, we run it through a simple regular expression,
checking for digits, hyphens and parenthesis.

So what's the Problem? While a person has a phone number, they are not
responsible for ensuring the validity of that number. It is simply assigned
by the telecommunications provider and assumed valid. Our `Person` should not be
responsible for making sure their phone number is valid.

Instead of validating phone number as though it were a characteristic that
defines a `Person`, treat the phone number as its own object. The shape of a
phone number is a fundamental characteristic of that number.

By moving phone number to it's own class, we can clearly define and validate its
characteristics independent of a `Person`. A `Person` object's phone number becomes
an instance of this defined `PhoneNumber` class, so the Person is no longer
defined by this validation. Each class is only responsible for maintaining its
own characteristics.

{% highlight javascript %}
class PhoneNumber {
    constructor(phoneNumber) {
        this.setPhoneNumber(phoneNumber);
    }
    
    setPhoneNumber(phoneNumber) {
        if (this.validatePhoneNumber(phoneNumber)) {
            this.phoneNumber = phoneNumber;
        } else {
            this.phoneNumber = null;
        }
    }
    
    validatePhoneNumber(phoneNumber) {
        const phoneRegex = '/^[0-9()-]+$/';
        return phoneRegex.test(phoneNumber);
    }
}

class Person {
    constructor(name, phoneNumber) {
        this.setName(name);
        this.setPhoneNumber(phoneNumber);
    }
    
    setName(name) {
        this.name = name;
    }
    
    setPhoneNumber(phoneNumber) {
        const phoneObj = new PhoneNumber(phoneNumber);
        this.phoneNumber = phoneObj.phoneNumber;
    }
}
{% endhighlight %}

## Open/Closed Principle (OCP)
According to the Open/Closed Principle (OCP), a class should be open for
extension, but closed for modification. That is, modification of a class should
be done though object inheritance, not code editing. Since making a source change
applies to all instances of the object, it could cause some serious issues in a
codebase.

As an example, imagine a Data Scientist. The role of a Data Scientist is to
glean new information from data by applying scientific methodologies and rigor.
If the definition of Data Scientist were changed to "all Blockchain, all the time",
it would have a significant impact on the Data Science community. To avoid this,
we would instead make a new role based on Data Scientist, but with more emphasis
on Blockchain.

Let's take another look at our previous `PhoneNumber` class.

{% highlight javascript %}
class PhoneNumber {
    // ...
    
    validatePhoneNumber(phoneNumber) {
        const phoneRegex = '/^[0-9()-]+$/';
        return phoneRegex.test(phoneNumber);
    }
}
{% endhighlight %}

Since the phone number regular expression only checks for digits, hyphens and
parenthesis, any other pattern would fail. These phone numbers would be valid:
- 212-555-2368
- (212)555-2368
- (212)-555-2368

Unfortunately, these would also pass validation:
- 21255523682125552368
- 2-125552368
- 2-1-2-5-5-5-2-3-6-8

While these would not:
- (212) 555-2368
- 212.555.2368
- 212 555 2368

We can fix this by using a more robust RegEx. Instead of `/^[0-9()-]+$/`,
let's use `/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/`. Support for
country codes, area codes, white space, hyphens, optional groups. You name it,
we support it.

{% highlight javascript %}
class PhoneNumber {
   // ...
    
    validatePhoneNumber(phoneNumber) {
        const phoneRegex = '/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/';
        return phoneRegex.test(phoneNumber);
    }
}
{% endhighlight %}

But wait, there's a problem. What happens if an instance of PhoneNumber was, for
whatever reason, reliant on the weak regular expression? By changing the regular
expression, we have officially broken the code.

Instead of modifying PhoneNumber directly, let's make a new derived object,
`ReliablePhoneNumber`, overriding the simple Regular Expression with our more
bulletproof validator. Instances of PhoneNumber relying on a weak RegEx will
still work, but other implementations can take advantage of the stronger RegEx.

{% highlight javascript %}
class ReliablePhoneNumber(PhoneNumber) {
    validatePhoneNumber(phoneNumber) {
        const phoneRegex = '/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/';
        return phoneRegex.test(phoneNumber);
    }
}
{% endhighlight %}

By implementing, `ReliablePhoneNumber` in this way, we've taken an advantage of
PhoneNumber's extensibility (openness) without modifying its source (and
violating it's closedness).

## Liskov Substitution Principle (LSP)
Liskov Substitution Principle states that if object S is a subtype of `T`, then any
object of `T` can be replaced with `S`. Liskov Substitution Principle is named after
its creator, Barbara Liskov. Liskov is a pioneer in computer science, doing AI
and NLP in the late 1960s and early 1970s.

As a real world example, consider automobiles. We've all seen the "Motor Vehicle
Only" signs on highways. This permits cars, trucks and motorcycles to operate on
motorways. In this case, Cars, Trucks and Motorcycles are all subtypes of the Motor 
Vehicle type. Since the sign says "Motor Vehicle", all subtype is implicitly
allowed. The inverse of this is the ubiquitous "Compact Only" parking space.
Only the compact car subtype can park there, not the greater motor vehicle type.

In our previous exercise, we noted that implementations of `PhoneNumber` reliant
on the simple regular expression would break once we change to a more robust
regular expression. The solution was to extend `PhoneNumber`, making a
`ReliablePhoneNumber` class. Since `ReliablePhoneNumber` is a subtype of `PhoneNumber`,
we can use `ReliablePhoneNumber` anywhere the base `PhoneNumber` would be implemented.

We can convert…

{% highlight javascript %}
class Person {
    // ...
    
    setPhoneNumber(phoneNumber) {
        const phoneObj = new PhoneNumber(phoneNumber);
        this.phoneNumber = phoneObj.phoneNumber;
    }
}
{% endhighlight %}

… into…

{% highlight javascript %}
class Person {
    // ...
    
    setPhoneNumber(phoneNumber) {
        const phoneObj = new ReliablePhoneNumber(phoneNumber);
        this.phoneNumber = phoneObj.phoneNumber;
    }
}
{% endhighlight %}

… and all is still right in the world.

## Interface Segregation Principle (ISP)
### Definition
Instead of opting for large all-encompassing interfaces, break them into smaller,
more discrete components. This helps avoids bloat and unnecessary confusion.

If you need to contact a colleague, you can do so in-person, over the phone,
through email, and on Slack. These are communication interfaces. Not everyone
uses Slack however, so this is an unnecessary interface for a lot of people.
Rather than merging in-person, phone, email and Slack into a single interface, 
we could split these into 4 discrete interfaces and apply them as required. One
person may use email and Slack only, while another may prefer in-person.
Separating interfaces communicates only the applicable communication channels,
preventing attempted communications through unused mediums.

(Bad) Example

{% highlight java %}
public interface WorkerInf {
    public void doNLP;
    public void doDeployment;
    public boolean knowsBlockchain;
    public boolean canKubernetes;
}

public class DataScientist implements WorkerInf {
    // Java Stuff...
    
    public void doNLP() {
        logger.log("I lemmatized the vector space into n-dimensions.");
    }

    public void doDeployment() throws WhatDidIDoException {
        throw new WhatDidIDoException("Umm the data center is on fire.");
    }

    public boolean knowsBlockchain() {
        logger.log("It's a revolutionary technology!!1!");
        return true;
    }

    public boolean canKubernetes() {
        logger.log("No one knows Kubernetes");
        return false;
    }
}

public class SoftwareEngineer implements WorkerInf {
    // Java Stuff...
    
    public void doNLP() throws IOnlyKnowTFIDF {
        throw new IOnlyKnowTFIDF("WHY DOESN'T IT RECOGNIZE MY NAMED ENTITIES?!");
    }

    public void doDeployment() {
        logger.log("I used Terraform to provision the cloud!");
    }

    public boolean knowsBlockchain() {
        logger.log("It's a slow database...");
        return false;
    }

    public boolean canKubernetes() {
        logger.log("No one knows Kubernetes");
        return false;
    }
}
{% endhighlight %}

### What's Wrong?
In this example, we have methods on the SoftwareEngineer that don't apply to the
software engineer. I should never do NLP because I'll TF/IDF everything. When you
only have a hammer, everything looks like nail.

### Better Approach
Instead of having one single interface handle everything, break it into smaller
pieces.

{% highlight java %}
public interface DataScientistInf {
    public void doNLP;
    public boolean knowsBlockchain;
}

public class DataScientist implements DataScientistInf {
    // Java Stuff...
    
    public void doNLP() {
        logger.log("I lemmatized the vector space into n-dimensions.");
    }

    public boolean knowsBlockchain() {
        logger.log("My stock just went up 30,000%!");
        return true;
    }
}

public interface SoftwareEngineerInf {
    public void doDeployment;
    public boolean canKubernetes;
}

public class SoftwareEngineer implements SoftwareEngineerInf {
    // Java Stuff...
    
    public void doDeployment() {
        logger.log("I used Terraform to provision the cloud!");
    }

    public boolean canKubernetes() {
        logger.log("Really, no one knows Kubernetes");
        return false;
    }
}
{% endhighlight %}

Now `DataScientist` can focus on NLP and `SoftwareEngineer` can deploy.

## Dependency Inversion Principle (DIP)
Dependency Inversion involves separating code into layers of abstraction, with
layers only interacting with things at or around their layer. That is, high level
code should stay high level, not getting involved in the minutia of implementation.
Data passed to one abstraction should not depend on another abstraction. Each
abstraction should be a black box.

A generalist Data Scientist should not be expected to master machine learning,
NLP and business analytics. They should delegate machine learning
responsibilities to a Machine Learning Specialist, NLP to a NLP guru, and
Business Analytics to a Business Analyst. This is essence creates a layer of
abstraction. Once the generalist Data Scientist hands some data to a specialist,
the specialist is free to mutate and mold as required, independent of the other
specialists. In this case, the generalist Data Scientist is responsible for
orchestrating tasks.

Consider the following:

{% highlight javascript %}
class ProjectManager {
    manageDatabaseTask() {
        addIndex();
        makeJoin();
        executeQuery();
    }
  
    manageFrontendTask() {
        addComponent();
        applyStyles();
        doBrowserTests();
    }
    
    manageBackendTask() {
        makeEndpoint();
        handleSession();
    }
    
    manageProject() {
        manageBackendTask();
        manageDatabaseTask();
        manageFrontendTask();
    }
}
{% endhighlight %}

Here, the `ProjectManager` is doing tasks associated with frontend, backend and
the database. `ProjectManager` will be overwhelmed with work and incredibly stressed.

To spare our project manager's sanity, let's off-load all specific work to
specialists. Our `ProjectManager` can delegate work to specialists instead of
dealing with individual tasks.

{% highlight javascript %}
class DatabaseTaskLead() {
    manageDatabaseTask() {
        addIndex();
        makeJoin();
        executeQuery();
    }
}

class FrontendTaskLead() {
    manageFrontendTask() {
        addComponent();
        applyStyles();
        doBrowserTests();
    }
}

class BackendTaskLead() {
    manageBackendTask() {
        makeEndpoint();
        handleSession();
    }
}


class ProjectManager {
    manageProject() {
        BackendTaskLead.manageBackendTask();
        DatabaseTaskLead.manageDatabaseTask();
        FrontendTaskLead.manageFrontendTask();
    }
}
{% endhighlight %}

By delegating authority, `ProjectManager` can manage the project as a whole. Each
task lead is responsible for executing the specifics of that task.

---

_This article originally appeared as a Software Engineering Birds of a Feather
presentation in the RTI International Center for Data Science. Content was
tailored to a mixed crowd of data scientists and software engineers and may
include reference some analytical techniques or applications. I originally published
this article to Medium before transitioning to a self-hosted solution._