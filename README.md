# Background

## Camp Cluedo

*Camp Cluedo* is a game I was introduced to on camp. 
To play, the names of all participants are put into one hat. Another hat has the same number of different locations. And a third hat has the same number of different objects that could be found around the campsite.
Everyone playing would then take a name, an object and a location. These would be your target, and your method of killing them.

The objective of the game was to witness your target in the location, holding the object. You could recruit other people to help, including people who weren't playing themselves.

Once you had killed your target, you then recieved their mission, to kill *their* target in *their* location with *their* object, and so it would continue.

## Emerging Problems

One unfortunte scenario that could occur is that you recieved yourself as a target. In this case you were immortal (unless you wanted to kill yourself), but also essentiall out of the game and unable to progress. A similar situation of there being a small cycle of people who had each other in a loop, whereby one of them would eventually get themselves while the game continued around them.

Another problem with the game, was that either the person organising it couldn't play, or there would be someone who knew all the possible locations and objects. The more people that were playing, the less of an issue this was, as there would be many different possible combinations, and all the locations would be common (or at least plausible) places across the campsite. But with a smaller number of players, this becomes more of a problem.

(This last problem can be solved by providing more locations and objects than are needed, so nobody knows which ones are in play.) 

## Solutions

This project aims to counter all of the problems using the power of **digital technology**.
It creates a random loop of all the participants, which ensures that if anyone ends up with themselves as their target, then everyone else has been killed.

## Variants

There is apparently a variant of the game, whereby each participant provides a method of killing which can, but does not necessarily, need to be specific to a location. This project allows for this variant.

# Usage

This project requires [ruby](https://www.ruby-lang.org/en/downloads/) installed on your computer.
Once that is installed, clone or download this repository.

You can set up your own participants in the `people.txt` file. It assumes that each person will be on a separate line and they will be in the format `"FirstName LastName <email@addres.com>"`, with the surrounding speech marks (`"`) being optional. 

You can add your own locations in the `locations.txt` file. It assumes that each location will be on a separate line, and that they include their own prepositions, for example "*on* the stairs", or "*in* the kitchen".

You can add your own objects in the `objects.txt` file. It assumes that each object will be on a separate line, and that they include their own article, for example "*a* fork", or "*the* TV remote".

You can also add you own methods, and use those. You can add the methods to the `methods.txt` file. It assumes each method will be on its own line. To have the assignment use the methods instead of locations and objects, change the final line of `assign.rb` from `assign_assignments`, to `assign_assignments(false)`.

**Important**: To send out the emails, you must create a file called `email_password.txt` which contains the password for your email SMTP server. It is not saved to the repository because having passwords publically is a bad idea.

To test the assignment and make sure that the emailing is working correctly, you can test it by changing the line containging `TEST_EMAIL_ADDRESS = nil` to `TEST_EMAIL_ADDRESS = "your@email.address"` (NB. Make sure the email address is in speech marks (`"`)).

To run the assignment, and email out the instructions to people, set the TEST_EMAIL_ADDRESS back to `nil`, and run the `assign.rb` file.
