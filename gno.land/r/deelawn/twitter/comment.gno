package twitter

import "time"

type Comment struct {
	Author    *User
	Timestamp time.Time
	Tweet     *Tweet
	Content   string
}
