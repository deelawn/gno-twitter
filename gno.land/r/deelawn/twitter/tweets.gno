package twitter

import "time"

type Tweet struct {
	Author    *User
	Timestamp time.Time
	Comments  []*Comment
	Content   string
}
