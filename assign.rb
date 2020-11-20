# Camp Cluedo Randomiser

=begin

    # TODO: Add description and usage
    This program ensures that no small loops occur.

=end

require 'net/smtp'

EMAIL_ADDRESS = "58ridgeterrace@gmail.com"
EMAIL_PASSWORD = File.read("email_password.txt").chomp


PEOPLE_FILENAME = "people.txt"
LOCATION_FILENAME = "locations.txt"
OBJECT_FILENAME = "objects.txt"

MESSAGE_FORMAT = <<MESSAGE_END
From: Ridge House <#{EMAIL_ADDRESS}>
To: %<full_name>s <%<email>s>
Subject: Ridge House Cluedo Instructions

Dear %<name>s,

You have to kill %<target>s.
To do this they must hold a %<object>s %<location>s.

Good luck.
MESSAGE_END

# TODO: Add more objects

def load_people
    people = []
    File.open(PEOPLE_FILENAME, 'r') do |f|
        f.each_line do |line|
            name, contact = *line.scan(/"(.+?)\s+<(.*?)>"/).first
            people.push({
                name: name.split(/\s/).first,
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

def load_objectives
    locations = load_locations
    objects = load_objects
    return locations.shuffle.zip(objects.shuffle.cycle).map { |location, object| { location: location, object: object} }
end

def assign_assignments
    people = load_people.shuffle
    objectives = load_objectives#.shuffle
    assignments = people.map.with_index do |person, i|
        target = people[(i + 1) % people.size]
        mission = objectives.shift
        { 
            name: person[:name], 
            target: target[:name], 
            object: mission[:object],
            location: mission[:location],
            email: person[:contact],
            full_name: person[:full_name],
        }
    end
    send_emails(assignments)
end

def send_emails(assignments)
    email = Net::SMTP.new('smtp.gmail.com', 587)
    email.enable_starttls
    p EMAIL_ADDRESS
    p EMAIL_PASSWORD
    email.start('smtp.gmail.com', EMAIL_ADDRESS, EMAIL_PASSWORD, :login) do |smtp|
        smtp.starttls
        assignments.each do |assignment|
            from = EMAIL_ADDRESS
            # to = person[:contact]
            to = 'huw_taylor@hotmail.co.uk' # TODO: When working, change for the line above 
            message = MESSAGE_FORMAT % assignment
            # smtp.send_message(message, from, to)
            break
        end
    end
    exit(0)    
end

assign_assignments
