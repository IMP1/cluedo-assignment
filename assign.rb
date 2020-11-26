# Camp Cluedo Randomiser

require 'net/smtp'

#=====================#
# CUSTOMISATION BEGIN #
#=====================#

# Who you want the email to be send from
SENDER_NAME = "Ridge House"
EMAIL_ADDRESS = "58ridgeterrace@gmail.com"
EMAIL_SUBJECT = "[For Your Eyes Only] Ridge House Cluedo Instructions"

# This is used to test the email service. When it is nil, emails will be sent out to all participants
TEST_EMAIL_ADDRESS = nil

# These are the SMTP server details. This will depend on who you are sending the email from.
SMTP_SERVER_ADDRESS = "smtp.gmail.com"
SMTP_SERVER_PORT = 587

# This is the format of the message. You can use the following special texts
#   * %<name>s       : The first name of the recipient of the email.
#   * %<email>s      : The email address of the recipient.
#   * %<full_name>s  : The full name of the recipient.
#   * %<target>s     : The person who is to be killed by the recipient.
#   * %<method>s     : The method by which the recipient is to kill.
# They will be replaced in the email automatically with the correct value.
# The first few lines of the email are necessary in their formatting, but the body of the email is up to you.

MESSAGE_FORMAT = <<MESSAGE_END
From: #{SENDER_NAME} <#{EMAIL_ADDRESS}>
To: %<full_name>s <%<email>s>
Subject: #{EMAIL_SUBJECT}

Dear %<name>s,

The Ridgemas Cluedo is about to begin.
The game starts at noon today (Thursday).

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

#===================#
# CUSTOMISATION END #
#===================#

PEOPLE_FILENAME = "people.txt"
LOCATION_FILENAME = "locations.txt"
OBJECT_FILENAME = "objects.txt"
METHOD_FILENAME = "methods.txt"

EMAIL_PASSWORD = File.read("email_password.txt").chomp

def load_people
    people = []
    File.open(PEOPLE_FILENAME, 'r') do |f|
        f.each_line do |line|
            _, name, contact = *line.scan(/("?)(.+?)\s+<(.*?)>\1/).first
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

def load_methods
    methods = []
    File.open(METHOD_FILENAME, 'r') do |f|
        f.each_line do |line|
            methods.push(line.chomp)
        end
    end
    return methods
end

def load_objectives(include_locations=true)
    if include_locations
        locations = load_locations
        objects = load_objects
        return locations.shuffle.zip(objects.shuffle)
                                .select { |location, object| !location.nil? && !object.nil? }
                                .map { |location, object| "they must hold #{object} #{location}" }
    else
        return load_methods
    end
end

def send_emails(assignments)
    email = Net::SMTP.new(SMTP_SERVER_ADDRESS, SMTP_SERVER_PORT)
    email.enable_starttls
    email.start(SMTP_SERVER_ADDRESS, EMAIL_ADDRESS, EMAIL_PASSWORD, :login) do |smtp|
        assignments.each do |assignment|
            from = EMAIL_ADDRESS
            to = assignment[:email]
            to = TEST_EMAIL_ADDRESS unless TEST_EMAIL_ADDRESS.nil?
            message = MESSAGE_FORMAT % assignment
            smtp.send_message(message, from, to)
        end
    end
end

def assign_assignments(include_locations=true)
    $stdout.sync = true
    puts "Loading data"
    people = load_people.shuffle
    objectives = load_objectives(include_locations).shuffle
    puts "Assigning missions"
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
    puts "Sending emails" + (TEST_EMAIL_ADDRESS.nil? ? "" : " to test email address.")
    send_emails(assignments)
    puts "Complete."
end

assign_assignments
