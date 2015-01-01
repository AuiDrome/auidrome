# AuiDrome

![Pair of Huia](https://upload.wikimedia.org/wikipedia/commons/0/00/Huia_Buller.jpg)

**Aui**: onomatopoeic fragment of the extinct Huia voice (trying to catch its "where-are-you" sound [0]).

**Drome**: a place where people can get in, and from some of them people can also get out.

In the context of a project, a good long project (e.g. a human life, a collective ambition, or a business line) there are **7 basic dromes**:

1. **AuiDrome**: people that are coming soon or that are finally between us. Her or his name should be created using, of course, love, and optionally related to one of the languages of the different cultures of the world (e.g. choosing from Glottolog [1] or ISO 639-3 vocabularies [2]).

2. **AcadoDrome**: people that has started to learn things about the culture or cultures of her or his parents. This *"drome"* has three internal stages: play, learn and grant.


3. **PedaloDrome**: people currently doing their best for the project, working hard for it but also for the pleasure that doing it returns to them.

4. **ByebyeDrome**: farewell from the squad to those who decide to keep growing in other projects. A place to remember those riders and their stuff (twitter, skype, or whatever they choose to keep in contact with us).

5. **RestoDrome**: people who deserves to rest and give to the project whatever they want. They happily still read, hopefully write, and some of them can even keep making amazing things.

6. **RipoDrome**: people that is no longer between us but that their spirit keep pushing us to build a better world.

7. **LoveDrome**: people we love or admire regardless of the *drome* to which they belong (**our affection is more important** than the *drome* where whey should be).

*Auidrome* is supposed to run on a collective or a **personal** server (i think we're not that far from that) and the data of its *dromes* should be easily shared (like the *Smallest Federated Wiki[3]* does) between them.

*Auidrome* is also desired to become *Hyperbooted[4]* to guarantee always **the rights of the user**.

[0] [https://en.wikipedia.org/wiki/Huia#Voice](https://en.wikipedia.org/wiki/Huia#Voice)

[1] [http://datahub.io/dataset/glottolog](http://datahub.io/dataset/glottolog)

[2] [http://datahub.io/dataset/iso-639-3](http://datahub.io/dataset/iso-639-3)

[3] [https://github.com/WardCunningham/Smallest-Federated-Wiki](https://github.com/WardCunningham/Smallest-Federated-Wiki)

[4] [http://hyperboot.org](http://hyperboot.org)

## Think and Shout (and dance if you want:).

The two basic actions anybody (no matter if logged or not) can do on a *drome* are **to think** (great!) and **to shout** (awesome... my parents don't let me do that! :)

*To think* [to think ico](https://raw.githubusercontent.com/AuiDrome/auidrome/master/public/images/think.png) a name or nickname means send it to the server to share it with the people currently connected to that particular *drome*. The technologies involved will be discussed later.

*To shout* [to shout ico](https://raw.githubusercontent.com/AuiDrome/auidrome/master/public/images/shout.png) it will share it as when we think but also store it by the server in its public *tuits* file available in its root with the name *tuits.json* (for example, if we send it to *drome* http://otaony.com:3003 we get it into the http://otaony.com:3003/tuits.json file).

So every *shout* is converted to a *tuit* as soon as is *"heard"* by the server. That means it will have its own web page where more things can be said about *"it"*.

## Login and "to amadrinate"

The basic idea is **amadrinate to login**. *"To amadrinate"* is a very popular verb in the *dromolands* which means **"to know"** something good/cool about that person to be told to anyone interested.

It should not be difficult to find someone to amadrinate so in order to get logged Auidrome force us to do it pushing the **Amadrinate** button on the *tuit* page of the person. We can amadrinate to the same person as many times as needed in order to login if no more *"amadrinable"* new people has appeared on that *drome* (something good if we're trying to login in the Ripodrome;)

If currently we are not part of the *drome* and we think we should, we can get logged also "shouting" our favourite nickname (the one that the people use to call us that is more cool for us) and then pushing the *It's me!* button on *the tuit page*.

## 3 Access Levels & 3 Auidrome Repositories **WARNING: NIY (Not Implemented Yet) stuff**

Auidrome has the three classical levels of access to the data of the user: **public**, **protected** and **private**:

1. **Public**: The *tuits* are public in the *public/tuits.json* file and become *humans* in the *public/tuits* directory ([Iria](data/auidrome/tuits/IRIA.json) for example) when someone *amadrinates* them. Ideally, they will eventually become part of the own repository of the server where that particular *auidrome* is running.

2. People idendified that are currently members of the *pedalodrome* (and even members of the *restodrome*) can see **the protected data** of the user. That info will be stored in a different repository administrated by the collective interested in the project the people is *pedaling* for in the *pedalodrome* (examples of the protected data could be *the email* account or *company phone number* of the user).

3. Only the user (and eventually others that have been granted to have it) have access to the user's **private data**. That info will be in YAR (Yet Another Repository, the private one) and will store data as the personal telephone of the user or the MAC of her or his Smartphone.

## Installation
Application written in Ruby+Sinatra (+ WebSockets to share "auidos" between people simultaneusly connected to the server).

If you want to test it make the next steps:

  1. bundle install
  2. bundle exec ruby app.rb
  3. you should have it ready to go on http://localhost:3003

## Config and run...

A Auidrome site, or *"a drome"*, is launched running the *bin/auidrome.rb* script.

Any *drome* should have its configuration on the *config/dromes* directory.

If *auidrome.rb* runs with no arguments it will use config/dromes/*auidrome*.yml configuration file.

To use a diferent one we have to give it as argument. For instance:

    $ ./bin/auidrome.rb config/dromes/ripodrome.yml

## Origin and Dedications

The project comes from a [Codetail](http://github.com/nando/piidos-compartidos-codetails) that use code from another one (http://github.com/samuelnp/banana-status-codetails) and is desired to be part of ANOTHER ONE MUCH MORE BIGGER that is about Twitter decentralization based on laguages and dialects spoken by the folks that are currently living in our planet ([OTAONY.com](http://OTAONY.com)).

After a personal Hackaton i've been able to finish an "alfa-but-working" first release into the last hours of the Human Rights Day, and i'll update OTAONY.com with a link to it tomorrow morning.

That has already been a great day for those of us who think and care about our rights on the Internet, since http://ind.ie has been able to meet and exceed the goal of raising 100,000 crowdfunded dollars.

Much more important than my economical contribution to that project is for me this shared present that is also for my mother, Ana (though her birthday has finished more than an hour ago... I almost did it! ;). Hope it'll become something joining to any other projects with the same or bigger goals.

## License

*PEEDODROME* is released under the [MIT License](http://www.opensource.org/licenses/MIT).
