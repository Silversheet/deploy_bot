def tag_release
    printf "${BLUE}======> 🏷  Creating production version tag${NC}\n\n"

    # Delete old tag and recreate if deploying twice in same day
    if [ $NEW_TAG == $PREVIOUS_TAG ]
    then
      printf "${BLUE}==> 🏷  Deleting and recreating tag: $NEW_TAG${NC}\n\n"
      git tag -d $NEW_TAG
      git push --delete origin $NEW_TAG
    fi

    git tag -a $NEW_TAG -m "Deployed to production"

    # Create changelog between deploys
    CHANGELOG=$(git log $PREVIOUS_TAG..$NEW_TAG --abbrev-commit --oneline)

    # Amend tag with changelog between current and previous tag
    git tag $NEW_TAG $NEW_TAG -f -m "$CHANGELOG"

    printf "${BLUE}==> 🏷   Pushing tag to GitHub${NC}\n\n"
    git push origin $NEW_TAG
  end
