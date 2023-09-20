package twitter

import (
	"strings"

	"gno.land/p/demo/avl"
)

func Render(path string) string {

	switch path {
	case "":
		return renderAllUsers()
	}

	return "404 not found"
}

func renderAllUsers() string {

	b := strings.Builder{}
	renderUserFunc := avl.IterCbFn(
		func(key string, value interface{}) bool {
			b.WriteString(key + "\n")
			return false
		},
	)

	b.WriteString("# Twitter users\n")
	Users.Iterate("", "", renderUserFunc)

	return b.String()
}
