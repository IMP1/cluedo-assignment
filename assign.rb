# Camp Cluedo Randomiser

=begin

    # TODO: Add description and usage
    This program ensures that no small loops occur.

=end

require 'net/smtp'

EMAIL_ADDRESS = "58ridgeterrace@gmail.com"
EMAIL_PASSWORD = File.read("email_password.txt").chomp

TEST_EMAIL_ADDRESS = "huw_taylor@hotmail.co.uk" # TODO: Set this to nil once emails are working. 

SMTP_SERVER_ADDRESS = "smtp.gmail.com"
SMTP_SERVER_PORT = 587

PEOPLE_FILENAME = "people.txt"
LOCATION_FILENAME = "locations.txt"
OBJECT_FILENAME = "objects.txt"

MESSAGE_FORMAT = <<MESSAGE_END
From: Ridge House <#{EMAIL_ADDRESS}>
To: %<full_name>s <%<email>s>
Subject: [For Your Eyes Only] Ridge House Cluedo Instructions

Dear %<name>s,

You have to kill %<target>s.
To do this %<method>s.

Good luck.


======== Rules ========

To kill someone you must witness them holding the required object in the necessary place and declare that they are now dead.
Once you kill your target, you then take on their misson.
You cannot force the object onto your target. 
Your target does not have to have taken the object from you, specifically, to be killed.
If you end up with yourself as your target then you have won!
You don't have to work alone, but be careful who you trust.

=======================

MESSAGE_END

# TODO: Add more objects
# TODO: Get more locations and objects from the house (and have them see the lists)
# TODO: Create a README with instructions (including having a `email_password.txt` file with the SMTP password stuff if necessary)

def load_people
    people = []
    File.open(PEOPLE_FILENAME, 'r') do |f|
        f.each_line do |line|
            name, contact = *line.scan(/"(.+?)\s+<(.*?)>"/).first
            people.push({
                name: name.split(/\s/).first, # ASSUMPTION: People's first names are their casual use-names
                full_name: name,
                contact: contact,
            })
        end
    end
    return people
end

def load_locations
    locations = []
    File.open(LOCATION_FILENAME, 'r') do |f|
        f.each_line do |line|
            locations.push(line.chomp)
        end
    end
    return locations
end

def load_objects
    objects = []
    File.open(OBJECT_FILENAME, 'r') do |f|
        f.each_line do |line|
            objects.push(line.chomp)
        end
    end
    return objects
end

def load_objectives(include_locations=true)
    if include_locations
        locations = load_locations
        objects = load_objects
        return locations.shuffle.zip(objects.shuffle.cycle).map { |location, object| "they must hold #{object} #{location}" }
    else
        return load_methods
    end
end

def assign_assignments(include_locations=true)
    people = load_people.shuffle
    objectives = load_objectives(include_locations)
    assignments = people.map.with_index do |person, i|
        target = people[(i + 1) % people.size]
        mission = objectives.shift
        { 
            name: person[:name], 
            target: target[:name], 
            method: mission,
            email: person[:contact],
            full_name: person[:full_name],
        }
    end
    send_emails(assignments)
end

def send_emails(assignments)
    email = Net::SMTP.new(SMTP_SERVER_ADDRESS, SMTP_SERVER_PORT)
    email.enable_starttls
    email.start(SMTP_SERVER_ADDRESS, EMAIL_ADDRESS, EMAIL_PASSWORD, :login) do |smtp|
        assignments.each do |assignment|
            from = EMAIL_ADDRESS
            to = assignment[:email]
            to = 'huw_taylor@hotmail.co.uk' unless TEST_EMAIL_ADDRESS.nil?
            message = MESSAGE_FORMAT % assignment
            smtp.send_message(message, from, to)
        end
    end
end

assign_assignments
