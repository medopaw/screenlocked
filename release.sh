#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$latest_tag" ]; then
    # If no tag exists, use v0.0.1
    suggested_version="v0.0.1"
else
    # Extract version numbers from the latest tag
    version_numbers=($(echo "$latest_tag" | grep -oE '[0-9]+'))
    major=${version_numbers[0]}
    minor=${version_numbers[1]}
    patch=${version_numbers[2]}

    # Increment the patch number
    suggested_version="v${major}.${minor}.$((patch + 1))"
fi

while true; do
    # Display the suggested version and get user input
    read -p "Suggested version $suggested_version (press Enter to accept or input a new version): " version

    # If the user just presses Enter, use the suggested version
    if [ -z "$version" ]; then
        version=$suggested_version
    fi

    # Validate the version format (vX.Y.Z)
    if [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        break
    else
        echo "Error: Invalid version format. Please use the format vX.Y.Z (e.g., v1.2.3)"
        sleep 0.1 # Prevent echo output from overlapping the read prompt
    fi
done

# Execute git commands to create and push the tag
git tag -a "$version" -m "Release $version" && git push origin --tags

if [ $? -ne 0 ]; then
    echo "Error: Tag creation or push failed"
    exit 1
fi

echo "Tag created and pushed: $version"

# Offer to open the GitHub Actions URL in the default browser (Mac). Press y to open or Enter to exit.
read -n 1 -p "Open GitHub Actions page? Press 'y' to open, or any other key to exit: " open_choice
echo ""
if [ "$open_choice" = "y" ] || [ "$open_choice" = "Y" ]; then
    open "https://github.com/medopaw/screenlocked/actions"
fi
