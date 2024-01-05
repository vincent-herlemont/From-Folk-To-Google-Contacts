#!/usr/bin/env nu

def main [folk_file: string] {
    let table = open $folk_file

    # Split emails into separate columns
    let table_with_emails = $table | each { |e|
       | get emails
       | split column "," "E-mail 1 - Value" "E-mail 2 - Value" "E-mail 3 - Value" "E-mail 4 - Value" "E-mail 5 - Value" "E-mail 6 - Value"
       | insert id $e.id
    } | flatten | move "id" --before "E-mail 1 - Value"

    # Split phone numbers into separate columns
    let table_with_phone_numbers = $table | each { |e|
       | get phones
       | split column "," "Phone 2 - Value" "Phone 3 - Value" "Phone 4 - Value" "Phone 5 - Value" "Phone 6 - Value"
       | insert id $e.id
    } | flatten | move "id" --before "Phone 2 - Value"

    # Split addresses into separate columns
    let table_with_addresses = $table | each { |e|
       | get addresses
       | split column "," "Address 2 - Formatted" "Address 3 - Formatted" "Address 4 - Formatted" "Address 5 - Formatted" "Address 6 - Formatted"
       | insert id $e.id
    } | flatten | move "id" --before "Address 2 - Formatted"

    # Select only the columns we want
    let clean_table = $table
        | select id firstname lastname gender notes contactType birthday companies
        | rename id "Given Name" "Family Name" "Gender" "Notes" "Subject" "Birthday" "Company"

    # Google Contacts CSV reference table
    let reference_table = [
    [
        ,"Name"
        ,"Given Name"
        ,"Additional Name"
        ,"Family Name"
        ,"Yomi Name"
        ,"Given Name Yomi"
        ,"Additional Name Yomi"
        ,"Family Name Yomi"
        ,"Name Prefix"
        ,"Name Suffix"
        ,"Initials"
        ,"Nickname",
        ,"Short Name"
        ,"Maiden Name"
        ,"Birthday"
        ,"Gender"
        ,"Location"
        ,"Billing Information"
        ,"Directory Server"
        ,"Mileage"
        ,"Occupation"
        ,"Hobby"
        ,"Sensitivity"
        ,"Priority"
        ,"Subject"
        ,"Notes"
        ,"Language"
        ,"Photo"
        ,"Group Membership"
    ];
    [
        "","","","","","","","","",""
        "","","","","","","","","",""
        "","","","","","","","",""
    ]]

    let join_table = $clean_table
    | join $table_with_emails id
    | join $table_with_phone_numbers id
    | join $table_with_addresses id
    | reject id

    let out = $join_table | merge $reference_table

    $out | to csv | save -f "contacts.csv"
}


