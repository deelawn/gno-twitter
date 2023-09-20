package twitter

import (
	"std"
	"strings"

	"gno.land/p/demo/avl"
)

const urlBasePath string = "/r/deelawn/twitter"

func Render(path string) string {

	pathParts := strings.Split(path, "/")
	if len(pathParts) == 0 || pathParts[0] == "" {
		return renderAllUsers()
	}

	if pathParts[0] == "users" {
		var userAddress string
		if len(pathParts) > 1 {
			userAddress = pathParts[1]
		}

		return renderUser(userAddress)
	}

	return "404 not found"
}

func renderAllUsers() string {

	b := strings.Builder{}
	renderUserFunc := avl.IterCbFn(
		func(key string, value interface{}) bool {
			b.WriteString(renderLink(":users/"+key, key) + "\n")
			return false
		},
	)

	b.WriteString("# Twitter users\n")
	Users.Iterate("", "", renderUserFunc)

	return b.String()
}

func renderUser(address string) string {

	user, err := resolveUser(std.Address(address), false)
	if err != nil {
		return err.Error()
	}

	b := strings.Builder{}
	b.WriteString("# User: " + address + "\n")

	// Now render each tweet with the timestamp as the header.
	for _, tweet := range user.Tweets {
		b.WriteString("### " + tweet.Timestamp.String() + "\n")
		b.WriteString(tweet.Content + "\n\n")
	}

	return b.String()
}

func renderLink(path string, text string) string {
	// TODO: why doesn't fmt package work?
	return "[" + text + "](" + urlBasePath + path + ")"
}
