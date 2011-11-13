#!/usr/bin/ruby

# Update Marketing Version
if ARGV.length == 1
    inputVers = ARGV[0]
    if inputVers.match /^\d\.\d$/
        system "agvtool new-marketing-version #{ARGV[0]}"
    else
        p 'Input string must be of format 1.1'
        exit
    end
end

# Update other versions
system "agvtool next-version -all"

# Get the version strings
vers = %x[agvtool vers -terse].strip
mvers = %x[agvtool what-marketing-version -terse1].strip
tag = "v#{mvers}.#{vers}"
commitMsg = "Update version to v#{mvers} (#{vers})"

# Add and commit the changes
system "git add ."
system "git commit -m \"#{commitMsg}\""

# Tag
system "git tag #{tag} -m \"#{commitMsg}\""
