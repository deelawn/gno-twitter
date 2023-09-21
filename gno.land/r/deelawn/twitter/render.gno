package twitter

import (
	"std"
	"strconv"
	"strings"

	"gno.land/p/demo/avl"
)

const (
	baseRelativeURL string = "../deelawn/twitter:"
	timestampFmt    string = "2006-01-02 15:04:05"

	err404 string = "404 not found"
)

// Render examines the provided path and renders the appropriate content.
func Render(path string) string {

	pathParts := strings.Split(path, "/")

	// Render the homepage if no path was provided.
	if len(pathParts) == 0 || pathParts[0] == "" {
		return renderLinksToAllUsers()
	}

	if pathParts[0] == "users" {

		if len(pathParts) == 1 {
			return renderLinksToAllUsers()
		}

		userAddress := pathParts[1]

		// Render the user page that displays all of their tweets.
		if len(pathParts) == 2 {
			renderedUser, err := renderUser(userAddress)
			if err != nil {
				return err.Error()
			}

			return renderedUser
		}

		// There must be least 3 path parts to get here.
		if pathParts[2] == "follows" {
			// Render the page that shows all the users a user follows.
			renderedFollows, err := renderFollows(userAddress)
			if err != nil {
				return err.Error()
			}

			return renderedFollows
		}

		return ""
	}

	// Render a specific tweet with all of its comments.
	if pathParts[0] == "tweets" {
		if len(pathParts) == 1 {
			// We aren't going to render all tweets.
			return err404
		}
		var tweetID string
		if len(pathParts) > 1 {
			tweetID = pathParts[1]
		}

		tweetIface, exists := Tweets.Get(tweetID)
		if !exists {
			return "no such tweet exists"
		}

		tweet, ok := tweetIface.(*Tweet)
		if !ok {
			return "invalid tweet schema"
		}

		return renderTweetWithComments(tweet)
	}

	return err404
}

// renderLinksToAllUsers generates a homepage of sorts with links to all users.
func renderLinksToAllUsers() string {

	b := strings.Builder{}
	renderUserFunc := avl.IterCbFn(
		func(key string, value interface{}) bool {
			b.WriteString(`<a href="` + baseRelativeURL + `users/` + key + `">` + key + `</a></br>`)
			// b.WriteString(renderLink(":users/"+key, key) + "")
			return false
		},
	)

	b.WriteString("<h1>Twitter users</h1></br>")
	Users.Iterate("", "", renderUserFunc)

	return b.String()
}

// renderUser will render a user's profile page that includes the user's address
// and links to all the tweets that the user has posted. It returns an error if the user does
// not exist.
func renderUser(address string) (string, error) {

	user, err := resolveUser(std.Address(address), false)
	if err != nil {
		return "", err
	}

	b := strings.Builder{}
	b.WriteString("<h1>User: " + address + "</h1>")
	numFollowers := strconv.Itoa(len(user.Follows))
	b.WriteString(`<h3><a href="` + address + `/follows">Follows ` + numFollowers + `</a></h3>`)
	b.WriteString("<h3>Tweets</h3>")

	// Render each tweet in the reverse order.
	for i := len(user.Tweets) - 1; i >= 0; i-- {
		tweetPath := ":tweets/" + user.Tweets[i].ID
		renderedTweet := renderTweet(user.Tweets[i], false, true)
		b.WriteString(`<a href="../` + baseRelativeURL + `tweets/` + user.Tweets[i].ID + `">` + renderedTweet + `</a></br>`)
		// b.WriteString(renderLink(tweetPath, renderTweet(user.Tweets[i], false)))
		b.WriteString("</br>")
	}

	return b.String(), nil
}

// renderTweet will render a tweet with the timestamp in the header and the content
// in the body. The header will be prefixed by the user's address if showUserAddress
// is true.
func renderTweet(tweet *Tweet, showUserAddress bool, condense bool) string {

	b := strings.Builder{}

	// The header size.
	b.WriteString("<h3>")

	// Determine whether to include the user address in the header.
	// This should be included if the render is not happening on the user's
	// own page, but it should be excluded if it is.
	if showUserAddress {
		b.WriteString(tweet.Author.Address.String() + " -- ")
	}

	b.WriteString(tweet.Timestamp.Format(timestampFmt) + "</h3>")
	if condense {
		var condensedContent string
		runes := []rune(tweet.Content)
		if len(runes) < 20 {
			condensedContent = string(runes)
		} else {
			condensedContent = string(runes[:20]) + "..."
		}
		b.WriteString(condensedContent + "</br>")
	} else {
		b.WriteString(tweet.Content + "</br>")
	}

	return b.String()
}

// renderTweetWithComments renders a tweet with all of its comments below it.
func renderTweetWithComments(tweet *Tweet) string {

	b := strings.Builder{}
	b.WriteString(renderTweet(tweet, true, false))
	b.WriteString("<h3>Comments</h3>")

	// Render each comment in the order they were made.
	for _, comment := range tweet.Comments {
		b.WriteString(renderComment(comment))
		b.WriteString("</br>")
	}

	return b.String()
}

// renderComment renders a tweet comment with the author address and
// timestamp in the header and the content in the body.
func renderComment(comment *Comment) string {

	b := strings.Builder{}

	b.WriteString("<h4>")
	b.WriteString(comment.Author.Address.String() + " -- ")
	b.WriteString(comment.Timestamp.Format(timestampFmt) + "</h4>")
	b.WriteString(comment.Content + "</br>")

	return b.String()
}

// renderFollows renders a page that shows all the users that the user with the given
// address follows.
func renderFollows(address string) (string, error) {

	user, err := resolveUser(std.Address(address), false)
	if err != nil {
		return "", err
	}

	b := strings.Builder{}
	b.WriteString("<h1>" + address + " Follows</h1>")

	// Render each user that the user follows.
	for _, followedUser := range user.Follows {
		b.WriteString(`<a href="../../` + baseRelativeURL + `users/` + followedUser.Address.String() + `">` + followedUser.Address.String() + `</a></br>`)
		// b.WriteString(renderLink(":users/"+followedUser.Address.String(), followedUser.Address.String()) + "</br>")
	}

	return b.String(), nil
}
