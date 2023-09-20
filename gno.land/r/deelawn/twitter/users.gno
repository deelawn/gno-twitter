package twitter

import (
	"errors"
	"std"
)

var (
	ErrNoSuchUser        = errors.New("no such user")
	ErrInvalidUserSchema = errors.New("invalid user schema")
)

// User represents a user on Twitter.
type User struct {
	// Address is the user's own wallet address.
	Address std.Address
	// Follows is a list of users that the user follows.
	Follows []*User
	// Tweets is a list of tweets that the user has posted.
	Tweets []*Tweet
	// Comments is a list of comments that the user has posted.
	Comments []*Comment
}

// Follow adds a user to the list of users that the user follows. It returns an error
// if no such user exists.
func (u *User) Follow(address std.Address) error {

	user, err := resolveUser(address, false)
	if err != nil {
		return err
	}

	u.Follows = append(u.Follows, user)
	return nil
}

// resolveUser will attempt to find the user registed with the given address.
// If no such user exists, it will create one if createIfNotExist is true.
// Otherwise it will return ErrNoSuchUser.
func resolveUser(address std.Address, createIfNotExist bool) (*User, error) {

	userIface, exists := Users.Get(address.String())
	if !exists {
		if !createIfNotExist {
			return nil, ErrNoSuchUser
		}

		user := &User{
			Address: address,
		}
		Users.Set(address.String(), user)
		return user, nil
	}

	user, ok := userIface.(*User)
	if !ok {
		return nil, ErrInvalidUserSchema
	}

	return user, nil
}
